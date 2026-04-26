{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.nixos.features.desktop.gnome;
in {
  options.my.nixos.features.desktop.gnome.enable = lib.mkEnableOption "GNOME desktop";

  config = lib.mkIf cfg.enable {
    services.desktopManager.gnome.enable = true;

    # DM is controlled by displayManager.nix — prevent GNOME from forcing GDM
    services.displayManager.gdm.enable = lib.mkDefault false;

    # Remove bloat packages
    environment.gnome.excludePackages = with pkgs; [
      gnome-tour
      epiphany
      geary
      gnome-music
      totem
      gnome-terminal
    ];

    programs.dconf.enable = true;
  };
}
