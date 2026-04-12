{ config, lib, pkgs, ... }:
let cfg = config.my.nixos.features.desktop.hyprland;
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
    };
    
    services.xserver.xkb = {
        layout = "de,de";
        variant = "neo,basic";
        options = "grp:menu_toggle";
    };

    # environment.sessionVariables = {
    #    NIXOS_OZONE_WL = "1";
    #    QT_STYLE_OVERRIDE = "gtk2";
    #    QT_QPA_PLATFORMTHEME = "gtk2";
    #    _JAVA_AWT_WM_NONREPARENTING = "1";
    #    AWT_TOOLKIT = "MToolkit";
    # };
  };
}
