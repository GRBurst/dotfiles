{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.nixos.features.ai;
in {
  options.my.nixos.features.ai = {
    enable = lib.mkEnableOption "Local AI Stack";
    ollamaPackage = lib.mkOption {
      type = lib.types.package;
      default = pkgs.ollama;
      description = "Package providing the ollama server (use pkgs.ollama-cuda on CUDA hosts).";
    };
    openWebuiPort = lib.mkOption {
      type = lib.types.port;
      default = 48480;
    };
  };

  config = lib.mkIf cfg.enable {
    services.ollama = {
      enable = true;
      package = cfg.ollamaPackage;
    };
    services.qdrant.enable = true;
    # open-webui pulls in the python torch / faster-whisper / piper-tts chain, which is
    # not covered by public caches. Re-enable once a personal cache warms them.
    # services.open-webui = {
    #   enable = true;
    #   port = cfg.openWebuiPort;
    # };
  };
}
