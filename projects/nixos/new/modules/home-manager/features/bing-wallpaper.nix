{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.hm.features.bingWallpaper;
  types = lib.types;

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

      api="https://www.bing.com/HPImageArchive.aspx?format=js&idx=0&n=$count&mkt=$market"
      if ! json="$(curl --fail --location --silent --show-error "$api")"; then
        use_cache_or_fail "Failed to fetch Bing metadata"
      fi

      paths=()

      for i in $(seq 0 "$((count - 1))"); do
        urlbase="$(printf '%s' "$json" | jq -r ".images[$i].urlbase")"
        url="$(printf '%s' "$json" | jq -r ".images[$i].url")"
        startdate="$(printf '%s' "$json" | jq -r ".images[$i].startdate")"

        if [ "$urlbase" = "null" ] || [ "$url" = "null" ] || [ "$startdate" = "null" ]; then
          continue
        fi

        fallback_url="https://www.bing.com$url"
        uhd_url="https://www.bing.com''${urlbase}_UHD.jpg"
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

        paths+=("$target")
      done

      if [ "''${#paths[@]}" -eq 0 ]; then
        use_cache_or_fail "No Bing wallpapers downloaded"
      fi

      ln -sfn "''${paths[0]}" "$out_dir/latest.jpg"
      write_manifest "''${paths[@]}"

      use_paths "''${paths[@]}"
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

          if command -v hyprctl >/dev/null 2>&1 && hyprctl hyprpaper listloaded >/dev/null 2>&1; then
            hyprctl hyprpaper reload ",$1"
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
