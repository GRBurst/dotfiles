{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.nixos.core.laptop;
in {
  options.my.nixos.core.laptop.enable = lib.mkEnableOption "Laptop Power Management (TLP)";

  config = lib.mkIf cfg.enable {
    services.power-profiles-daemon.enable = false;
    services.tlp = {
      enable = true;
      settings = {
        TLP_DEFAULT_MODE = "BAT";
        START_CHARGE_THRESH_BAT0 = 20;
        STOP_CHARGE_THRESH_BAT0 = 80;

        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";

        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 1;

        DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth wwan";
        DEVICES_TO_DISABLE_ON_BAT = "bluetooth wwan";

        USB_AUTOSUSPEND = 1;
      };
    };
  };
}
