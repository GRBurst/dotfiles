{
  config,
  lib,
  ...
}: let
  cfg = config.my.nixos.features.ausweisapp;
in {
  options.my.nixos.features.ausweisapp = {
    enable = lib.mkEnableOption "AusweisApp (German eID)";
    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open the firewall ports required by AusweisApp.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.ausweisapp = {
      enable = true;
      inherit (cfg) openFirewall;
    };
  };
}
