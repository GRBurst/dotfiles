{
  config,
  lib,
  ...
}: let
  cfg = config.my.nixos.core.caches;
in {
  options.my.nixos.core.caches = {
    enable = lib.mkEnableOption "Shared binary caches (substituters + trusted keys)";
    extraSubstituters = lib.mkOption {
      type = with lib.types; listOf str;
      default = [];
      description = "Host-specific extra substituters appended to the shared set.";
    };
    extraTrustedPublicKeys = lib.mkOption {
      type = with lib.types; listOf str;
      default = [];
      description = "Host-specific trusted public keys appended to the shared set.";
    };
  };

  config = lib.mkIf cfg.enable {
    nix.settings = {
      substituters =
        [
          "https://cache.nixos.org/"
          "https://nix-community.cachix.org"
          "https://hyprland.cachix.org"
        ]
        ++ cfg.extraSubstituters;

      trusted-public-keys =
        [
          "cache.nixos.org-1:6NCHdD59X431o0gWypbMrAURkbJ16ZPMQFGspcDShjY="
          "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
          "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
        ]
        ++ cfg.extraTrustedPublicKeys;
    };
  };
}
