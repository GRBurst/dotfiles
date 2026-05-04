{ pkgs, lib, self, ... }:
let
  osCfg   = self.nixosConfigurations.earth.config;
  hmCfg   = osCfg.home-manager.users.jelias;
  expect  = label: e: a:
    if e == a then null
    else throw "stylix mismatch ${label}: expected ${toString e}, got ${toString a}";
  vt0  = builtins.elemAt osCfg.console.colors 0;
  vt7  = builtins.elemAt osCfg.console.colors 7;
  vt15 = builtins.elemAt osCfg.console.colors 15;
in
pkgs.runCommand "check-stylix" {} ''
  ${builtins.toString (lib.filter (x: x != null) [
    (expect "autoEnable"               true    osCfg.stylix.autoEnable)
    (expect "console VT0 (dark bg_0)"  "181818" vt0)
    (expect "console VT7 (dark fg_0)"  "b9b9b9" vt7)
    (expect "console VT15 (dark fg_1)" "dedede" vt15)
    (expect "alacritty opt-out" false hmCfg.stylix.targets.alacritty.enable)
    (expect "kitty opt-out"     false hmCfg.stylix.targets.kitty.enable)
    (expect "rofi opt-out"      false hmCfg.stylix.targets.rofi.enable)
    (expect "i3 opt-out"        false hmCfg.stylix.targets.i3.enable)
    (expect "hyprland opt-out"  false hmCfg.stylix.targets.hyprland.enable)
    (expect "waybar opt-out"    false hmCfg.stylix.targets.waybar.enable)
  ])}
  touch $out
''
