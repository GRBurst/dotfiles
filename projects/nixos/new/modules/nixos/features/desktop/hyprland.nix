{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.nixos.features.desktop.hyprland;
in {
  options.my.nixos.features.desktop.hyprland.enable = lib.mkEnableOption "Hyprland";

  config = lib.mkIf cfg.enable {
    programs.hyprland = {
      enable = true;
      xwayland.enable = true;
      withUWSM = true;
    };

    xdg.portal = {
      enable = true;
      config.common.default = "*";
      extraPortals = [pkgs.xdg-desktop-portal-hyprland];
    };

    security.pam.services.hyprlock = {};
  };
}
