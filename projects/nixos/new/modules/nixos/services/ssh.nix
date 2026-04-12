{ config, lib, ... }:
let cfg = config.my.nixos.services.ssh;
in {
  options.my.nixos.services.ssh.enable = lib.mkEnableOption "SSH Server";

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [ 53292 ];
    };
  };
}
