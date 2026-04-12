{ config, lib, pkgs, ... }:
let cfg = config.my.nixos.services.syncthing;
in {
  options.my.nixos.services.syncthing.enable = lib.mkEnableOption "Syncthing";

  config = lib.mkIf cfg.enable {
    services.syncthing = {
      enable = true;
      user = "pallon";
      configDir = "/home/pallon/.config/syncthing";
      dataDir = "/home/pallon/.config/syncthing";
      openDefaultPorts = true;
    };
  };
}
