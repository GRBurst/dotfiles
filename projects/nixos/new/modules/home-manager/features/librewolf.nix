{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.hm.features.librewolf;
in {
  options.my.hm.features.librewolf = {
    enable = lib.mkEnableOption "Declarative LibreWolf via Home Manager";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.librewolf-bin;
      description = ''
        LibreWolf package used by `programs.librewolf`. Defaults to the
        binary build to match the system-wide install and avoid long
        source compiles.
      '';
    };

    profileName = lib.mkOption {
      type = lib.types.str;
      default = "nix-managed";
      description = ''
        Name of the HM-owned LibreWolf profile. Distinct from any
        pre-existing `default` profile to keep the migration
        non-destructive and reversible.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.librewolf = {
      enable = true;
      package = cfg.package;
      # Keep pre nix-managed profile as fallback
      profiles.manual = {
        id = 0;
        path = "mi3lqq74.default";
        isDefault = false;
      };
      profiles.${cfg.profileName} = {
        id = 1;
        isDefault = true;
      };
    };
  };
}
