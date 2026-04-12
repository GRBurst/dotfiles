{ config, lib, ... }:
let cfg = config.my.nixos.services.printing;
in {
  options.my.nixos.services.printing.enable = lib.mkEnableOption "Printing";

  config = lib.mkIf cfg.enable {
    services.printing.enable = true;
    services.avahi.enable = true;
  };
}
