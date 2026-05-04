{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.nixos.features.style;
  style = import ../../lib/style {inherit lib;};
  palettes = style.palettes.${cfg.palette};
  fontCfg = config.my.nixos.features.fonts.families;
in {
  options.my.nixos.features.style = {
    enable = lib.mkEnableOption "shared style architecture";

    palette = lib.mkOption {
      type = lib.types.enum ["enfocado"];
      default = "enfocado";
      description = "Canonical palette family.";
    };

    defaultMode = lib.mkOption {
      type = lib.types.enum ["light" "dark"];
      default = "light";
      description = "Initial mode used for declarative fallback artifacts.";
    };

    stylixMigration.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Keep Stylix enabled as a migration backend.";
    };
  };

  config = lib.mkIf cfg.enable {
    stylix = lib.mkIf cfg.stylixMigration.enable {
      enable = true;
      autoEnable = true;

      # Console always uses dark palette for boot readability:
      # 256-color gray maps to #b9b9b9 on #181818 (~9:1 contrast, WCAG AAA).
      base16Scheme = style.toBase16 palettes.dark;

      targets = {
        console.enable = true;
        qt.enable      = false;
      };

      fonts = {
        monospace = {
          package = fontCfg.monospace.package;
          name = fontCfg.monospace.name;
        };
        sansSerif = {
          package = fontCfg.sansSerif.package;
          name = fontCfg.sansSerif.name;
        };
        serif = {
          package = fontCfg.serif.package;
          name = fontCfg.serif.name;
        };
      };
    };

    xdg.portal = {
      extraPortals = [pkgs.darkman];
      config.common."org.freedesktop.impl.portal.Settings" = "darkman";
    };
  };
}
