{
  config,
  lib,
  ...
}: let
  cfg = config.my.hm.features.waybar;
in {
  options.my.hm.features.waybar = {
    enable = lib.mkEnableOption "Waybar for Hyprland";
    battery = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Show battery module (for laptops)";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.waybar = {
      enable = true;
      settings = [
        {
          layer = "top";
          position = "top";
          height = 30;
          modules-left = ["hyprland/workspaces" "hyprland/window"];
          modules-center = ["clock"];
          modules-right =
            ["pulseaudio" "network" "cpu" "memory"]
            ++ lib.optional cfg.battery "battery"
            ++ ["tray"];

          "hyprland/workspaces" = {
            format = "{id}";
            on-click = "activate";
            sort-by-number = true;
          };
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
          battery = lib.mkIf cfg.battery {
            format = "{capacity}% {icon}";
            format-charging = "{capacity}% ";
            format-icons = ["" "" "" "" ""];
          };
        }
      ];

      style = ''
        @import url("../my/theme/current/waybar.css");
      '';
    };
  };
}
