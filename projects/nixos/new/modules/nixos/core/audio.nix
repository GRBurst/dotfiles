{
  config,
  lib,
  ...
}: let
  cfg = config.my.nixos.core.audio;
in {
  options.my.nixos.core.audio.enable = lib.mkEnableOption "Audio (Pipewire)";

  config = lib.mkIf cfg.enable {
    services.pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
    };
    services.pulseaudio.enable = lib.mkDefault false;
    security.rtkit.enable = true;
  };
}
