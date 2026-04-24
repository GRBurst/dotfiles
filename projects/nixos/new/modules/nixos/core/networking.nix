{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.nixos.core.networking;
in {
  options.my.nixos.core.networking = {
    enable = lib.mkEnableOption "Networking Config";
    extraTcpPorts = lib.mkOption {
      type = with lib.types; listOf port;
      default = [];
      description = "Host-specific TCP ports to open in addition to the base set.";
    };
    extraUdpPorts = lib.mkOption {
      type = with lib.types; listOf port;
      default = [];
      description = "Host-specific UDP ports to open in addition to the base set.";
    };
    macAddressPolicy = lib.mkOption {
      type = lib.types.enum ["permanent" "preserve" "random" "stable"];
      default = "random";
      description = "NetworkManager MAC randomization policy (applied to both wifi and ethernet).";
    };
    nameservers = lib.mkOption {
      type = with lib.types; listOf str;
      default = ["9.9.9.9" "149.112.112.112" "2620:fe::fe" "2620:fe::9"];
    };
  };

  config = lib.mkIf cfg.enable {
    networking = {
      networkmanager = {
        enable = true;
        wifi.macAddress = cfg.macAddressPolicy;
        ethernet.macAddress = cfg.macAddressPolicy;
        plugins = with pkgs; [
          networkmanager-openconnect
          networkmanager-openvpn
        ];
      };
      enableIPv6 = true;
      firewall = {
        enable = true;
        allowedTCPPorts = [12345 15432 53292 3000 8000 4848 5000] ++ cfg.extraTcpPorts;
        allowedUDPPorts = [50624 50625] ++ cfg.extraUdpPorts;
        trustedInterfaces = [
          "docker0"
        ];
      };
      nameservers = cfg.nameservers;
      extraHosts = ''
        127.0.0.1       *.localhost *.localhost.localdomain
      '';
    };
    services.tailscale.enable = true;
  };
}
