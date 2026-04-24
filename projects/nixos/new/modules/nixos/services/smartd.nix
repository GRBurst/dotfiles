{
  config,
  lib,
  ...
}: let
  cfg = config.my.nixos.services.smartd;
in {
  options.my.nixos.services.smartd = {
    enable = lib.mkEnableOption "SMART disk monitoring (smartd)";
    autodetect = lib.mkOption {
      type = lib.types.bool;
      default = true;
    };
  };

  config = lib.mkIf cfg.enable {
    services.smartd = {
      enable = true;
      inherit (cfg) autodetect;
    };
  };
}
