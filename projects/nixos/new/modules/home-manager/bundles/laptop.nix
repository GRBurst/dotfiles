{ config, lib, pkgs, ... }:
let cfg = config.my.hm.bundles.laptop;
in {
  options.my.hm.bundles.laptop.enable = lib.mkEnableOption "Laptop Bundle";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      tlp powertop cbatticon brillo acpi 
      brightnessctl # light 
      zbar
      linuxPackages.tp_smapi
      linuxPackages.acpi_call
    ];
  };
}
