{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.nixos.core.packages;
in {
  options.my.nixos.core.packages.enable = lib.mkEnableOption "Extra System Packages & Services";

  config = lib.mkIf cfg.enable {
    # System-wide Packages
    environment.systemPackages = with pkgs; [
      proton-vpn
      protonmail-bridge
      proton-vpn-cli
      hdparm
      adapta-gtk-theme
      adapta-kde-theme
    ];

    # Java
    programs.java.enable = true;

    # Screen (with custom config)
    programs.screen = {
      enable = true;
      screenrc = ''
        term screen-256color
        termcapinfo xterm*|xs|rxvt* ti@:te@
        startup_message off
        caption string '%{= G}[ %{G}%H %{g}][%= %{= w}%?%-Lw%?%{= R}%n*%f %t%?%{= R}(%u)%?%{= w}%+Lw%?%= %{= g}][ %{y}Load: %l %{g}][%{B}%Y-%m-%d %{W}%c:%s %{g}]'
        caption always
      '';
    };

    # GPaste
    programs.gpaste.enable = true;

    # Services
    services.flatpak.enable = true;
    services.snap.enable = true; # Requires nix-snapd module
    services.autorandr.enable = true;
  };
}
