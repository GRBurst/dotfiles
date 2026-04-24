{
  config,
  lib,
  ...
}: let
  cfg = config.my.nixos.services.ssh;
in {
  options.my.nixos.services.ssh = {
    enable = lib.mkEnableOption "SSH Server";
    extraSettings = lib.mkOption {
      type = lib.types.attrs;
      default = {};
      description = "Extra key/value pairs merged into services.openssh.settings.";
    };
  };

  config = lib.mkIf cfg.enable {
    services.openssh = {
      enable = true;
      ports = [53292];
      settings = cfg.extraSettings;
    };
  };
}
