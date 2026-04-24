{
  config,
  lib,
  ...
}: let
  cfg = config.my.hm.features.shellAliases;
in {
  options.my.hm.features.shellAliases = {
    enable = lib.mkEnableOption "Cross-shell aliases (zsh/bash/fish)";
    aliases = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = {
        l = "ls -l";
        t = "tree -C";
        vn = "nvim /etc/nixos/configuration.nix";
      };
      description = "Aliases propagated via home.shellAliases.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Use mkDefault so richer shell-specific modules (e.g. features/zsh.nix)
    # can override individual aliases with identical or more specific values.
    home.shellAliases = lib.mapAttrs (_: lib.mkDefault) cfg.aliases;
  };
}
