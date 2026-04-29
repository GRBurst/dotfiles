{
  config,
  lib,
  ...
}: let
  cfg = config.my.hm.features.yazi;
in {
  options.my.hm.features.yazi.enable = lib.mkEnableOption "Yazi file manager";

  config = lib.mkIf cfg.enable {
    programs.yazi = {
      enable = true;
      enableZshIntegration = true;
      shellWrapperName = "yy";
    };
  };
}
