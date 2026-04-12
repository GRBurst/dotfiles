{ config, lib, pkgs, ... }:
let cfg = config.my.hm.features.alacritty;
in {
  options.my.hm.features.alacritty.enable = lib.mkEnableOption "Alacritty Terminal";

  config = lib.mkIf cfg.enable {
    programs.alacritty = {
      enable = true;
    };
  };
}
