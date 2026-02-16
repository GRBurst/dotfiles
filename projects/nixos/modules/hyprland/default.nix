{pkgs, ...}: let
  configFiles = [
    ./hypr.conf
    ./plugins.conf
    ./keybindings.conf
  ];
  config = builtins.concatStringsSep "\n" (map builtins.readFile configFiles);
in {
  wayland.windowManager.hyprland = {
    enable = true;
    plugins = with pkgs.hyprlandPlugins; [hy3];
    extraConfig = config;
  };
  /*
  https://github.com/hyprland-community/awesome-hyprland
  eww ironbar ashell
  swww
  yofi anyrun
  */
}
