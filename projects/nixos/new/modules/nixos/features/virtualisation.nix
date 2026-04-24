{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.nixos.features.virtualisation;
in {
  options.my.nixos.features.virtualisation.enable = lib.mkEnableOption "Virtualization Stack";

  config = lib.mkIf cfg.enable {
    virtualisation.docker = {
      enable = true;
      enableOnBoot = false;
      daemon.settings = {
        "insecure-registries" = ["127.0.0.1:5000" "gitlab-ci-local-registry:5000"];
      };
    };

    virtualisation.libvirtd.enable = true;

    virtualisation.virtualbox.host = {
      enable = false; # Config had this false, but extension pack true. Keeping strictly as source.
      enableExtensionPack = true;
    };
  };
}
