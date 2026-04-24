{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.nixos.features.desktop.i3;
in {
  options.my.nixos.features.desktop.i3.enable = lib.mkEnableOption "i3 Window Manager";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = config.my.nixos.features.desktop.xserver.enable;
        message = "my.nixos.features.desktop.i3 requires xserver.enable = true.";
      }
    ];

    services.xserver.windowManager.i3 = {
      enable = true;
      extraPackages = with pkgs; [
        feh
        rofi
        i3status-rust
        i3lock
        gnome-keyring
      ];
      extraSessionCommands = ''
        xsetroot -bg black
        xsetroot -cursor_name left_ptr
        gnome-keyring-daemon --start -d --components=pkcs11,secrets,ssh
      '';
    };

    services.unclutter-xfixes.enable = true;

    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita";
    };

    programs.i3lock.enable = true;
  };
}
