{
  config,
  lib,
  ...
}: let
  cfg = config.my.nixos.features.steam;
in {
  options.my.nixos.features.steam.enable = lib.mkEnableOption "Steam";

  config = lib.mkIf cfg.enable {
    programs.steam.enable = true;
  };
}
