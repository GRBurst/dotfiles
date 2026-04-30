{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.my.nixos.core.nixpkgs;
  system = pkgs.stdenv.hostPlatform.system;

  masterPkgs = import inputs.nixpkgs-master {
    inherit system;
    config = config.nixpkgs.config;
  };

  selected = cfg.masterPackages.packageNames;

  masterOverlay = final: prev:
    lib.genAttrs selected (name: masterPkgs.${name});

  mkPkgAssertion = name: {
    assertion = builtins.hasAttr name pkgs && builtins.hasAttr name masterPkgs;
    message = "masterPackages: package `${name}` must exist in both base pkgs and nixpkgs-master";
  };
in {
  options.my.nixos.core.nixpkgs.masterPackages = {
    enable = lib.mkEnableOption "use nixpkgs/master for selected packages" // {default = true;};

    packageNames = lib.mkOption {
      type = with lib.types; listOf (enum ["codex" "claude-code"]);
      default = ["codex" "claude-code"];
      description = "Top-level package attrs sourced from nixpkgs/master.";
    };
  };

  config = {
    assertions = map mkPkgAssertion selected;

    nixpkgs.config.allowUnfree = true;

    nixpkgs.overlays = lib.mkIf cfg.masterPackages.enable [masterOverlay];

    system.autoUpgrade.enable = true;

    environment.systemPackages = [pkgs.alejandra];
  };
}
