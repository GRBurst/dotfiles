{
  config,
  lib,
  ...
}: let
  cfg = config.my.hm.features.waybar;
in {
  options.my.hm.features.waybar = {
    enable = lib.mkEnableOption "Waybar";
    battery = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Show battery module (for laptops)";
    };
    windowManagers = lib.mkOption {
      type = lib.types.listOf (lib.types.enum ["hyprland" "sway"]);
      default = ["hyprland"];
      description = "WMs to generate waybar configs for.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      style = ''
        @import url("../my/theme/current/waybar.css");
      '';
    };

    xdg.configFile = lib.listToAttrs (map (wm: let
      wmModulesLeft =
        if wm == "hyprland"
        then ["hyprland/workspaces" "hyprland/window"]
        else ["sway/workspaces" "sway/window"];
      wmModuleConfig =
        if wm == "hyprland"
        then {
          "hyprland/workspaces" = {
            format = "{id}";
            on-click = "activate";
            sort-by-number = true;
          };
        }
        else {
          "sway/workspaces" = {
            format = "{name}";
            on-click = "activate";
            disable-scroll = true;
          };
          "sway/window" = {};
        };
      barConfig =
        {
          layer = "top";
          position = "top";
          height = 30;
          modules-left = wmModulesLeft;
          modules-center = ["clock"];
          modules-right =
            ["pulseaudio" "network" "cpu" "memory"]
            ++ lib.optional cfg.battery "battery"
            ++ ["tray"];
          clock = {
            format = "{:%H:%M}";
            format-alt = "{:%Y-%m-%d %H:%M}";
            tooltip-format = "<tt>{calendar}</tt>";
          };
          pulseaudio = {
            format = "{volume}% {icon}";
            format-muted = "muted";
            format-icons.default = ["" "" ""];
            on-click = "pavucontrol";
          };
          network = {
            format-wifi = "{essid} ({signalStrength}%)";
            format-ethernet = "{ifname}";
            format-disconnected = "disconnected";
          };
          cpu.format = "cpu {usage}%";
          memory.format = "mem {}%";
        }
        // lib.optionalAttrs cfg.battery {
          battery = {
            format = "{capacity}% {icon}";
            format-charging = "{capacity}% ";
            format-icons = ["" "" "" "" ""];
          };
        }
        // wmModuleConfig;
    in {
      name = "waybar/config-${wm}";
      value.text = builtins.toJSON [barConfig];
    })
    cfg.windowManagers);
  };
}
