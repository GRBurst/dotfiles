{ config, lib, pkgs, ... }:
let cfg = config.my.nixos.features.security;
in {
  options.my.nixos.features.security.enable = lib.mkEnableOption "Security Tools";

  config = lib.mkIf cfg.enable {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    programs.seahorse.enable = true;
    services.clamav = {
      daemon.enable = true;
      updater.enable = true;
    };
  };
}
