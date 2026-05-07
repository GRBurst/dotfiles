{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.hm.features.displayProfiles;
  types = lib.types;

  enabledOutputs = profile: builtins.filter (o: o.enable) profile.outputs;
  primaryOutput = profile: lib.findFirst (o: o.enable && o.primary) null profile.outputs;
  secondaryOutputs = profile: builtins.filter (o: o.enable && !o.primary) profile.outputs;

  renderX11Position = o: "${toString o.position.x}x${toString o.position.y}";

  mkAutorandrProfile = profile: {
    name = profile.name;
    value = {
      fingerprint =
        lib.listToAttrs
        (map (o: {
            name = o.name;
            value = o.fingerprint;
          })
          profile.outputs);
      config =
        lib.listToAttrs
        (map (o: {
            name = o.name;
            value =
              if o.enable
              then
                lib.filterAttrs (_: v: v != null) {
                  enable = true;
                  primary = o.primary;
                  mode = o.mode;
                  position = renderX11Position o;
                  rate = o.rate;
                  gamma = o.gamma;
                }
              else {
                enable = false;
              };
          })
          profile.outputs);
      hooks.postswitch = lib.concatStringsSep "\n" (lib.filter (s: s != "") [
        "${pkgs.i3}/bin/i3-msg reload"
        (lib.optionalString config.my.hm.features.bingWallpaper.enable "${config.my.hm.features.bingWallpaper.package}/bin/my-bing-wallpaper apply-cache || true")
      ]);
    };
  };

  profileJson = builtins.toJSON cfg.profiles;

  displayProfileScriptText = ''
    set -euo pipefail

    profiles_json=${lib.escapeShellArg profileJson}

    usage() {
      echo "Usage: my-display-profile apply|watch sway|hyprland" >&2
      exit 2
    }

    detect_outputs() {
      case "$compositor" in
        sway) swaymsg -t get_outputs ;;
        hyprland) hyprctl monitors all -j ;;
        *) usage ;;
      esac
    }

    connected_names_json() {
      case "$compositor" in
        sway) jq -c '[.[].name]' ;;
        hyprland) jq -c '[.[].name]' ;;
        *) usage ;;
      esac
    }

    select_profile() {
      connected="$1"
      jq -cn \
        --argjson profiles "$profiles_json" \
        --argjson connected "$connected" '
          def same_set($a; $b): (($a | sort) == ($b | sort));
          def subset($a; $b): all($a[]; . as $name | any($b[]; . == $name));
          first(
            ($profiles[] | select(same_set([.outputs[].name]; $connected))),
            ($profiles[] | select(subset([.outputs[] | select(.enable == true) | .name]; $connected)))
          )
        '
    }

    apply_sway_output() {
      output="$1"
      name="$(jq -r '.name' <<< "$output")"
      enable="$(jq -r '.enable' <<< "$output")"

      if [ "$enable" != "true" ]; then
        swaymsg -- output "$name" disable >/dev/null
        return 0
      fi

      args=(-- output "$name" enable)
      mode="$(jq -r '.mode // empty' <<< "$output")"
      if [ -n "$mode" ]; then
        args+=(mode "$mode")
      fi
      x="$(jq -r '.position.x' <<< "$output")"
      y="$(jq -r '.position.y' <<< "$output")"
      args+=(position "$x $y")
      scale="$(jq -r '.scale' <<< "$output")"
      args+=(scale "$scale")

      swaymsg "''${args[@]}" >/dev/null
    }

    apply_hyprland_output() {
      output="$1"
      name="$(jq -r '.name' <<< "$output")"
      enable="$(jq -r '.enable' <<< "$output")"

      if [ "$enable" != "true" ]; then
        hyprctl keyword monitor "$name, disable" >/dev/null
        return 0
      fi

      mode="$(jq -r '.mode // "preferred"' <<< "$output")"
      rate="$(jq -r '.rate // empty' <<< "$output")"
      x="$(jq -r '.position.x' <<< "$output")"
      y="$(jq -r '.position.y' <<< "$output")"
      scale="$(jq -r '.scale' <<< "$output")"
      if [ "$mode" != "preferred" ] && [ -n "$rate" ]; then
        mode="$mode@$rate"
      fi

      hyprctl keyword monitor "$name, $mode, ''${x}x''${y}, $scale" >/dev/null
    }

    apply_workspace_roles() {
      profile="$1"
      primary="$(jq -r '[.outputs[] | select(.enable == true and .primary == true) | .name][0] // empty' <<< "$profile")"
      secondary="$(jq -r '[.outputs[] | select(.enable == true and .primary != true) | .name][0] // empty' <<< "$profile")"
      [ -n "$primary" ] || return 0
      [ -n "$secondary" ] || secondary="$primary"

      if [ "$compositor" = "hyprland" ]; then
        for workspace in $(seq 1 10); do
          hyprctl dispatch moveworkspacetomonitor "$workspace $primary" >/dev/null || true
        done
        for workspace in $(seq 11 19); do
          hyprctl dispatch moveworkspacetomonitor "$workspace $secondary" >/dev/null || true
        done
      fi
    }

    apply_profile() {
      outputs="$(detect_outputs)"
      connected="$(connected_names_json <<< "$outputs")"
      profile="$(select_profile "$connected")"
      [ "$profile" != "null" ] || {
        echo "No display profile matches connected outputs: $connected" >&2
        exit 1
      }

      while IFS= read -r output; do
        [ -n "$output" ] || continue
        case "$compositor" in
          sway) apply_sway_output "$output" ;;
          hyprland) apply_hyprland_output "$output" ;;
        esac
      done < <(jq -c '.outputs[]' <<< "$profile")

      apply_workspace_roles "$profile"
      my-bing-wallpaper apply-cache >/dev/null 2>&1 || true
    }

    watch_profile() {
      apply_profile

      case "$compositor" in
        sway)
          swaymsg -m -t subscribe '["output"]' | while IFS= read -r _event; do
            apply_profile || true
          done
          ;;
        hyprland)
          runtime_dir="''${XDG_RUNTIME_DIR:-/run/user/$(id -u)}"
          socket="$runtime_dir/hypr/''${HYPRLAND_INSTANCE_SIGNATURE:-}/.socket2.sock"
          if [ -S "$socket" ]; then
            socat -U - UNIX-CONNECT:"$socket" | while IFS= read -r event; do
              case "$event" in
                monitoradded*|monitorremoved*) apply_profile || true ;;
              esac
            done
          fi
          ;;
      esac
    }

    [ "$#" -eq 2 ] || usage
    action="$1"
    compositor="$2"

    case "$action" in
      apply) apply_profile ;;
      watch) watch_profile ;;
      *) usage ;;
    esac
  '';
  displayProfilePackage = pkgs.writeShellApplication {
    name = "my-display-profile";
    runtimeInputs = [
      pkgs.coreutils
      pkgs.jq
      pkgs.socat
      pkgs.sway
      pkgs.hyprland
    ];
    text = displayProfileScriptText;
  };
