{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.nixos.features.fonts;
in {
  options.my.nixos.features.fonts.enable = lib.mkEnableOption "Fonts";

  config = lib.mkIf cfg.enable {
    fonts = {
      enableDefaultPackages = true;
      packages = with pkgs; [
        corefonts
        dejavu_fonts
        google-fonts
        liberation_ttf
        powerline-fonts
        ubuntu-classic
        symbola
        font-awesome
        nerd-fonts.symbols-only
      ];
    };
  };
}
