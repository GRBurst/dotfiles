{
  config,
  lib,
  ...
}: let
  cfg = config.my.nixos.features.coolercontrol;
in {
  options.my.nixos.features.coolercontrol.enable = lib.mkEnableOption "CoolerControl fan/pump control";

  config = lib.mkIf cfg.enable {
    programs.coolercontrol.enable = true;
  };
}
