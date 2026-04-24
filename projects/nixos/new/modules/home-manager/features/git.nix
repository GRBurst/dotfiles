{
  config,
  lib,
  ...
}: let
  cfg = config.my.hm.features.git;
in {
  options.my.hm.features.git = {
    enable = lib.mkEnableOption "Git Config";
    name = lib.mkOption {
      type = lib.types.str;
      description = "Git user.name.";
    };
    email = lib.mkOption {
      type = lib.types.strMatching "^[^@[:space:]]+@[^@[:space:]]+\\.[^@[:space:]]+$";
      description = "Git user.email.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = cfg.name;
          email = cfg.email;
        };
      };
    };
  };
}
