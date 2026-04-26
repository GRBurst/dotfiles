{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.hm.bundles.desktop;
in {
  options.my.hm.bundles.desktop = {
    enable = lib.mkEnableOption "Desktop Tools";
    x11 = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Include X11-specific packages";
    };
    wayland = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Include Wayland-specific packages";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs;
    # Universal
      [
        networkmanagerapplet
        libnotify
        pavucontrol
        vanilla-dmz
        papirus-icon-theme
        flameshot
      ]
      ++ lib.optionals cfg.x11 [
        xclip
        xdotool
        xkill
        feh
        rofi
      ]
      ++ lib.optionals cfg.wayland [
        waybar
        hyprpaper
        hyprlock
        wl-clipboard
        grim
        slurp
        grimblast
        wlogout
        hypridle
      ];
  };
}
