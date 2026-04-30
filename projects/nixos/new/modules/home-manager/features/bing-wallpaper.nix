{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.hm.features.bingWallpaper;
  types = lib.types;
  hyprlandPrimaryMonitor =
    if cfg.hyprlandPrimaryMonitor == null
    then ""
    else cfg.hyprlandPrimaryMonitor;

  bingWallpaper = pkgs.writeShellApplication {
    name = "my-bing-wallpaper";
    runtimeInputs =
      [
        pkgs.coreutils
        pkgs.curl
        pkgs.jq
      ]
      ++ cfg.setter.packages;

    text = ''
      set -euo pipefail

      market=${lib.escapeShellArg cfg.market}
      count=${toString cfg.count}
      prefer_uhd=${
        if cfg.preferUhd
        then "1"
        else "0"
      }
      nasa_enabled=${
        if cfg.nasaApod.enable
        then "1"
        else "0"
      }
      nasa_api_key=${lib.escapeShellArg cfg.nasaApod.apiKey}
      nasa_prefer_hd=${
        if cfg.nasaApod.preferHd
        then "1"
        else "0"
      }

      cache_home="''${XDG_CACHE_HOME:-$HOME/.cache}"
      out_dir="$cache_home/bing-wallpaper"
      mkdir -p "$out_dir"
      manifest="$out_dir/latest-paths"

      use_paths() {
        ${cfg.setter.command}
      }

      write_manifest() {
        tmp_manifest="$manifest.tmp"
        : > "$tmp_manifest"
        for path in "$@"; do
          printf '%s\n' "$path" >> "$tmp_manifest"
        done
        mv "$tmp_manifest" "$manifest"
      }

      read_cached_manifest() {
        [ -s "$manifest" ] || return 1

        cached=()
        while IFS= read -r path; do
          [ -n "$path" ] || continue
          [ -f "$path" ] || return 1
          cached+=("$path")
        done < "$manifest"

        [ "''${#cached[@]}" -gt 0 ] || return 1
        use_paths "''${cached[@]}"
      }

      read_cached_latest() {
        [ -f "$out_dir/latest.jpg" ] || return 1
        use_paths "$out_dir/latest.jpg"
      }

      read_cached_nasa() {
        [ -f "$out_dir/nasa-latest.jpg" ] || return 1
        printf '%s\n' "$out_dir/nasa-latest.jpg"
      }

      use_cache_or_fail() {
        echo "$1" >&2
        if read_cached_manifest; then
          echo "Reused cached Bing wallpaper manifest" >&2
          exit 0
        fi
        if read_cached_latest; then
          echo "Reused cached Bing latest.jpg" >&2
          exit 0
        fi
        echo "No Bing wallpapers downloaded and no cache available" >&2
        exit 1
      }

      absolute_bing_url() {
        case "$1" in
          http://*|https://*|file://*) printf '%s\n' "$1" ;;
          *) printf 'https://www.bing.com%s\n' "$1" ;;
        esac
      }

      fetch_bing_paths() {
        bing_api="''${BING_WALLPAPER_BING_API:-https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=$count&mkt=$market}"
        json="$(curl --fail --location --silent --show-error "$bing_api")" || return 1

        bing_paths=()

        for i in $(seq 0 "$((count - 1))"); do
          urlbase="$(printf '%s' "$json" | jq -r ".images[$i].urlbase // empty")"
          url="$(printf '%s' "$json" | jq -r ".images[$i].url // empty")"
          startdate="$(printf '%s' "$json" | jq -r ".images[$i].startdate // empty")"

          if [ -z "$urlbase" ] || [ -z "$url" ] || [ -z "$startdate" ]; then
            continue
          fi

          fallback_url="$(absolute_bing_url "$url")"
          uhd_url="$(absolute_bing_url "''${urlbase}_UHD.jpg")"
          target="$out_dir/''${startdate}_$i.jpg"
          tmp="$target.tmp"

          if [ "$prefer_uhd" = "1" ] && curl --fail --location --silent --show-error "$uhd_url" -o "$tmp"; then
            mv "$tmp" "$target"
          else
            rm -f "$tmp"
            if curl --fail --location --silent --show-error "$fallback_url" -o "$tmp"; then
              mv "$tmp" "$target"
            else
              rm -f "$tmp"
              continue
            fi
          fi

          bing_paths+=("$target")
        done

        [ "''${#bing_paths[@]}" -gt 0 ]
      }

      fetch_nasa_path() {
        [ "$nasa_enabled" = "1" ] || return 1

        nasa_end_date="$(date +%F)"
        nasa_start_date="$(date -d "$nasa_end_date -6 days" +%F)"
        nasa_api="''${BING_WALLPAPER_NASA_API:-https://api.nasa.gov/planetary/apod?api_key=$nasa_api_key&start_date=$nasa_start_date&end_date=$nasa_end_date}"
        json="$(curl --fail --location --silent --show-error "$nasa_api")" || return 1

        selected="$(
          printf '%s' "$json" |
            jq -r --arg prefer_hd "$nasa_prefer_hd" '
              def image_url:
                if $prefer_hd == "1"
                then (.hdurl // .url // empty)
                else (.url // .hdurl // empty)
                end;

              if type == "array" then . else [.] end
              | map(select(.media_type == "image") | {date, url: image_url})
              | map(select(.date != null and .url != ""))
              | sort_by(.date)
              | last
              | if . == null then empty else [.date, .url] | @tsv end
            '
        )"

        [ -n "$selected" ] || return 1
        apod_date="''${selected%%	*}"
        image_url="''${selected#*	}"
        [ -n "$apod_date" ] || return 1
        [ -n "$image_url" ] || return 1

        apod_file_date="''${apod_date//-/}"
        target="$out_dir/nasa-''${apod_file_date}.jpg"
        tmp="$target.tmp"
        curl --fail --location --silent --show-error "$image_url" -o "$tmp" || {
          rm -f "$tmp"
          return 1
        }
        mv "$tmp" "$target"
        ln -sfn "$target" "$out_dir/nasa-latest.jpg"
        printf '%s\n' "$target"
      }

      fetch_nasa_path_or_cache() {
        [ "$nasa_enabled" = "1" ] || return 1
        fetch_nasa_path || read_cached_nasa
      }

      if ! fetch_bing_paths; then
        use_cache_or_fail "Failed to fetch Bing metadata"
      fi

      if [ "''${#bing_paths[@]}" -eq 0 ]; then
        use_cache_or_fail "No Bing wallpapers downloaded"
      fi

      display_paths=("''${bing_paths[0]}")

      if nasa_path="$(fetch_nasa_path_or_cache)"; then
        display_paths+=("$nasa_path")
      elif [ "$nasa_enabled" != "1" ] && [ "''${#bing_paths[@]}" -gt 1 ]; then
        display_paths+=("''${bing_paths[1]}")
      fi

      ln -sfn "''${bing_paths[0]}" "$out_dir/latest.jpg"
      write_manifest "''${display_paths[@]}"

      use_paths "''${display_paths[@]}"
    '';
  };
in {
  options.my.hm.features.bingWallpaper = {
    enable = lib.mkEnableOption "Bing wallpaper user timer";

    market = lib.mkOption {
      type = types.str;
      default = "de-DE";
      description = "Bing image archive market, for example de-DE or en-US.";
    };

    interval = lib.mkOption {
      type = types.str;
      default = "6h";
      description = "systemd timer interval used after each successful run.";
    };

    count = lib.mkOption {
      type = types.ints.between 1 8;
      default = 1;
      description = "Number of recent Bing images to fetch and pass to the setter.";
    };

    preferUhd = lib.mkOption {
      type = types.bool;
      default = true;
      description = "Try the derived UHD image URL before falling back to Bing's advertised URL.";
    };

    hyprlandPrimaryMonitor = lib.mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Preferred Hyprland monitor for the primary Bing wallpaper. Null uses Hyprland's first monitor.";
    };

    nasaApod = {
      enable = lib.mkEnableOption "NASA APOD secondary wallpaper";

      apiKey = lib.mkOption {
        type = types.str;
        default = "DEMO_KEY";
        description = "NASA APOD API key.";
      };

      preferHd = lib.mkOption {
        type = types.bool;
        default = true;
        description = "Prefer APOD hdurl over url when APOD returns an image.";
      };
    };

    setter = {
      packages = lib.mkOption {
        type = types.listOf types.package;
        default = [
          pkgs.feh
          pkgs.hyprland
        ];
        description = "Packages required by the wallpaper setter command.";
      };

      command = lib.mkOption {
        type = types.lines;
        default = ''
          if [ "$#" -eq 0 ]; then
            echo "No wallpaper paths provided" >&2
            exit 1
          fi

          preferred_monitor=${lib.escapeShellArg hyprlandPrimaryMonitor}

          if command -v hyprctl >/dev/null 2>&1 && monitors_json="$(hyprctl monitors -j 2>/dev/null)"; then
            primary="$(
              printf '%s' "$monitors_json" |
                jq -r --arg preferred "$preferred_monitor" '
                  if $preferred != "" and any(.[]; .name == $preferred)
                  then $preferred
                  else .[0].name // empty
                  end
                '
            )"

            [ -n "$primary" ] || exit 1
            hyprctl hyprpaper wallpaper "$primary, $1, cover"

            if [ "$#" -ge 2 ]; then
              printf '%s' "$monitors_json" |
                jq -r --arg primary "$primary" '.[] | select(.name != $primary) | .name' |
                while IFS= read -r monitor; do
                  [ -n "$monitor" ] || continue
                  hyprctl hyprpaper wallpaper "$monitor, $2, cover"
                done
            fi
          elif [ -n "''${DISPLAY:-}" ]; then
            feh --bg-fill "$@"
          else
            echo "No supported wallpaper session found" >&2
            exit 1
          fi
        '';
        description = "Shell command that receives downloaded image paths as positional arguments.";
      };
    };

    package = lib.mkOption {
      type = types.package;
      readOnly = true;
      default = bingWallpaper;
      description = "Generated Bing wallpaper updater package.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [bingWallpaper];

    systemd.user.services.bing-wallpaper = {
      Unit = {
        Description = "Set Bing wallpaper of the day";
        After = ["graphical-session.target"];
      };

      Service = {
        Type = "oneshot";
        ExecStart = "${bingWallpaper}/bin/my-bing-wallpaper";
      };
    };

    systemd.user.timers.bing-wallpaper = {
      Unit.Description = "Run Bing wallpaper updater periodically";
      Timer = {
        OnStartupSec = "1m";
        OnUnitActiveSec = cfg.interval;
        Persistent = true;
        Unit = "bing-wallpaper.service";
      };
      Install.WantedBy = ["timers.target"];
    };
  };
}
