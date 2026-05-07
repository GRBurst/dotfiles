{
  pkgs,
  lib,
  ...
}: let
  style = import ../../modules/lib/style {inherit lib;};
  light = (import ../../modules/lib/style/enfocado.nix).light;
  dark = (import ../../modules/lib/style/enfocado.nix).dark;
  rofi = style.mkRofiTheme light;
  wofi = style.mkWofiCss light;
  hypr = style.mkHyprlandTheme dark;
  dunst = style.mkDunstConfig light {
    families.sansSerif.name = "X";
    sizes.notification.body = 11;
  };
  contains = needle: hay:
    if lib.hasInfix needle hay
    then null
    else throw "template missing literal: ${needle}";
in
  pkgs.runCommand "check-templates" {} ''
    ${builtins.toString (lib.filter (x: x != null) [
      (contains "muted: #878787" rofi)
      (contains "element selected {\n  background-color: @accent;" rofi)
      (contains "element-text, element-icon {\n  background-color: transparent;\n  text-color: inherit;" rofi)
      (contains "#entry:selected {\n  background-color: #0064e4;" wofi)
      (contains "rgba(368aebee)" hypr)
      (contains "rgba(a580e2ee)" hypr)
      (contains "rgba(3b3b3baa)" hypr)
      (contains "frame_color = \"#d04a00\"" dunst)
    ])}
    touch $out
  ''
