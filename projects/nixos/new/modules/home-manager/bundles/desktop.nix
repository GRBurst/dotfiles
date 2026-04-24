{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.hm.bundles.desktop;
in {
  options.my.hm.bundles.desktop.enable = lib.mkEnableOption "Desktop Tools";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      xclip
      xdotool
      xkill
      feh
      rofi
      flameshot
      networkmanagerapplet
      libnotify
      pavucontrol
      vanilla-dmz
      papirus-icon-theme
      waybar
      hyprpaper
      hyprlock
    ];
  };
}
