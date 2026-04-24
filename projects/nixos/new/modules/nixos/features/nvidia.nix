{
  config,
  lib,
  ...
}: let
  cfg = config.my.nixos.features.nvidia;
in {
  options.my.nixos.features.nvidia.enable = lib.mkEnableOption "NVIDIA GPU support";

  config = lib.mkIf cfg.enable {
    hardware.nvidia = {
      open = true;
      nvidiaSettings = true;
    };
    hardware.graphics.enable = true;
    my.nixos.features.desktop.xserver.videoDrivers = lib.mkForce ["nvidia"];
    assertions = [
      {
        assertion = lib.elem "nvidia" config.services.xserver.videoDrivers;
        message = "my.nixos.features.nvidia requires videoDrivers to contain \"nvidia\".";
      }
    ];
  };
}
