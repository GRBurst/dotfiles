{
  config,
  lib,
  ...
}: let
  cfg = config.my.nixos.core.input;
in {
  options.my.nixos.core.input.enable = lib.mkEnableOption "Input Devices";

  config = lib.mkIf cfg.enable {
    services.libinput = {
      enable = true;
      touchpad = {
        scrollMethod = "twofinger";
        disableWhileTyping = true;
        tapping = false;
      };
    };
  };
}
