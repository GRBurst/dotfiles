{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.nixos.core.user;
  enabledUsers = lib.filterAttrs (_: u: u.enable) cfg.users;
  primaries = lib.filterAttrs (_: u: u.isPrimary) enabledUsers;
  primaryName =
    if primaries == {}
    then null
    else lib.head (lib.attrNames primaries);
in {
  options.my.nixos.core.user = {
    users = lib.mkOption {
      type = lib.types.attrsOf (lib.types.submodule ({name, ...}: {
        options = {
          enable = lib.mkEnableOption "NixOS user ${name}";
          extraGroups = lib.mkOption {
            type = with lib.types; listOf str;
            default = [];
          };
          shell = lib.mkOption {
            type = lib.types.package;
            default = pkgs.zsh;
          };
          authorizedKeys = lib.mkOption {
            type = with lib.types; listOf str;
            default = [];
          };
          trusted = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
          isPrimary = lib.mkOption {
            type = lib.types.bool;
            default = false;
          };
        };
      }));
      default = {};
      description = "Attrset of NixOS users. Exactly one must have isPrimary = true when non-empty.";
    };
    primary = lib.mkOption {
      type = with lib.types; nullOr str;
      default = primaryName;
      readOnly = true;
      description = "Derived name of the primary user, or null when no users are enabled.";
    };
  };

  config = lib.mkIf (enabledUsers != {}) {
    users.users =
      lib.mapAttrs (_: u: {
        isNormalUser = true;
        inherit (u) extraGroups shell;
        openssh.authorizedKeys.keys = u.authorizedKeys;
      })
      enabledUsers;

    programs.zsh.enable = true;

    nix.settings.trusted-users =
      lib.mapAttrsToList (n: _: n)
      (lib.filterAttrs (_: u: u.trusted) enabledUsers);

    assertions = [
      {
        assertion = lib.length (lib.attrNames primaries) == 1;
        message = "my.nixos.core.user.users: exactly one enabled user must have isPrimary = true; found ${toString (lib.length (lib.attrNames primaries))}.";
      }
    ];
  };
}
