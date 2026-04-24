{
  config,
  lib,
  ...
}: let
  cfg = config.my.nixos.services.syncthing;
  user = config.my.nixos.core.user.primary;
in {
  options.my.nixos.services.syncthing.enable = lib.mkEnableOption "Syncthing";

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = user != null;
        message = "my.nixos.services.syncthing requires a primary user (set isPrimary = true on a user).";
      }
    ];
    services.syncthing = {
      enable = true;
      inherit user;
      configDir = "/home/${user}/.config/syncthing";
      dataDir = "/home/${user}/.config/syncthing";
      openDefaultPorts = true;
    };
  };
}
