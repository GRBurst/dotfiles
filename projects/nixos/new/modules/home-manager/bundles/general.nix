{ config, lib, pkgs, ... }:
let cfg = config.my.hm.bundles.general;
in {
  options.my.hm.bundles.general.enable = lib.mkEnableOption "General System Tools";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      htop btop iotop lsof
      wget ripgrep fzf fd tree
      unzip zip
      file
      jq
    ];
  };
}