in {
  options.my.hm.features.displayProfiles = {
    enable = lib.mkEnableOption "shared display profile model";

    profiles = lib.mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = lib.mkOption {type = types.str;};
          outputs = lib.mkOption {
            type = types.listOf (types.submodule {
              options = {
                name = lib.mkOption {type = types.str;};
                fingerprint = lib.mkOption {
                  type = types.nullOr types.str;
                  default = null;
                };
                enable = lib.mkOption {
                  type = types.bool;
                  default = true;
                };
                primary = lib.mkOption {
                  type = types.bool;
                  default = false;
                };
                mode = lib.mkOption {
                  type = types.nullOr types.str;
                  default = null;
                };
                rate = lib.mkOption {
                  type = types.nullOr types.str;
                  default = null;
                };
                position = lib.mkOption {
                  type = types.submodule {
                    options = {
                      x = lib.mkOption {
                        type = types.int;
                        default = 0;
                      };
                      y = lib.mkOption {
                        type = types.int;
                        default = 0;
                      };
                    };
                  };
                  default = {};
                };
                scale = lib.mkOption {
                  type = types.float;
                  default = 1.0;
                };
                gamma = lib.mkOption {
                  type = types.nullOr types.str;
                  default = null;
                };
              };
            });
            default = [];
          };
        };
      });
      default = [];
    };

    package = lib.mkOption {
      type = types.package;
      readOnly = true;
      default = displayProfilePackage;
      description = "Generated display profile apply/watch helper.";
    };

    scriptText = lib.mkOption {
      type = types.lines;
      readOnly = true;
      default = displayProfileScriptText;
      description = "Generated display profile helper script text, exposed for eval checks.";
    };
  };

  config = lib.mkIf cfg.enable {
    assertions =
      lib.flatten
      (map (profile: let
          outputNames = map (o: o.name) profile.outputs;
          enabled = enabledOutputs profile;
          primary = primaryOutput profile;
        in [
          {
            assertion = outputNames == lib.unique outputNames;
            message = "display profile ${profile.name} must have unique output names.";
          }
          {
            assertion = enabled != [];
            message = "display profile ${profile.name} must have at least one enabled output.";
          }
          {
            assertion = primary != null && builtins.length (builtins.filter (o: o.enable && o.primary) profile.outputs) == 1;
            message = "display profile ${profile.name} must have exactly one enabled primary output.";
          }
          {
            assertion = builtins.all (o: o.fingerprint != null) profile.outputs;
            message = "display profile ${profile.name} outputs must have fingerprints for autorandr generation.";
          }
        ])
        cfg.profiles);

    home.packages = [displayProfilePackage];

    programs.autorandr = {
      enable = true;
      profiles = lib.listToAttrs (map mkAutorandrProfile cfg.profiles);
    };
  };
}
