{ config, lib, pkgs, ... }:
let cfg = config.my.nixos.core.networking;
in {
  options.my.nixos.core.networking.enable = lib.mkEnableOption "Networking Config";

  config = lib.mkIf cfg.enable {
    networking = {
      networkmanager = {
        enable = true;
        wifi.macAddress = "random";
        plugins = with pkgs; [
            networkmanager-openconnect
            networkmanager-openvpn
        ];
      };
      enableIPv6 = true;
      firewall = {
        enable = true;
        allowedTCPPorts = [ 12345 15432 53292 3000 8000 4848 5000 ];
        allowedUDPPorts = [ 50624 50625 ];
        trustedInterfaces = [
          "docker0"
          # Add stable custom bridges here, e.g. "br-myapp"
        ];
      };
      nameservers = [ "9.9.9.9" "149.112.112.112" "2620:fe::fe" "2620:fe::9" ];
      extraHosts = ''
        127.0.0.1       *.localhost *.localhost.localdomain
      '';
    };
    services.tailscale.enable = true;
  };
}
