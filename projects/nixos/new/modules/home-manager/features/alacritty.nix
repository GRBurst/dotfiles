{
  config,
  lib,
  ...
}: let
  cfg = config.my.hm.features.alacritty;
in {
  options.my.hm.features.alacritty = {
    enable = lib.mkEnableOption "Alacritty Terminal";
    terminal = lib.mkOption {
      type = lib.types.str;
      default = "xterm-256color";
      description = "Value for alacritty env.TERM.";
    };
    scrollingMultiplier = lib.mkOption {
      type = lib.types.int;
      default = 3;
      description = "Lines of output per scroll wheel tick.";
    };
    saveSelectionToClipboard = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Copy text selection directly into the system clipboard.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
      settings = {
        env.TERM = cfg.terminal;
        scrolling.multiplier = cfg.scrollingMultiplier;
        selection.save_to_clipboard = cfg.saveSelectionToClipboard;
      };
    };
  };
}
