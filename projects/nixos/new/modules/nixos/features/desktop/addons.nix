{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.nixos.features.desktop.addons;
in {
  options.my.nixos.features.desktop.addons.enable = lib.mkEnableOption "Desktop Addons";

  config = lib.mkIf cfg.enable {
    programs.appimage.enable = true;
    programs.noisetorch.enable = true;
    programs.dconf.enable = true;

    # Redshift (Eye protection)
    services.redshift = {
      enable = true;
      temperature = {
        day = 5000;
        night = 3000;
      };
      brightness = {
        day = "1.0";
        night = "0.75";
      };
    };

    # iOS Support
    services.usbmuxd.enable = true;

    # Gnome Services (Required for GTK apps outside Gnome)
    services.gnome = {
      gnome-keyring.enable = true;
      gnome-settings-daemon.enable = true;
      core-shell.enable = true; # often needed for gsd
    };
  };
}
