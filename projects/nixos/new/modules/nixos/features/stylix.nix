{
  config,
  lib,
  ...
}: let
  cfg = config.my.nixos.features.stylix;
in {
  options.my.nixos.features.stylix.enable = lib.mkEnableOption "legacy Stylix migration shim";

  config = lib.mkIf cfg.enable {
    my.nixos.features.style = {
      enable = lib.mkDefault true;
      stylixMigration.enable = lib.mkDefault true;
    };
  };
}
