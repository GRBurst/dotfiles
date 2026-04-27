{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.nixos.features.fonts;
in {
  options.my.nixos.features.fonts = {
    enable = lib.mkEnableOption "Fonts";

    families = {
      monospace = {
        package = lib.mkPackageOption pkgs "monospace font" {default = ["nerd-fonts" "noto"];};
        name = lib.mkOption {
          type = lib.types.str;
          default = "JetBrainsMono Nerd Font Mono";
        };
      };
      sansSerif = {
        package = lib.mkPackageOption pkgs "sans-serif font" {default = ["dejavu_fonts"];};
        name = lib.mkOption {
          type = lib.types.str;
          default = "DejaVu Sans";
        };
      };
      serif = {
        package = lib.mkPackageOption pkgs "serif font" {default = ["dejavu_fonts"];};
        name = lib.mkOption {
          type = lib.types.str;
          default = "DejaVu Serif";
        };
      };
    };

    sizes = {
      terminal = lib.mkOption {
        type = lib.types.int;
        default = 12;
      };
      notification = {
        title = lib.mkOption {
          type = lib.types.int;
          default = 16;
        };
        body = lib.mkOption {
          type = lib.types.int;
          default = 14;
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    fonts = {
      enableDefaultPackages = true;
      packages =
        (with pkgs; [
          corefonts
          dejavu_fonts
          google-fonts
          liberation_ttf
          powerline-fonts
          ubuntu-classic
          symbola
          font-awesome
          nerd-fonts.symbols-only
        ])
        ++ [
          cfg.families.monospace.package
          cfg.families.sansSerif.package
          cfg.families.serif.package
        ];
    };
  };
}
