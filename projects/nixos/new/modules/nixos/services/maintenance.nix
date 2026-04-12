{ config, lib, pkgs, ... }:
let cfg = config.my.nixos.services.maintenance;
in {
  options.my.nixos.services.maintenance.enable = lib.mkEnableOption "Maintenance Services";

  config = lib.mkIf cfg.enable {
    services.cron.enable = true;
    services.lorri.enable = true;
    services.fwupd.enable = true;
    services.fstrim.enable = true;
    services.locate = { enable = true; interval = "22:00"; };
    services.psd.enable = true; # Profile Sync Daemon
    services.gvfs.enable = true;
    services.udisks2.enable = true;
    services.acpid.enable = true;
    services.upower.enable = true;
    services.openntpd.enable = true;
    services.automatic-timezoned.enable = true;
    
    # Journald optimization
    services.journald.extraConfig = ''
      Storage=persist
      Compress=yes
      SystemMaxUse=128M
      RuntimeMaxUse=8M
    '';
  };
}
