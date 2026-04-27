{
  self,
  pkgs,
  lib,
}: let
  andromeda = self.nixosConfigurations.andromeda.config;
  earth = self.nixosConfigurations.earth.config;

  mkAssertionCheck = name: assertions:
    pkgs.runCommand name {} ''
      ${lib.concatMapStringsSep "\n" (assertion: ''
          if [ "${
            if assertion.condition
            then "1"
            else "0"
          }" != "1" ]; then
            echo ${lib.escapeShellArg assertion.message} >&2
            exit 1
          fi
        '')
        assertions}
      touch "$out"
    '';
in {
  nvf-config = mkAssertionCheck "nvf-config" [
    {
      condition = andromeda.home-manager.users.pallon.my.hm.features.nvf.enable == true;
      message = "andromeda: nvf feature must be enabled for pallon";
    }
    {
      condition = andromeda.home-manager.users.pallon.programs.nvf.enable == true;
      message = "andromeda: programs.nvf must be enabled for pallon";
    }
    {
      condition = andromeda.home-manager.users.pallon.programs.nvf.settings.vim.theme.name == "gruvbox";
      message = "andromeda: nvf theme must be gruvbox";
    }
  ];

  font-options = mkAssertionCheck "font-options" [
    {
      condition = andromeda.my.nixos.features.fonts.families.monospace.name == "JetBrainsMono Nerd Font Mono";
      message = "andromeda: monospace font name must default to JetBrainsMono Nerd Font Mono";
    }
    {
      condition = andromeda.my.nixos.features.fonts.families.sansSerif.name == "DejaVu Sans";
      message = "andromeda: sansSerif font name must default to DejaVu Sans";
    }
    {
      condition = andromeda.my.nixos.features.fonts.families.serif.name == "DejaVu Serif";
      message = "andromeda: serif font name must default to DejaVu Serif";
    }
    {
      condition = andromeda.my.nixos.features.fonts.sizes.terminal == 12;
      message = "andromeda: terminal font size must default to 12";
    }
    {
      condition = andromeda.my.nixos.features.fonts.sizes.notification.title == 16;
      message = "andromeda: notification title size must default to 16";
    }
    {
      condition = andromeda.my.nixos.features.fonts.sizes.notification.body == 14;
      message = "andromeda: notification body size must default to 14";
    }
  ];

  font-propagation = mkAssertionCheck "font-propagation" [
    {
      condition = andromeda.stylix.fonts.monospace.name == andromeda.my.nixos.features.fonts.families.monospace.name;
      message = "andromeda: stylix monospace must match central font definition";
    }
    {
      condition = andromeda.stylix.fonts.sansSerif.name == andromeda.my.nixos.features.fonts.families.sansSerif.name;
      message = "andromeda: stylix sansSerif must match central font definition";
    }
    {
      condition = andromeda.stylix.fonts.serif.name == andromeda.my.nixos.features.fonts.families.serif.name;
      message = "andromeda: stylix serif must match central font definition";
    }
    {
      condition = earth.stylix.fonts.monospace.name == earth.my.nixos.features.fonts.families.monospace.name;
      message = "earth: stylix monospace must match central font definition";
    }
    {
      condition = earth.stylix.fonts.sansSerif.name == earth.my.nixos.features.fonts.families.sansSerif.name;
      message = "earth: stylix sansSerif must match central font definition";
    }
    {
      condition = earth.stylix.fonts.serif.name == earth.my.nixos.features.fonts.families.serif.name;
      message = "earth: stylix serif must match central font definition";
    }
    {
      condition = andromeda.home-manager.users.pallon.programs.kitty.font.name == andromeda.my.nixos.features.fonts.families.monospace.name;
      message = "andromeda: kitty font must match central monospace definition";
    }
    {
      condition = earth.home-manager.users.jelias.programs.kitty.font.name == earth.my.nixos.features.fonts.families.monospace.name;
      message = "earth: kitty font must match central monospace definition";
    }
    {
      condition = andromeda.home-manager.users.pallon.programs.alacritty.settings.font.normal.family == andromeda.my.nixos.features.fonts.families.monospace.name;
      message = "andromeda: alacritty font must match central monospace definition";
    }
    {
      condition = earth.home-manager.users.jelias.programs.alacritty.settings.font.normal.family == earth.my.nixos.features.fonts.families.monospace.name;
      message = "earth: alacritty font must match central monospace definition";
    }
  ];

  lookup-ownership = mkAssertionCheck "lookup-ownership" [
    {
      condition = andromeda.programs.command-not-found.enable == false;
      message = "andromeda: system-level command-not-found must be disabled";
    }
    {
      condition = andromeda.programs.nix-index.enable == false;
      message = "andromeda: system-level nix-index must be disabled";
    }
    {
      condition = andromeda.home-manager.users.pallon.programs.nix-index.enable == true;
      message = "andromeda: Home Manager nix-index must stay enabled for pallon";
    }
    {
      condition = earth.programs.command-not-found.enable == false;
      message = "earth: system-level command-not-found must be disabled";
    }
    {
      condition = earth.programs.nix-index.enable == false;
      message = "earth: system-level nix-index must be disabled";
    }
    {
      condition = earth.home-manager.users.jelias.programs.nix-index.enable == true;
      message = "earth: Home Manager nix-index must stay enabled for jelias";
    }
  ];
}
