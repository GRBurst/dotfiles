{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.my.nixos.features.stylix;
in {
  options.my.nixos.features.stylix.enable = lib.mkEnableOption "Stylix Theming";

  config = lib.mkIf cfg.enable {
    stylix = {
      enable = true;
      autoEnable = false;

      # Target specific apps
      targets = {
        console.enable = true;
        # dunst.enable = true; # Referenced in comments
      };

      base16Scheme = {
        base00 = "222436"; # bg
        base01 = "2f334d"; # bg_highlight
        base02 = "2d3f76"; # bg_visual
        base03 = "636da6"; # comment
        base04 = "828bb8"; # fg_dark
        base05 = "c8d3f5"; # fg
        base06 = "c8d3f5"; # fg (reused)
        base07 = "c8d3f5"; # terminal.white_bright
        base08 = "ff757f"; # red
        base09 = "ff966c"; # orange
        base0A = "ffc777"; # yellow
        base0B = "c3e88d"; # green
        base0C = "86e1fc"; # cyan
        base0D = "82aaff"; # blue
        base0E = "c099ff"; # magenta
        base0F = "4fd6be"; # teal
      };

      fonts = let
        f = config.my.nixos.features.fonts.families;
      in {
        monospace = {
          package = f.monospace.package;
          name = f.monospace.name;
        };
        sansSerif = {
          package = f.sansSerif.package;
          name = f.sansSerif.name;
        };
        serif = {
          package = f.serif.package;
          name = f.serif.name;
        };
      };
    };
  };
}
