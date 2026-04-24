{
  config,
  lib,
  ...
}: let
  cfg = config.my.nixos.features.security;
in {
  options.my.nixos.features.security = {
    enable = lib.mkEnableOption "Security Tools";
    clamav.tcpSocket = lib.mkOption {
      type = with lib.types;
        nullOr (submodule {
          options = {
            addr = lib.mkOption {
              type = str;
              default = "127.0.0.1";
            };
            port = lib.mkOption {
              type = port;
              default = 3310;
            };
          };
        });
      default = null;
      description = "Expose the clamav daemon over TCP (for scanning from containers). Null disables the TCP socket.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    programs.seahorse.enable = true;
    services.clamav = {
      daemon.enable = true;
      daemon.settings = lib.mkIf (cfg.clamav.tcpSocket != null) {
        TCPAddr = cfg.clamav.tcpSocket.addr;
        TCPSocket = cfg.clamav.tcpSocket.port;
      };
      updater.enable = true;
    };
  };
}
