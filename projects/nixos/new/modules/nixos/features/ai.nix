{ config, lib, pkgs, ... }:
let cfg = config.my.nixos.features.ai;
in {
  options.my.nixos.features.ai.enable = lib.mkEnableOption "Local AI Stack";

  config = lib.mkIf cfg.enable {
    services.ollama.enable = true;
    services.qdrant.enable = true;
    services.open-webui = {
      enable = true;
      port = 48480;
    };
  };
}
