{
  config,
  lib,
  ...
}: let
  cfg = config.my.nixos.features.desktop.gnome;
in {
  options.my.nixos.features.desktop.gnome.enable = lib.mkEnableOption "GNOME desktop";

  config = lib.mkIf cfg.enable {
    services.desktopManager.gnome.enable = true;
  };
}
