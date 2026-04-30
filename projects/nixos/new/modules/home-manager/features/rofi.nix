{
  config,
  lib,
  osConfig,
  ...
}: let
  cfg = config.my.hm.features.rofi;
  fontCfg = osConfig.my.nixos.features.fonts.families;
in {
  options.my.hm.features.rofi.enable =
    lib.mkEnableOption "managed rofi launcher";

  config = lib.mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      font = "${fontCfg.monospace.name} 14";
      location = "top";
      modes = ["window" "run" "drun" "ssh" "combi"];
      theme = "~/.config/my/theme/current/rofi.rasi";
      extraConfig = {
        dpi = 192;
        width = 100;
        columns = 1;
        matching = "fuzzy";
        sidebar-mode = true;
        "combi-modi" = "window,run,drun";
        "drun-show-actions" = false;
        timeout = {
          action = "kb-cancel";
          delay = 0;
        };
        filebrowser = {
          directories-first = true;
          sorting-method = "name";
        };
      };
    };

    home.file."${config.programs.rofi.configPath}".force = true;
  };
}
