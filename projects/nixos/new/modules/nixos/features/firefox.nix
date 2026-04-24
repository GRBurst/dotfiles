{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.nixos.features.firefox;
in {
  options.my.nixos.features.firefox = {
    enable = lib.mkEnableOption "Firefox (or a compatible package)";
    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.librewolf;
      description = "Browser package to install as the system firefox.";
    };
    nativeMessagingHosts = lib.mkOption {
      type = with lib.types; listOf package;
      default = [pkgs.tridactyl-native];
      description = "Native messaging hosts exposed to the browser.";
    };
  };

  config = lib.mkIf cfg.enable {
    programs.firefox = {
      enable = true;
      package = cfg.package;
      nativeMessagingHosts.packages = cfg.nativeMessagingHosts;
    };
  };
}
