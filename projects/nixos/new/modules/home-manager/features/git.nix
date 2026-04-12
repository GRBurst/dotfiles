{ config, lib, ... }:
let cfg = config.my.hm.features.git;
in {
  options.my.hm.features.git.enable = lib.mkEnableOption "Git Config";

  config = lib.mkIf cfg.enable {
    programs.git = {
      enable = true;
      settings = {
        user = {
          name = "GRBurst";
          email = "GRBurst@protonmail.com";
        };
      };
    };
  };
}
