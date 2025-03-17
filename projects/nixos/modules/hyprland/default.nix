{ inputs, config, pkgs, ... }:

{
  wayland.windowManager.hyprland = {
    enable = true;
    plugins = with pkgs.hyprlandPlugins; [ hy3 ];
    extraConfig = builtins.readFile ./hypr.conf;
  };
}
