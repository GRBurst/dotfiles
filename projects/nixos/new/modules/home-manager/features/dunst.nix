{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.hm.features.dunst;
  dunstCommand = "dunst -config ~/.config/my/theme/current/dunst.conf";
in {
  options.my.hm.features.dunst = {
    enable = lib.mkEnableOption "Dunst notification daemon for i3 and Hyprland";

    command = lib.mkOption {
      type = lib.types.str;
      readOnly = true;
      default = dunstCommand;
      description = "Command used by supported window manager session startup paths.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [pkgs.dunst];
    }
    (lib.mkIf config.my.hm.features.i3.enable {
      my.hm.features.i3.commonStartupCommands = [cfg.command];
    })
    (lib.mkIf config.my.hm.features.hyprland.enable {
      my.hm.features.hyprland.extraExecOnce = [cfg.command];
    })
  ]);
}
