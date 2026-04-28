{
  self,
  pkgs,
  lib,
  inputs,
}: let
  andromedaSystem = self.nixosConfigurations.andromeda;
  earthSystem = self.nixosConfigurations.earth;
  andromeda = andromedaSystem.config;
  earth = earthSystem.config;

  mkHost = hostModule: extraModules:
    inputs.nixpkgs.lib.nixosSystem {
      system = "x86_64-linux";
      specialArgs = {inherit inputs;};
      modules =
        [
          inputs.stylix.nixosModules.stylix
          hostModule
          inputs.nix-snapd.nixosModules.default
          inputs.home-manager.nixosModules.home-manager
          ../modules/nixos
        ]
        ++ extraModules;
    };

  andromedaNoMaster = mkHost ../hosts/andromeda [
    {my.nixos.core.nixpkgs.masterPackages.enable = false;}
  ];

  masterPkgs = import inputs.nixpkgs-master {
    system = "x86_64-linux";
    config = andromedaNoMaster.config.nixpkgs.config;
  };

  pallonHome = andromeda.home-manager.users.pallon;
  i3ConfigText = pallonHome.xdg.configFile."i3/config".text;
  i3ConfigFiles = builtins.attrValues pallonHome.xdg.configFile;
  autorandrProfiles = pallonHome.programs.autorandr.profiles;

  enabledOutputs = profile:
    lib.filterAttrs (_: output: output.enable or false) profile.config;

  enabledPrimaryOutputs = profile:
    lib.filterAttrs (_: output: (output.enable or false) && (output.primary or false)) profile.config;

  hasExactlyOneEnabledPrimary = profile:
    builtins.length (builtins.attrNames (enabledPrimaryOutputs profile)) == 1;

  hasOneOrTwoEnabledOutputs = profile: let
    n = builtins.length (builtins.attrNames (enabledOutputs profile));
  in
    n >= 1 && n <= 2;

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

  font-package-consistency = mkAssertionCheck "font-package-consistency" [
    {
      condition =
        andromeda.my.nixos.features.fonts.families.monospace.package
        == pkgs.nerd-fonts.jetbrains-mono;
      message = "andromeda: monospace font package must be nerd-fonts.jetbrains-mono";
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

  fontconfig-defaults = mkAssertionCheck "fontconfig-defaults" [
    {
      condition =
        builtins.elem
        "JetBrainsMono Nerd Font Mono"
        andromeda.fonts.fontconfig.defaultFonts.monospace;
      message = "andromeda: fontconfig monospace must include configured font";
    }
    {
      condition =
        builtins.elem
        "DejaVu Sans"
        andromeda.fonts.fontconfig.defaultFonts.sansSerif;
      message = "andromeda: fontconfig sansSerif must include configured font";
    }
    {
      condition =
        builtins.elem
        "DejaVu Serif"
        andromeda.fonts.fontconfig.defaultFonts.serif;
      message = "andromeda: fontconfig serif must include configured font";
    }
  ];

  i3-config = mkAssertionCheck "i3-config" [
    {
      condition = pallonHome.my.hm.features.i3.enable == true;
      message = "andromeda: i3 feature must be enabled for pallon";
    }
    {
      condition = !(lib.hasInfix "include ~/.config/i3/display-config" i3ConfigText);
      message = "andromeda: i3 config must not include display-config file";
    }
    {
      condition = !(pallonHome.home.activation ? createI3DisplayConfig);
      message = "andromeda: Home Manager activation must not create i3 display-config";
    }
    {
      condition = !(pallonHome.xdg.configFile ? "i3/scripts/write-display-config.sh");
      message = "andromeda: write-display-config.sh must not be deployed";
    }
    {
      condition = !(lib.hasInfix "include ~/.config/i3/outputs" i3ConfigText);
      message = "andromeda: i3 config must not include stale outputs file";
    }
    {
      condition = lib.hasInfix "set $mod Mod4" i3ConfigText;
      message = "andromeda: i3 config must define $mod";
    }
    {
      condition = lib.hasInfix ''workspace "1: mail" output primary'' i3ConfigText;
      message = "andromeda: i3 config must assign workspace 1 to primary";
    }
    {
      condition = lib.hasInfix ''workspace "11: terminal" output nonprimary primary'' i3ConfigText;
      message = "andromeda: i3 config must assign workspace 11 to nonprimary primary";
    }
    {
      condition = lib.hasInfix "bar {" i3ConfigText;
      message = "andromeda: i3 config must include static bar";
    }
    {
      condition = lib.hasInfix "output primary" i3ConfigText;
      message = "andromeda: i3 config must use primary output alias";
    }
    {
      condition = lib.hasInfix "output nonprimary" i3ConfigText;
      message = "andromeda: i3 config must use nonprimary output alias";
    }
    {
      condition = lib.hasInfix "i3status-rs" i3ConfigText;
      message = "andromeda: i3 config must reference i3status-rs";
    }
    {
      condition =
        builtins.all
        (file: let
          text = file.text or null;
        in
          text == null || (!(lib.hasInfix "$OUT" text) && !(lib.hasInfix "$OUT2" text)))
        i3ConfigFiles;
      message = "andromeda: deployed i3 config text must not contain $OUT or $OUT2";
    }
    {
      condition = lib.hasInfix "exec --no-startup-id nm-applet" i3ConfigText;
      message = "andromeda: i3 config must contain nm-applet startup";
    }
    {
      condition = lib.hasInfix "exec --no-startup-id cbatticon" i3ConfigText;
      message = "andromeda: i3 config must contain cbatticon startup";
    }
    {
      condition = pallonHome.xdg.configFile."i3/scripts/i3scripts.sh".executable == true;
      message = "andromeda: i3scripts.sh must be executable";
    }
    {
      condition = pallonHome.xdg.configFile ? "i3status-rust/config.toml";
      message = "andromeda: i3status-rust config must be deployed";
    }
    {
      condition = lib.hasInfix ''theme = "slick"'' pallonHome.xdg.configFile."i3status-rust/config.toml".text;
      message = "andromeda: i3status-rust must use slick theme";
    }
    {
      condition = lib.hasInfix ''device = "enp2s0f0"'' pallonHome.xdg.configFile."i3status-rust/config.toml".text;
      message = "andromeda: i3status-rust must include ethernet device";
    }
    {
      condition = lib.hasInfix ''device = "wlp3s0"'' pallonHome.xdg.configFile."i3status-rust/config.toml".text;
      message = "andromeda: i3status-rust must include wifi device";
    }
  ];

  i3-statusbar-path = mkAssertionCheck "i3-statusbar-path" [
    {
      condition =
        builtins.any
        (p: (p.pname or p.name or "") == "i3status-rust")
        andromeda.home-manager.users.pallon.home.packages;
      message = "andromeda: i3status-rust must be in pallon home.packages";
    }
  ];

  i3-autorandr = mkAssertionCheck "i3-autorandr" [
    {
      condition = pallonHome.programs.autorandr.enable == true;
      message = "andromeda: autorandr must be enabled for pallon";
    }
    {
      condition = autorandrProfiles ? "laptop";
      message = "andromeda: autorandr must have laptop profile";
    }
    {
      condition = autorandrProfiles ? "docked";
      message = "andromeda: autorandr must have docked profile";
    }
    {
      condition =
        builtins.all
        hasOneOrTwoEnabledOutputs
        (builtins.attrValues autorandrProfiles);
      message = "andromeda: every autorandr profile must enable one or two outputs";
    }
    {
      condition =
        builtins.all
        hasExactlyOneEnabledPrimary
        (builtins.attrValues autorandrProfiles);
      message = "andromeda: every autorandr profile must have exactly one enabled primary output";
    }
    {
      condition =
        builtins.all
        (profile: !(lib.hasInfix "write-display-config.sh" profile.hooks.postswitch))
        (builtins.attrValues autorandrProfiles);
      message = "andromeda: autorandr postswitch hooks must not call write-display-config.sh";
    }
    {
      condition =
        builtins.all
        (profile: lib.hasInfix "i3-msg reload" profile.hooks.postswitch)
        (builtins.attrValues autorandrProfiles);
      message = "andromeda: every autorandr postswitch hook must reload i3";
    }
    {
      condition = lib.hasInfix "/bin/i3-msg reload" autorandrProfiles.docked.hooks.postswitch;
      message = "andromeda: docked postswitch must reload i3";
    }
    {
      condition = lib.hasInfix "i3-msg reload" autorandrProfiles.laptop.hooks.postswitch;
      message = "andromeda: laptop postswitch must reload i3";
    }
  ];

  i3-syntax = pkgs.runCommand "i3-syntax" {} ''
    export XDG_RUNTIME_DIR="$TMPDIR"
    configFile=${pkgs.writeText "andromeda-i3-config" i3ConfigText}
    ${pkgs.i3}/bin/i3 -C -c "$configFile"
    touch "$out"
  '';

  autorandr-gamma = mkAssertionCheck "autorandr-gamma" [
    {
      condition =
        andromeda.home-manager.users.pallon.programs.autorandr.profiles.laptop.config."eDP-1"
        ? gamma;
      message = "andromeda: autorandr laptop eDP-1 must have gamma";
    }
    {
      condition =
        andromeda.home-manager.users.pallon.programs.autorandr.profiles.docked.config."DP-4"
        ? gamma;
      message = "andromeda: autorandr docked DP-4 must have gamma";
    }
    {
      condition =
        andromeda.home-manager.users.pallon.programs.autorandr.profiles.docked.config."DP-3"
        ? gamma;
      message = "andromeda: autorandr docked DP-3 must have gamma";
    }
  ];

  dictate-module = mkAssertionCheck "dictate-module" [
    {
      condition =
        andromeda.home-manager.users.pallon.my.hm.features.dictate.enable == false;
      message = "andromeda: dictate feature must be importable and default to disabled";
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

  master-package-defaults = mkAssertionCheck "master-package-defaults" [
    {
      condition = andromedaSystem.pkgs.codex.version == masterPkgs.codex.version;
      message = "andromeda: codex must come from nixpkgs-master by default";
    }
    {
      condition = andromedaSystem.pkgs.claude-code.version == masterPkgs.claude-code.version;
      message = "andromeda: claude-code must come from nixpkgs-master by default";
    }
    {
      condition =
        builtins.any
        (p: (p.pname or p.name or "") == "codex")
        andromeda.home-manager.users.pallon.home.packages;
      message = "andromeda: codex must remain in pallon home.packages";
    }
    {
      condition =
        builtins.any
        (p: (p.pname or p.name or "") == "claude-code")
        andromeda.home-manager.users.pallon.home.packages;
      message = "andromeda: claude-code must remain in pallon home.packages";
    }
  ];

  master-package-opt-out = mkAssertionCheck "master-package-opt-out" [
    {
      condition = andromedaNoMaster.config.my.nixos.core.nixpkgs.masterPackages.enable == false;
      message = "opt-out fixture: masterPackages.enable must be false";
    }
    {
      condition = andromedaNoMaster.pkgs.codex.version != masterPkgs.codex.version;
      message = "opt-out fixture: codex must fall back to base nixpkgs when disabled";
    }
    {
      condition = andromedaNoMaster.pkgs.claude-code.version != masterPkgs.claude-code.version;
      message = "opt-out fixture: claude-code must fall back to base nixpkgs when disabled";
    }
  ];
}
