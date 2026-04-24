{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: {
  nixpkgs.config.allowUnfree = true;

  # nixpkgs.overlays = [
  #   inputs.wired.overlays.default
  # ];

  system.autoUpgrade.enable = true;

  environment.systemPackages = [pkgs.alejandra];
}
