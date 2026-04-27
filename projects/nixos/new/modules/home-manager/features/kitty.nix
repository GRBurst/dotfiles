{
  config,
  lib,
  osConfig,
  ...
}: let
  cfg = config.my.hm.features.kitty;
  fontCfg = osConfig.my.nixos.features.fonts;
in {
  options.my.hm.features.kitty.enable = lib.mkEnableOption "Kitty Terminal";

  config = lib.mkIf cfg.enable {
    programs.kitty = {
      enable = true;
      font = {
        name = fontCfg.families.monospace.name;
        package = fontCfg.families.monospace.package;
      };
    };
  };
}
