{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.nixos.features.desktop.sway;
in {
  options.my.nixos.features.desktop.sway = {
    enable = lib.mkEnableOption "Sway/SwayFX window manager";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.swayfx;
      description = "Sway package. Override with pkgs.sway to use vanilla sway (e.g. on NVIDIA).";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.sway = {
      enable = true;
      package = cfg.package;
      wrapperFeatures.gtk = true;
      xwayland.enable = true;
    };

    # Allow swaylock to authenticate via PAM
    security.pam.services.swaylock = {};

    # XDG desktop portal for Wayland (wlr backend for sway)
    xdg.portal = {
      enable = true;
      extraPortals = [pkgs.xdg-desktop-portal-wlr];
      config.sway.default = lib.mkForce ["wlr" "gtk"];
    };
  };
}
