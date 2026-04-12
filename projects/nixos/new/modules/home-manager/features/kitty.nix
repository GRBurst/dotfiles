{ config, lib, ... }:
let cfg = config.my.hm.features.kitty;
in {
  options.my.hm.features.kitty.enable = lib.mkEnableOption "Kitty Terminal";

  config = lib.mkIf cfg.enable {
    programs.kitty.enable = true;
  };
}
