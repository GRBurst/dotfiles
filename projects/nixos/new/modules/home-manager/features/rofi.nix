{
  config,
  lib,
  osConfig,
  ...
}: let
  cfg = config.my.hm.features.rofi;
  fontCfg = osConfig.my.nixos.features.fonts.families;
  baseConfig = {
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
in {
  options.my.hm.features.rofi = {
    enable = lib.mkEnableOption "managed rofi launcher";
    modeDisplayNames = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {
        run = "run";
        drun = "drun";
        ssh = "ssh";
        window = "window";
        combi = "combi";
      };
      description = "Display labels rendered by rofi for each enabled mode.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.rofi = {
      enable = true;
      font = "${fontCfg.monospace.name} 14";
      location = "top";
      modes = ["window" "run" "drun" "ssh" "combi"];
      theme = "~/.config/my/theme/current/rofi.rasi";
      extraConfig =
        baseConfig
        // lib.mapAttrs (_: name: {"display-name" = name;}) cfg.modeDisplayNames;
    };

    home.file."${config.programs.rofi.configPath}".force = true;
  };
}
