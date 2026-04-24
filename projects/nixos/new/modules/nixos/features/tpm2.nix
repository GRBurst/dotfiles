{
  config,
  lib,
  ...
}: let
  cfg = config.my.nixos.features.tpm2;
in {
  options.my.nixos.features.tpm2.enable = lib.mkEnableOption "TPM 2.0 support";

  config = lib.mkIf cfg.enable {
    security.tpm2 = {
      enable = true;
      pkcs11.enable = true;
      tctiEnvironment.enable = true;
    };
  };
}
