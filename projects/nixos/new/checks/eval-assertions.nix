{
  self,
  pkgs,
  lib,
  inputs,
}: let
  cfgs = self.nixosConfigurations;
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
  jeliasHome = earth.home-manager.users.jelias;
  pallonFiles = pallonHome.xdg.configFile or {};
  jeliasFiles = jeliasHome.xdg.configFile or {};
  pallonDarkmanScript = pallonHome.services.darkman.scripts."theme-dispatch" or "";
  styleSwitchText = pallonHome.my.hm.features.style.dispatcher.package.text or "";
  pallonDarkmanDataScript =
    if pallonHome.xdg.dataFile ? "darkman/theme-dispatch"
    then builtins.readFile pallonHome.xdg.dataFile."darkman/theme-dispatch".source
    else "";
  jeliasDarkmanScript = jeliasHome.services.darkman.scripts."theme-dispatch" or "";
  pallonI3StatusText = pallonFiles."i3status-rust/config.toml".text or "";
  pallonI3StatusThemePath = "${pallonHome.xdg.configHome}/my/theme/current/i3status-rust.toml";
  jeliasI3StatusThemePath = "${jeliasHome.xdg.configHome}/my/theme/current/i3status-rust.toml";
  pallonRofiConfigText = pallonHome.home.file."${pallonHome.programs.rofi.configPath}".text or "";
  i3ConfigText = pallonHome.xdg.configFile."i3/config".text;
  i3ConfigFiles = builtins.attrValues pallonHome.xdg.configFile;
  dunstCommand = "dunst -config ~/.config/my/theme/current/dunst.conf";
  pallonDunstCurrentText = pallonFiles."my/theme/current/dunst.conf".text or "";
  pallonI3ThemeText = pallonFiles."my/theme/current/i3.conf".text or "";
  pallonI3LightThemeText = pallonFiles."my/theme/i3/light.conf".text or "";
  pallonI3DarkThemeText = pallonFiles."my/theme/i3/dark.conf".text or "";
  earthFiles = jeliasHome.xdg.configFile or {};
  earthI3ThemeText = earthFiles."my/theme/current/i3.conf".text or "";
  earthI3ConfigText = earthFiles."i3/config".text or "";
  earthI3StatusText = earthFiles."i3status-rust/config.toml".text or "";
  pallonActivation = pallonHome.home.activation or {};
  pallonNvfLua = pallonHome.programs.nvf.settings.vim.luaConfigRC.custom-functions.data or "";
  jeliasNvfLua = jeliasHome.programs.nvf.settings.vim.luaConfigRC.custom-functions.data or "";
  autorandrProfiles = pallonHome.programs.autorandr.profiles;
  bingWallpaperTestHome = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      ../modules/home-manager/features/bing-wallpaper.nix
      {
        home = {
          username = "bing-test";
          homeDirectory = "/tmp/bing-test";
          stateVersion = "25.11";
        };

        my.hm.features.bingWallpaper = {
          enable = true;
          count = 2;
          preferUhd = false;
          setter = {
            packages = [];
            command = ''printf '%s\n' "$@" > "$BING_WALLPAPER_TEST_OUT"'';
          };
        };
      }
    ];
  };
  bingWallpaperTestPackage = bingWallpaperTestHome.config.my.hm.features.bingWallpaper.package;
  bingWallpaperNasaTestHome = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    modules = [
      ../modules/home-manager/features/bing-wallpaper.nix
      {
        home = {
          username = "bing-test";
          homeDirectory = "/tmp/bing-test";
          stateVersion = "25.11";
        };

        my.hm.features.bingWallpaper = {
          enable = true;
          count = 2;
          preferUhd = false;
          nasaApod.enable = true;
          setter = {
            packages = [];
            command = ''printf '%s\n' "$@" > "$BING_WALLPAPER_TEST_OUT"'';
          };
        };
      }
    ];
  };
  bingWallpaperNasaTestPackage = bingWallpaperNasaTestHome.config.my.hm.features.bingWallpaper.package;
  bingWallpaperDefaultSetter = pkgs.writeShellScript "bing-wallpaper-default-setter" pallonHome.my.hm.features.bingWallpaper.setter.command;
  themeDocPath = ../docs/theme-architecture.md;
  themeDoc =
    if builtins.pathExists themeDocPath
    then builtins.readFile themeDocPath
    else "";
  flakeText = builtins.readFile ../flake.nix;
  hmDefaultText = builtins.readFile ../modules/home-manager/default.nix;
  andromedaHostText = builtins.readFile ../hosts/andromeda/default.nix;
  earthHostText = builtins.readFile ../hosts/earth/default.nix;
  wiredFeaturePath = ../modules/home-manager/features/wired.nix;

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

  mkCheck = name: cond: msg:
    mkAssertionCheck "check-${name}" [
      {
        condition = cond;
        message = msg;
      }
    ];

  librewolfTestHome = inputs.home-manager.lib.homeManagerConfiguration {
    inherit pkgs;
    extraSpecialArgs = {inherit inputs;};
    modules = [
      ../modules/home-manager/features/librewolf.nix
      {
        home.username = "lw-test";
        home.homeDirectory = "/tmp/lw-test";
        home.stateVersion = "25.11";
        my.hm.features.librewolf = {
          enable = true;
          package = pkgs.librewolf;
        };
      }
    ];
  };
  librewolfTest = librewolfTestHome.config;

  lwAndromedaNixpkgsCfg = andromeda.nixpkgs.config;
  lwAllowInsecurePred = lwAndromedaNixpkgsCfg.allowInsecurePredicate or (_: false);
  lwFakeBin = {pname = "librewolf-bin"; name = "librewolf-bin-999"; meta.knownVulnerabilities = ["x"];};
  lwFakeUnwrapped = {pname = "librewolf-bin-unwrapped"; name = "librewolf-bin-unwrapped-999"; meta.knownVulnerabilities = ["x"];};
  lwFakeOther = {pname = "unrelated-pkg"; name = "unrelated-pkg-1"; meta.knownVulnerabilities = ["x"];};
  lwHasExt = pkgList: n: builtins.any (p: lib.getName p == n) pkgList;
  lwAddons = inputs.firefox-addons.packages.${pkgs.stdenv.hostPlatform.system};
in {
  andromeda-syncthing-user =
    mkCheck "andromeda-syncthing-user"
    (cfgs.andromeda.config.services.syncthing.user == "pallon")
    "andromeda syncthing user must be pallon (backwards-compat)";

  earth-syncthing-user =
    mkCheck "earth-syncthing-user"
    (cfgs.earth.config.services.syncthing.user == "jelias")
    "earth syncthing user must be jelias";

  earth-video-nvidia =
    mkCheck "earth-video-nvidia"
    (lib.elem "nvidia" cfgs.earth.config.services.xserver.videoDrivers)
    "earth must use nvidia videoDriver";

  earth-dm-gdm =
    mkCheck "earth-dm-gdm"
    cfgs.earth.config.services.displayManager.gdm.enable
    "earth must use gdm";

  andromeda-dm-greetd =
    mkCheck "andromeda-dm-greetd"
    cfgs.andromeda.config.services.greetd.enable
    "andromeda must use greetd";

  andromeda-dm-sddm-disabled =
    mkCheck "andromeda-dm-sddm-disabled"
    (!cfgs.andromeda.config.services.displayManager.sddm.enable)
    "andromeda must not use sddm";

  andromeda-dm-gdm-disabled =
    mkCheck "andromeda-dm-gdm-disabled"
    (!cfgs.andromeda.config.services.displayManager.gdm.enable)
    "andromeda must not use gdm";

  andromeda-dm-default-session-null =
    mkCheck "andromeda-dm-default-session-null"
    (cfgs.andromeda.config.services.displayManager.defaultSession == null)
    "andromeda greetd must leave services.displayManager.defaultSession unset";

  andromeda-greetd-greeter-user =
    mkCheck "andromeda-greetd-greeter-user"
    (cfgs.andromeda.config.services.greetd.settings.default_session.user == "greeter")
    "andromeda greetd default_session must run as the greeter system user";

  andromeda-greetd-tuigreet-cmd = let
    cmd = cfgs.andromeda.config.services.greetd.settings.default_session.command;
  in
    mkAssertionCheck "check-andromeda-greetd-tuigreet-cmd" [
      {
        condition = lib.hasInfix "tuigreet" cmd;
        message = "andromeda greetd command must invoke tuigreet";
      }
      {
        condition = lib.hasInfix "--time" cmd;
        message = "andromeda tuigreet must pass --time";
      }
      {
        condition = lib.hasInfix "--remember" cmd;
        message = "andromeda tuigreet must pass --remember";
      }
      {
        condition = lib.hasInfix "--remember-session" cmd;
        message = "andromeda tuigreet must pass --remember-session";
      }
      {
        condition = lib.hasInfix "--sessions" cmd;
        message = "andromeda tuigreet must pass --sessions (prevents double-scan via XDG_DATA_DIRS)";
      }
      {
        condition = lib.hasInfix "--xsessions" cmd;
        message = "andromeda tuigreet must pass --xsessions (enables X11 session discovery for i3)";
      }
    ];

  andromeda-greetd-no-initial-session =
    mkCheck "andromeda-greetd-no-initial-session"
    (!(cfgs.andromeda.config.services.greetd.settings ? initial_session))
    "andromeda greetd must not auto-login (no initial_session) when autoLogin = false";

  earth-greetd-disabled =
    mkCheck "earth-greetd-disabled"
    (!cfgs.earth.config.services.greetd.enable)
    "earth must not enable greetd (regression — earth uses gdm)";

  earth-firewall-k3s = let
    ports = cfgs.earth.config.networking.firewall.allowedTCPPorts;
  in
    mkCheck "earth-firewall-k3s"
    (lib.elem 6443 ports && lib.elem 8080 ports)
    "earth firewall must open 6443 + 8080";

  earth-user-primary =
    mkCheck "earth-user-primary"
    (cfgs.earth.config.my.nixos.core.user.primary == "jelias")
    "earth primary user must be jelias";

  andromeda-user-primary =
    mkCheck "andromeda-user-primary"
    (cfgs.andromeda.config.my.nixos.core.user.primary == "pallon")
    "andromeda primary user must be pallon";

  earth-ssh-x11forwarding =
    mkCheck "earth-ssh-x11forwarding"
    (cfgs.earth.config.services.openssh.settings.X11Forwarding == true)
    "earth sshd must enable X11Forwarding";

  earth-ssh-passwordauth-off =
    mkCheck "earth-ssh-passwordauth-off"
    (cfgs.earth.config.services.openssh.settings.PasswordAuthentication == false)
    "earth sshd must disable password authentication";

  andromeda-ssh-passwordauth-default =
    mkCheck "andromeda-ssh-passwordauth-default"
    (cfgs.andromeda.config.services.openssh.settings.PasswordAuthentication == true)
    "andromeda sshd must keep its current password-auth default unchanged";

  earth-clamav-tcp =
    mkCheck "earth-clamav-tcp"
    (cfgs.earth.config.services.clamav.daemon.settings.TCPSocket == 3310)
    "earth clamav daemon must listen on TCP 3310";

  earth-pulseaudio-off =
    mkCheck "earth-pulseaudio-off"
    (cfgs.earth.config.services.pulseaudio.enable == false)
    "earth must have pulseaudio disabled (pipewire-only)";

  andromeda-pulseaudio-off =
    mkCheck "andromeda-pulseaudio-off"
    (cfgs.andromeda.config.services.pulseaudio.enable == false)
    "andromeda must have pulseaudio disabled (pipewire-only)";

  earth-bash-completion =
    mkCheck "earth-bash-completion"
    (cfgs.earth.config.programs.bash.completion.enable == true)
    "earth must enable bash completion";

  earth-firewall-udp-12345 =
    mkCheck "earth-firewall-udp-12345"
    (lib.elem 12345 cfgs.earth.config.networking.firewall.allowedUDPPorts)
    "earth firewall must open UDP 12345";

  earth-hm-alias-vn =
    mkCheck "earth-hm-alias-vn"
    (cfgs.earth.config.home-manager.users.jelias.home.shellAliases.vn
      == "nvim /etc/nixos/configuration.nix")
    "earth home must expose shellAlias vn=nvim /etc/nixos/configuration.nix";

  earth-alacritty-term =
    mkCheck "earth-alacritty-term"
    (cfgs.earth.config.home-manager.users.jelias.programs.alacritty.settings.env.TERM
      == "xterm-256color")
    "earth alacritty must set env.TERM=xterm-256color";

  earth-alacritty-scrolling =
    mkCheck "earth-alacritty-scrolling"
    (cfgs.earth.config.home-manager.users.jelias.programs.alacritty.settings.scrolling.multiplier
      == 5)
    "earth alacritty must set scrolling.multiplier=5";

  earth-alacritty-clipboard =
    mkCheck "earth-alacritty-clipboard"
    (cfgs.earth.config.home-manager.users.jelias.programs.alacritty.settings.selection.save_to_clipboard
      == true)
    "earth alacritty must save selection to clipboard";

  earth-gpu-monitor-nvidia =
    mkCheck "earth-gpu-monitor-nvidia"
    (cfgs.earth.config.home-manager.users.jelias.my.hm.bundles.extras.gpuMonitor == "nvidia")
    "earth home must set gpuMonitor = \"nvidia\"";

  andromeda-gpu-monitor-amd =
    mkCheck "andromeda-gpu-monitor-amd"
    (cfgs.andromeda.config.home-manager.users.pallon.my.hm.bundles.extras.gpuMonitor == "amd")
    "andromeda home must default gpuMonitor to \"amd\"";

  earth-hyprland-enabled =
    mkCheck "earth-hyprland-enabled"
    cfgs.earth.config.programs.hyprland.enable
    "earth must enable hyprland";

  andromeda-hyprland-enabled =
    mkCheck "andromeda-hyprland-enabled"
    cfgs.andromeda.config.programs.hyprland.enable
    "andromeda must enable hyprland";

  earth-hyprland-xwayland =
    mkCheck "earth-hyprland-xwayland"
    cfgs.earth.config.programs.hyprland.xwayland.enable
    "earth hyprland must enable xwayland";

  earth-hyprland-uwsm =
    mkCheck "earth-hyprland-uwsm"
    cfgs.earth.config.programs.hyprland.withUWSM
    "earth hyprland must use UWSM";

  andromeda-hyprland-uwsm =
    mkCheck "andromeda-hyprland-uwsm"
    cfgs.andromeda.config.programs.hyprland.withUWSM
    "andromeda hyprland must use UWSM";

  earth-hyprland-package-present =
    mkCheck "earth-hyprland-package-present"
    (cfgs.earth.config.programs.hyprland.package != null)
    "earth NixOS Hyprland package must be present";

  andromeda-hyprland-package-present =
    mkCheck "andromeda-hyprland-package-present"
    (cfgs.andromeda.config.programs.hyprland.package != null)
    "andromeda NixOS Hyprland package must be present";

  earth-hyprlock-pam =
    mkCheck "earth-hyprlock-pam"
    (cfgs.earth.config.security.pam.services ? hyprlock)
    "earth must have hyprlock PAM service";

  andromeda-hyprlock-pam =
    mkCheck "andromeda-hyprlock-pam"
    (cfgs.andromeda.config.security.pam.services ? hyprlock)
    "andromeda must have hyprlock PAM service";

  earth-gnome-enabled =
    mkCheck "earth-gnome-enabled"
    cfgs.earth.config.services.desktopManager.gnome.enable
    "earth must enable gnome desktop";

  earth-dconf-enabled =
    mkCheck "earth-dconf-enabled"
    cfgs.earth.config.programs.dconf.enable
    "earth must enable dconf";

  earth-hm-hyprland-enabled =
    mkCheck "earth-hm-hyprland-enabled"
    cfgs.earth.config.home-manager.users.jelias.wayland.windowManager.hyprland.enable
    "earth jelias must enable HM hyprland";

  andromeda-hm-hyprland-enabled =
    mkCheck "andromeda-hm-hyprland-enabled"
    cfgs.andromeda.config.home-manager.users.pallon.wayland.windowManager.hyprland.enable
    "andromeda pallon must enable HM hyprland";

  earth-hm-hyprland-systemd-disabled =
    mkCheck "earth-hm-hyprland-systemd-disabled"
    (!cfgs.earth.config.home-manager.users.jelias.wayland.windowManager.hyprland.systemd.enable)
    "earth HM Hyprland systemd integration must be disabled for UWSM";

  andromeda-hm-hyprland-systemd-disabled =
    mkCheck "andromeda-hm-hyprland-systemd-disabled"
    (!cfgs.andromeda.config.home-manager.users.pallon.wayland.windowManager.hyprland.systemd.enable)
    "andromeda HM Hyprland systemd integration must be disabled for UWSM";

  earth-hm-hyprland-package-null =
    mkCheck "earth-hm-hyprland-package-null"
    (cfgs.earth.config.home-manager.users.jelias.wayland.windowManager.hyprland.package == null)
    "earth HM Hyprland package must be null to use NixOS module package";

  andromeda-hm-hyprland-package-null =
    mkCheck "andromeda-hm-hyprland-package-null"
    (cfgs.andromeda.config.home-manager.users.pallon.wayland.windowManager.hyprland.package == null)
    "andromeda HM Hyprland package must be null to use NixOS module package";

  earth-hm-hyprland-portal-package-null =
    mkCheck "earth-hm-hyprland-portal-package-null"
    (cfgs.earth.config.home-manager.users.jelias.wayland.windowManager.hyprland.portalPackage == null)
    "earth HM Hyprland portalPackage must be null to use NixOS module portal package";

  andromeda-hm-hyprland-portal-package-null =
    mkCheck "andromeda-hm-hyprland-portal-package-null"
    (cfgs.andromeda.config.home-manager.users.pallon.wayland.windowManager.hyprland.portalPackage == null)
    "andromeda HM Hyprland portalPackage must be null to use NixOS module portal package";

  earth-hm-hyprland-final-package-null =
    mkCheck "earth-hm-hyprland-final-package-null"
    (cfgs.earth.config.home-manager.users.jelias.wayland.windowManager.hyprland.finalPackage == null)
    "earth HM Hyprland finalPackage must resolve to null";

  andromeda-hm-hyprland-final-package-null =
    mkCheck "andromeda-hm-hyprland-final-package-null"
    (cfgs.andromeda.config.home-manager.users.pallon.wayland.windowManager.hyprland.finalPackage == null)
    "andromeda HM Hyprland finalPackage must resolve to null";

  earth-hm-hyprland-final-portal-package-null =
    mkCheck "earth-hm-hyprland-final-portal-package-null"
    (cfgs.earth.config.home-manager.users.jelias.wayland.windowManager.hyprland.finalPortalPackage == null)
    "earth HM Hyprland finalPortalPackage must resolve to null";

  andromeda-hm-hyprland-final-portal-package-null =
    mkCheck "andromeda-hm-hyprland-final-portal-package-null"
    (cfgs.andromeda.config.home-manager.users.pallon.wayland.windowManager.hyprland.finalPortalPackage == null)
    "andromeda HM Hyprland finalPortalPackage must resolve to null";

  earth-hm-hyprland-session-target-absent =
    mkCheck "earth-hm-hyprland-session-target-absent"
    (!(cfgs.earth.config.home-manager.users.jelias.systemd.user.targets ? "hyprland-session"))
    "earth HM must not generate hyprland-session.target for UWSM";

  andromeda-hm-hyprland-session-target-absent =
    mkCheck "andromeda-hm-hyprland-session-target-absent"
    (!(cfgs.andromeda.config.home-manager.users.pallon.systemd.user.targets ? "hyprland-session"))
    "andromeda HM must not generate hyprland-session.target for UWSM";

  earth-hm-xdg-portal-disabled =
    mkCheck "earth-hm-xdg-portal-disabled"
    (!cfgs.earth.config.home-manager.users.jelias.xdg.portal.enable)
    "earth HM xdg portal must be disabled because NixOS owns portals";

  andromeda-hm-xdg-portal-disabled =
    mkCheck "andromeda-hm-xdg-portal-disabled"
    (!cfgs.andromeda.config.home-manager.users.pallon.xdg.portal.enable)
    "andromeda HM xdg portal must be disabled because NixOS owns portals";

  earth-hm-uwsm-env =
    mkCheck "earth-hm-uwsm-env"
    (cfgs.earth.config.home-manager.users.jelias.xdg.configFile ? "uwsm/env")
    "earth HM must export session variables for UWSM";

  andromeda-hm-uwsm-env =
    mkCheck "andromeda-hm-uwsm-env"
    (cfgs.andromeda.config.home-manager.users.pallon.xdg.configFile ? "uwsm/env")
    "andromeda HM must export session variables for UWSM";

  earth-hm-waybar-enabled =
    mkCheck "earth-hm-waybar-enabled"
    cfgs.earth.config.home-manager.users.jelias.programs.waybar.enable
    "earth jelias must enable waybar";

  andromeda-hm-waybar-enabled =
    mkCheck "andromeda-hm-waybar-enabled"
    cfgs.andromeda.config.home-manager.users.pallon.programs.waybar.enable
    "andromeda pallon must enable waybar";

  hyprland-no-windowrulev2 =
    mkCheck "hyprland-no-windowrulev2"
    (! (builtins.hasAttr "windowrulev2"
      cfgs.earth.config.home-manager.users.jelias.wayland.windowManager.hyprland.settings))
    "Hyprland must not use deprecated windowrulev2";

  hyprland-has-windowrule =
    mkCheck "hyprland-has-windowrule"
    (builtins.hasAttr "windowrule"
      cfgs.earth.config.home-manager.users.jelias.wayland.windowManager.hyprland.settings)
    "Hyprland must use windowrule (not windowrulev2)";

  hyprland-no-wlr-no-hw-cursors =
    mkCheck "hyprland-no-wlr-no-hw-cursors"
    (let
      envList = cfgs.earth.config.home-manager.users.jelias.wayland.windowManager.hyprland.settings.env or [];
    in
      ! (builtins.any (e: builtins.match "WLR_NO_HARDWARE_CURSORS.*" e != null) envList))
    "Must not set WLR_NO_HARDWARE_CURSORS env (deprecated)";

  hyprland-cursor-no-hw-cursors-nvidia =
    mkCheck "hyprland-cursor-no-hw-cursors-nvidia"
    ((cfgs.earth.config.home-manager.users.jelias.wayland.windowManager.hyprland.settings.cursor.no_hardware_cursors or false) == true)
    "NVIDIA host must set cursor.no_hardware_cursors";

  hyprland-bind-workspace-back-and-forth =
    mkCheck "hyprland-bind-workspace-back-and-forth"
    ((cfgs.earth.config.home-manager.users.jelias.wayland.windowManager.hyprland.settings.binds.workspace_back_and_forth or false) == true)
    "Hyprland must enable workspace_back_and_forth";

  hyprland-has-togglesplit =
    mkCheck "hyprland-has-togglesplit"
    (builtins.any (b: builtins.match ".*togglesplit.*" b != null)
      cfgs.earth.config.home-manager.users.jelias.wayland.windowManager.hyprland.settings.bind)
    "Hyprland must have togglesplit binding";

  hyprland-has-togglegroup =
    mkCheck "hyprland-has-togglegroup"
    (builtins.any (b: builtins.match ".*togglegroup.*" b != null)
      cfgs.earth.config.home-manager.users.jelias.wayland.windowManager.hyprland.settings.bind)
    "Hyprland must have togglegroup binding (tabbed)";

  hyprland-has-exit-submap =
    mkCheck "hyprland-has-exit-submap"
    (lib.hasInfix "submap = exit"
      cfgs.earth.config.home-manager.users.jelias.wayland.windowManager.hyprland.extraConfig)
    "Hyprland must have exit submap";

  hyprland-has-screen-submap =
    mkCheck "hyprland-has-screen-submap"
    (lib.hasInfix "submap = screen"
      cfgs.earth.config.home-manager.users.jelias.wayland.windowManager.hyprland.extraConfig)
    "Hyprland must have screen submap";

  hyprland-has-work-submap =
    mkCheck "hyprland-has-work-submap"
    (lib.hasInfix "submap = work"
      cfgs.earth.config.home-manager.users.jelias.wayland.windowManager.hyprland.extraConfig)
    "Hyprland must have work submap";

  hyprland-has-refocus-submap =
    mkCheck "hyprland-has-refocus-submap"
    (lib.hasInfix "submap = refocus"
      cfgs.earth.config.home-manager.users.jelias.wayland.windowManager.hyprland.extraConfig)
    "Hyprland must have refocus submap";

  hyprland-has-redesign-submap =
    mkCheck "hyprland-has-redesign-submap"
    (lib.hasInfix "submap = redesign"
      cfgs.earth.config.home-manager.users.jelias.wayland.windowManager.hyprland.extraConfig)
    "Hyprland must have redesign submap";

  hyprland-bind-exit-submap =
    mkCheck "hyprland-bind-exit-submap"
    (builtins.any (b: builtins.match ".*SHIFT.*E.*submap.*exit.*" b != null)
      cfgs.earth.config.home-manager.users.jelias.wayland.windowManager.hyprland.settings.bind)
    "Hyprland must bind $mod+Shift+E to exit submap";

  hyprland-bind-screen-submap =
    mkCheck "hyprland-bind-screen-submap"
    (builtins.any (b: builtins.match ".*SHIFT.*M.*submap.*screen.*" b != null)
      cfgs.earth.config.home-manager.users.jelias.wayland.windowManager.hyprland.settings.bind)
    "Hyprland must bind $mod+Shift+M to screen submap";

  hyprland-has-mod3-shortcuts =
    mkCheck "hyprland-has-mod3-shortcuts"
    (builtins.any (b: builtins.match ".*MOD3.*exec.*" b != null)
      cfgs.earth.config.home-manager.users.jelias.wayland.windowManager.hyprland.settings.bind)
    "Hyprland must have MOD3 (AltGr/NEO) program shortcuts";

  earth-hm-gnome-dconf-enabled =
    mkCheck "earth-hm-gnome-dconf-enabled"
    cfgs.earth.config.home-manager.users.jelias.my.hm.features.gnome.enable
    "jelias on earth must have GNOME dconf keybindings enabled";

  andromeda-hm-gnome-dconf-enabled =
    mkCheck "andromeda-hm-gnome-dconf-enabled"
    cfgs.andromeda.config.home-manager.users.pallon.my.hm.features.gnome.enable
    "pallon on andromeda must have GNOME dconf keybindings enabled";

  earth-i3-still-enabled =
    mkCheck "earth-i3-still-enabled"
    cfgs.earth.config.services.xserver.windowManager.i3.enable
    "earth must still have i3 enabled";

  andromeda-i3-still-enabled =
    mkCheck "andromeda-i3-still-enabled"
    cfgs.andromeda.config.services.xserver.windowManager.i3.enable
    "andromeda must still have i3 enabled";

  andromeda-bing-wallpaper-enabled =
    mkCheck "andromeda-bing-wallpaper-enabled"
    (pallonHome.my.hm.features.bingWallpaper.enable == true)
    "andromeda/pallon must enable Bing wallpaper";

  andromeda-bing-wallpaper-market =
    mkCheck "andromeda-bing-wallpaper-market"
    (pallonHome.my.hm.features.bingWallpaper.market == "de-DE")
    "Bing wallpaper market must be de-DE";

  andromeda-bing-wallpaper-count =
    mkCheck "andromeda-bing-wallpaper-count"
    (pallonHome.my.hm.features.bingWallpaper.count == 2)
    "Bing wallpaper must fetch 2 images";

  andromeda-bing-wallpaper-prefers-uhd =
    mkCheck "andromeda-bing-wallpaper-prefers-uhd"
    (pallonHome.my.hm.features.bingWallpaper.preferUhd == true)
    "Bing wallpaper must prefer UHD";

  andromeda-bing-wallpaper-primary-monitor =
    mkCheck "andromeda-bing-wallpaper-primary-monitor"
    (pallonHome.my.hm.features.bingWallpaper.hyprlandPrimaryMonitor == "eDP-1")
    "Bing wallpaper must target eDP-1 as the Hyprland primary monitor";

  andromeda-bing-wallpaper-nasa-apod =
    mkCheck "andromeda-bing-wallpaper-nasa-apod"
    (pallonHome.my.hm.features.bingWallpaper.nasaApod.enable == true)
    "Andromeda must enable NASA APOD secondary wallpaper";

  andromeda-bing-wallpaper-session-aware-setter = mkAssertionCheck "check-andromeda-bing-wallpaper-session-aware-setter" [
    {
      condition = lib.hasInfix "hyprctl monitors -j" pallonHome.my.hm.features.bingWallpaper.setter.command;
      message = "Bing wallpaper setter must read Hyprland monitors as JSON";
    }
    {
      condition = lib.hasInfix "hyprctl hyprpaper wallpaper" pallonHome.my.hm.features.bingWallpaper.setter.command;
      message = "Bing wallpaper setter must support Hyprland via hyprpaper wallpaper";
    }
    {
      condition = lib.hasInfix "preferred_monitor=eDP-1" pallonHome.my.hm.features.bingWallpaper.setter.command;
      message = "Bing wallpaper setter must embed the configured primary monitor";
    }
    {
      condition = lib.hasInfix "feh --bg-fill" pallonHome.my.hm.features.bingWallpaper.setter.command;
      message = "Bing wallpaper setter must preserve feh fallback";
    }
  ];

  andromeda-bing-wallpaper-user-service =
    mkCheck "andromeda-bing-wallpaper-user-service"
    (
      pallonHome.systemd.user.services.bing-wallpaper.Service.Type
      == "oneshot"
      && pallonHome.systemd.user.services.bing-wallpaper.Service.ExecStart
      == ["${pallonHome.my.hm.features.bingWallpaper.package}/bin/my-bing-wallpaper refresh-if-stale"]
    )
    "Bing wallpaper timer service must run refresh-if-stale";

  andromeda-bing-wallpaper-login-service =
    mkCheck "andromeda-bing-wallpaper-login-service"
    (
      pallonHome.systemd.user.services.bing-wallpaper-login.Service.ExecStart
      == ["${pallonHome.my.hm.features.bingWallpaper.package}/bin/my-bing-wallpaper login"]
      && pallonHome.systemd.user.services.bing-wallpaper-login.Unit.PartOf
      == ["graphical-session.target"]
      && pallonHome.systemd.user.services.bing-wallpaper-login.Install.WantedBy
      == ["graphical-session.target"]
    )
    "Bing wallpaper login service must run from graphical-session.target";

  andromeda-bing-wallpaper-user-timer =
    mkCheck "andromeda-bing-wallpaper-user-timer"
    (pallonHome.systemd.user.timers.bing-wallpaper.Timer.OnUnitActiveSec == "6h")
    "Bing wallpaper timer must run every 6h";

  andromeda-bing-wallpaper-timer-install =
    mkCheck "andromeda-bing-wallpaper-timer-install"
    (pallonHome.systemd.user.timers.bing-wallpaper.Install.WantedBy == ["timers.target"])
    "Bing wallpaper timer must install into timers.target";

  andromeda-bing-wallpaper-package = pallonHome.my.hm.features.bingWallpaper.package;

  andromeda-bing-wallpaper-script-structure = pkgs.runCommand "andromeda-bing-wallpaper-script-structure" {} ''
    script="${pallonHome.my.hm.features.bingWallpaper.package}/bin/my-bing-wallpaper"
    grep -F latest-paths "$script"
    grep -F "Reused cached Bing wallpaper manifest" "$script"
    grep -F "api.nasa.gov/planetary/apod" "$script"
    grep -F "media_type" "$script"
    grep -F "hdurl" "$script"
    grep -F "hyprctl monitors -j" "$script"
    grep -F "hyprctl hyprpaper wallpaper" "$script"
    grep -F "feh --bg-fill" "$script"
    touch "$out"
  '';

  bing-wallpaper-nasa-image-second-path = pkgs.runCommand "bing-wallpaper-nasa-image-second-path" {} ''
    export HOME="$PWD/home"
    export XDG_CACHE_HOME="$PWD/cache"
    out_dir="$XDG_CACHE_HOME/bing-wallpaper"
    mkdir -p "$out_dir"

    printf 'bing-one\n' > "$PWD/bing-one.jpg"
    printf 'bing-two\n' > "$PWD/bing-two.jpg"
    printf 'nasa\n' > "$PWD/nasa.jpg"
    printf '{"images":[{"urlbase":"/unused/one","url":"file://%s","startdate":"20260429"},{"urlbase":"/unused/two","url":"file://%s","startdate":"20260428"}]}\n' "$PWD/bing-one.jpg" "$PWD/bing-two.jpg" > "$PWD/bing.json"
    printf '{"date":"2026-04-30","media_type":"image","url":"file://%s","hdurl":"file://%s"}\n' "$PWD/nasa.jpg" "$PWD/nasa.jpg" > "$PWD/nasa.json"

    export BING_WALLPAPER_BING_API="file://$PWD/bing.json"
    export BING_WALLPAPER_NASA_API="file://$PWD/nasa.json"
    export BING_WALLPAPER_TEST_OUT="$PWD/setter.out"

    ${bingWallpaperNasaTestPackage}/bin/my-bing-wallpaper

    printf '%s\n%s\n' "$out_dir/20260429_0.jpg" "$out_dir/nasa-20260430.jpg" > expected
    cmp expected "$BING_WALLPAPER_TEST_OUT"
    cmp expected "$out_dir/latest-paths"
    touch "$out"
  '';

  bing-wallpaper-nasa-video-range-selects-newest-image = pkgs.runCommand "bing-wallpaper-nasa-video-range-selects-newest-image" {} ''
    export HOME="$PWD/home"
    export XDG_CACHE_HOME="$PWD/cache"
    out_dir="$XDG_CACHE_HOME/bing-wallpaper"
    mkdir -p "$out_dir"

    printf 'bing-one\n' > "$PWD/bing-one.jpg"
    printf 'bing-two\n' > "$PWD/bing-two.jpg"
    printf 'nasa-new\n' > "$PWD/nasa-new.jpg"
    printf 'nasa-old\n' > "$PWD/nasa-old.jpg"
    printf '{"images":[{"urlbase":"/unused/one","url":"file://%s","startdate":"20260429"},{"urlbase":"/unused/two","url":"file://%s","startdate":"20260428"}]}\n' "$PWD/bing-one.jpg" "$PWD/bing-two.jpg" > "$PWD/bing.json"
    printf '[{"date":"2026-04-30","media_type":"video","url":"https://example.invalid/video"},{"date":"2026-04-29","media_type":"image","url":"file://%s","hdurl":"file://%s"},{"date":"2026-04-24","media_type":"image","url":"file://%s","hdurl":"file://%s"}]\n' "$PWD/nasa-new.jpg" "$PWD/nasa-new.jpg" "$PWD/nasa-old.jpg" "$PWD/nasa-old.jpg" > "$PWD/nasa.json"

    export BING_WALLPAPER_BING_API="file://$PWD/bing.json"
    export BING_WALLPAPER_NASA_API="file://$PWD/nasa.json"
    export BING_WALLPAPER_TEST_OUT="$PWD/setter.out"

    ${bingWallpaperNasaTestPackage}/bin/my-bing-wallpaper

    printf '%s\n%s\n' "$out_dir/20260429_0.jpg" "$out_dir/nasa-20260429.jpg" > expected
    cmp expected "$BING_WALLPAPER_TEST_OUT"
    cmp expected "$out_dir/latest-paths"
    touch "$out"
  '';

  bing-wallpaper-nasa-range-no-image-reuses-cache = pkgs.runCommand "bing-wallpaper-nasa-range-no-image-reuses-cache" {} ''
    export HOME="$PWD/home"
    export XDG_CACHE_HOME="$PWD/cache"
    out_dir="$XDG_CACHE_HOME/bing-wallpaper"
    mkdir -p "$out_dir"

    printf 'bing-one\n' > "$PWD/bing-one.jpg"
    printf 'bing-two\n' > "$PWD/bing-two.jpg"
    printf 'cached-nasa\n' > "$out_dir/nasa-latest.jpg"
    printf '{"images":[{"urlbase":"/unused/one","url":"file://%s","startdate":"20260429"},{"urlbase":"/unused/two","url":"file://%s","startdate":"20260428"}]}\n' "$PWD/bing-one.jpg" "$PWD/bing-two.jpg" > "$PWD/bing.json"
    printf '[{"date":"2026-04-30","media_type":"video","url":"https://example.invalid/video"},{"date":"2026-04-29","media_type":"video","url":"https://example.invalid/video"}]\n' > "$PWD/nasa.json"

    export BING_WALLPAPER_BING_API="file://$PWD/bing.json"
    export BING_WALLPAPER_NASA_API="file://$PWD/nasa.json"
    export BING_WALLPAPER_TEST_OUT="$PWD/setter.out"

    ${bingWallpaperNasaTestPackage}/bin/my-bing-wallpaper

    printf '%s\n%s\n' "$out_dir/20260429_0.jpg" "$out_dir/nasa-latest.jpg" > expected
    cmp expected "$BING_WALLPAPER_TEST_OUT"
    cmp expected "$out_dir/latest-paths"
    touch "$out"
  '';

  bing-wallpaper-nasa-range-no-image-keeps-secondary = pkgs.runCommand "bing-wallpaper-nasa-range-no-image-keeps-secondary" {} ''
    export HOME="$PWD/home"
    export XDG_CACHE_HOME="$PWD/cache"
    out_dir="$XDG_CACHE_HOME/bing-wallpaper"
    mkdir -p "$out_dir"

    printf 'bing-one\n' > "$PWD/bing-one.jpg"
    printf 'bing-two\n' > "$PWD/bing-two.jpg"
    printf '{"images":[{"urlbase":"/unused/one","url":"file://%s","startdate":"20260429"},{"urlbase":"/unused/two","url":"file://%s","startdate":"20260428"}]}\n' "$PWD/bing-one.jpg" "$PWD/bing-two.jpg" > "$PWD/bing.json"
    printf '[{"date":"2026-04-30","media_type":"video","url":"https://example.invalid/video"},{"date":"2026-04-29","media_type":"video","url":"https://example.invalid/video"}]\n' > "$PWD/nasa.json"

    export BING_WALLPAPER_BING_API="file://$PWD/bing.json"
    export BING_WALLPAPER_NASA_API="file://$PWD/nasa.json"
    export BING_WALLPAPER_TEST_OUT="$PWD/setter.out"

    ${bingWallpaperNasaTestPackage}/bin/my-bing-wallpaper

    printf '%s\n' "$out_dir/20260429_0.jpg" > expected
    cmp expected "$BING_WALLPAPER_TEST_OUT"
    cmp expected "$out_dir/latest-paths"
    touch "$out"
  '';

  bing-wallpaper-hyprland-primary-secondary = pkgs.runCommand "bing-wallpaper-hyprland-primary-secondary" {} ''
    mkdir -p "$PWD/bin"
    export PATH="$PWD/bin:${lib.makeBinPath [pkgs.coreutils pkgs.diffutils pkgs.jq]}"
    cat > "$PWD/bin/hyprctl" <<'EOF'
    #!${pkgs.runtimeShell}
    if [ "$1" = monitors ] && [ "$2" = -j ]; then
      printf '[{"name":"eDP-1"},{"name":"DP-4"}]\n'
      exit 0
    fi
    if [ "$1" = hyprpaper ] && [ "$2" = wallpaper ]; then
      printf '%s\n' "$3" >> "$PWD/hyprctl.out"
      exit 0
    fi
    exit 1
    EOF
    chmod +x "$PWD/bin/hyprctl"

    ${bingWallpaperDefaultSetter} /cache/bing.jpg /cache/nasa.jpg

    printf '%s\n%s\n' \
      "eDP-1, /cache/bing.jpg, cover" \
      "DP-4, /cache/nasa.jpg, cover" > expected
    cmp expected "$PWD/hyprctl.out"
    touch "$out"
  '';

  bing-wallpaper-hyprland-missing-primary-falls-back = pkgs.runCommand "bing-wallpaper-hyprland-missing-primary-falls-back" {} ''
    mkdir -p "$PWD/bin"
    export PATH="$PWD/bin:${lib.makeBinPath [pkgs.coreutils pkgs.diffutils pkgs.jq]}"
    cat > "$PWD/bin/hyprctl" <<'EOF'
    #!${pkgs.runtimeShell}
    if [ "$1" = monitors ] && [ "$2" = -j ]; then
      printf '[{"name":"DP-4"},{"name":"HDMI-A-1"}]\n'
      exit 0
    fi
    if [ "$1" = hyprpaper ] && [ "$2" = wallpaper ]; then
      printf '%s\n' "$3" >> "$PWD/hyprctl.out"
      exit 0
    fi
    exit 1
    EOF
    chmod +x "$PWD/bin/hyprctl"

    ${bingWallpaperDefaultSetter} /cache/bing.jpg /cache/nasa.jpg

    printf '%s\n%s\n' \
      "DP-4, /cache/bing.jpg, cover" \
      "HDMI-A-1, /cache/nasa.jpg, cover" > expected
    cmp expected "$PWD/hyprctl.out"
    touch "$out"
  '';

  bing-wallpaper-hyprland-single-monitor-one-call = pkgs.runCommand "bing-wallpaper-hyprland-single-monitor-one-call" {} ''
    mkdir -p "$PWD/bin"
    export PATH="$PWD/bin:${lib.makeBinPath [pkgs.coreutils pkgs.diffutils pkgs.jq]}"
    cat > "$PWD/bin/hyprctl" <<'EOF'
    #!${pkgs.runtimeShell}
    if [ "$1" = monitors ] && [ "$2" = -j ]; then
      printf '[{"name":"eDP-1"}]\n'
      exit 0
    fi
    if [ "$1" = hyprpaper ] && [ "$2" = wallpaper ]; then
      printf '%s\n' "$3" >> "$PWD/hyprctl.out"
      exit 0
    fi
    exit 1
    EOF
    chmod +x "$PWD/bin/hyprctl"

    ${bingWallpaperDefaultSetter} /cache/bing.jpg /cache/nasa.jpg

    printf '%s\n' "eDP-1, /cache/bing.jpg, cover" > expected
    cmp expected "$PWD/hyprctl.out"
    touch "$out"
  '';

  bing-wallpaper-hyprland-one-path-keeps-secondary = pkgs.runCommand "bing-wallpaper-hyprland-one-path-keeps-secondary" {} ''
    mkdir -p "$PWD/bin"
    export PATH="$PWD/bin:${lib.makeBinPath [pkgs.coreutils pkgs.diffutils pkgs.jq]}"
    cat > "$PWD/bin/hyprctl" <<'EOF'
    #!${pkgs.runtimeShell}
    if [ "$1" = monitors ] && [ "$2" = -j ]; then
      printf '[{"name":"eDP-1"},{"name":"DP-4"}]\n'
      exit 0
    fi
    if [ "$1" = hyprpaper ] && [ "$2" = wallpaper ]; then
      printf '%s\n' "$3" >> "$PWD/hyprctl.out"
      exit 0
    fi
    exit 1
    EOF
    chmod +x "$PWD/bin/hyprctl"

    ${bingWallpaperDefaultSetter} /cache/bing.jpg

    printf '%s\n' "eDP-1, /cache/bing.jpg, cover" > expected
    cmp expected "$PWD/hyprctl.out"
    touch "$out"
  '';

  bing-wallpaper-hyprland-wallpaper-retries = pkgs.runCommand "bing-wallpaper-hyprland-wallpaper-retries" {} ''
    mkdir -p "$PWD/bin"
    export PATH="$PWD/bin:${lib.makeBinPath [pkgs.coreutils pkgs.diffutils pkgs.jq]}"
    cat > "$PWD/bin/hyprctl" <<'EOF'
    #!${pkgs.runtimeShell}
    if [ "$1" = monitors ] && [ "$2" = -j ]; then
      printf '[{"name":"eDP-1"}]\n'
      exit 0
    fi
    if [ "$1" = hyprpaper ] && [ "$2" = wallpaper ]; then
      count="$(cat "$PWD/wallpaper-count" 2>/dev/null || printf 0)"
      count="$((count + 1))"
      printf '%s\n' "$count" > "$PWD/wallpaper-count"
      if [ "$count" -eq 1 ]; then
        exit 1
      fi
      printf '%s\n' "$3" >> "$PWD/hyprctl.out"
      exit 0
    fi
    exit 1
    EOF
    chmod +x "$PWD/bin/hyprctl"

    ${bingWallpaperDefaultSetter} /cache/bing.jpg

    test "$(cat "$PWD/wallpaper-count")" = 2
    printf '%s\n' "eDP-1, /cache/bing.jpg, cover" > expected
    cmp expected "$PWD/hyprctl.out"
    touch "$out"
  '';

  bing-wallpaper-reuses-latest-paths = pkgs.runCommand "bing-wallpaper-reuses-latest-paths" {} ''
    export HOME="$PWD/home"
    export XDG_CACHE_HOME="$PWD/cache"
    out_dir="$XDG_CACHE_HOME/bing-wallpaper"
    mkdir -p "$out_dir"
    printf 'one\n' > "$out_dir/one.jpg"
    printf 'two\n' > "$out_dir/two.jpg"
    printf '%s\n%s\n' "$out_dir/one.jpg" "$out_dir/two.jpg" > "$out_dir/latest-paths"
    export BING_WALLPAPER_TEST_OUT="$PWD/setter.out"
    export HTTPS_PROXY="http://127.0.0.1:9"
    export HTTP_PROXY="http://127.0.0.1:9"

    ${bingWallpaperTestPackage}/bin/my-bing-wallpaper 2>stderr
    printf '%s\n%s\n' "$out_dir/one.jpg" "$out_dir/two.jpg" > expected
    cmp expected "$BING_WALLPAPER_TEST_OUT"
    grep -F "Reused cached Bing wallpaper manifest" stderr
    touch "$out"
  '';

  bing-wallpaper-reuses-latest-jpg = pkgs.runCommand "bing-wallpaper-reuses-latest-jpg" {} ''
    export HOME="$PWD/home"
    export XDG_CACHE_HOME="$PWD/cache"
    out_dir="$XDG_CACHE_HOME/bing-wallpaper"
    mkdir -p "$out_dir"
    printf 'latest\n' > "$out_dir/latest.jpg"
    export BING_WALLPAPER_TEST_OUT="$PWD/setter.out"
    export HTTPS_PROXY="http://127.0.0.1:9"
    export HTTP_PROXY="http://127.0.0.1:9"

    ${bingWallpaperTestPackage}/bin/my-bing-wallpaper 2>stderr
    printf '%s\n' "$out_dir/latest.jpg" > expected
    cmp expected "$BING_WALLPAPER_TEST_OUT"
    grep -F "Reused cached Bing latest.jpg" stderr
    touch "$out"
  '';

  bing-wallpaper-fails-without-cache = pkgs.runCommand "bing-wallpaper-fails-without-cache" {} ''
    export HOME="$PWD/home"
    export XDG_CACHE_HOME="$PWD/cache"
    mkdir -p "$XDG_CACHE_HOME/bing-wallpaper"
    export BING_WALLPAPER_TEST_OUT="$PWD/setter.out"
    export HTTPS_PROXY="http://127.0.0.1:9"
    export HTTP_PROXY="http://127.0.0.1:9"

    if ${bingWallpaperTestPackage}/bin/my-bing-wallpaper 2>stderr; then
      echo "Bing wallpaper should fail without downloads or cache" >&2
      exit 1
    fi
    grep -F "No Bing wallpapers downloaded and no cache available" stderr
    test ! -e "$BING_WALLPAPER_TEST_OUT"
    touch "$out"
  '';

  bing-wallpaper-login-fresh-cache-skips-fetch = pkgs.runCommand "bing-wallpaper-login-fresh-cache-skips-fetch" {} ''
    export HOME="$PWD/home"
    export XDG_CACHE_HOME="$PWD/cache"
    out_dir="$XDG_CACHE_HOME/bing-wallpaper"
    mkdir -p "$out_dir"

    printf 'cached\n' > "$out_dir/cached.jpg"
    printf '%s\n' "$out_dir/cached.jpg" > "$out_dir/latest-paths"
    today="$(date +%F)"
    printf '{"version":1,"refreshedDate":"%s","market":"de-DE","displayPaths":["%s"],"bingStartdate":"20260429","nasaDate":null}\n' "$today" "$out_dir/cached.jpg" > "$out_dir/state.json"

    printf 'fresh-fetch\n' > "$PWD/fresh-fetch.jpg"
    printf '{"images":[{"urlbase":"/unused/fresh","url":"file://%s","startdate":"20260430"}]}\n' "$PWD/fresh-fetch.jpg" > "$PWD/bing.json"

    export BING_WALLPAPER_BING_API="file://$PWD/bing.json"
    export BING_WALLPAPER_TEST_OUT="$PWD/setter.out"

    ${bingWallpaperTestPackage}/bin/my-bing-wallpaper login

    printf '%s\n' "$out_dir/cached.jpg" > expected
    cmp expected "$BING_WALLPAPER_TEST_OUT"
    grep -F "$out_dir/cached.jpg" "$out_dir/state.json"
    test ! -e "$out_dir/20260430_0.jpg"
    touch "$out"
  '';

  bing-wallpaper-login-stale-cache-refreshes = pkgs.runCommand "bing-wallpaper-login-stale-cache-refreshes" {} ''
    export HOME="$PWD/home"
    export XDG_CACHE_HOME="$PWD/cache"
    out_dir="$XDG_CACHE_HOME/bing-wallpaper"
    mkdir -p "$out_dir"

    printf 'cached\n' > "$out_dir/cached.jpg"
    printf '%s\n' "$out_dir/cached.jpg" > "$out_dir/latest-paths"
    printf '{"version":1,"refreshedDate":"2026-01-01","market":"de-DE","displayPaths":["%s"],"bingStartdate":"20260101","nasaDate":null}\n' "$out_dir/cached.jpg" > "$out_dir/state.json"

    printf 'refreshed\n' > "$PWD/refreshed.jpg"
    printf '{"images":[{"urlbase":"/unused/refreshed","url":"file://%s","startdate":"20260430"}]}\n' "$PWD/refreshed.jpg" > "$PWD/bing.json"

    export BING_WALLPAPER_BING_API="file://$PWD/bing.json"
    export BING_WALLPAPER_TEST_OUT="$PWD/setter.out"

    ${bingWallpaperTestPackage}/bin/my-bing-wallpaper login

    printf '%s\n' "$out_dir/20260430_0.jpg" > expected
    cmp expected "$BING_WALLPAPER_TEST_OUT"
    cmp expected "$out_dir/latest-paths"
    grep -F '"refreshedDate": "'"$(date +%F)"'"' "$out_dir/state.json"
    grep -F '"bingStartdate": "20260430"' "$out_dir/state.json"
    touch "$out"
  '';

  bing-wallpaper-login-stale-fetch-failure-keeps-cache = pkgs.runCommand "bing-wallpaper-login-stale-fetch-failure-keeps-cache" {} ''
    export HOME="$PWD/home"
    export XDG_CACHE_HOME="$PWD/cache"
    out_dir="$XDG_CACHE_HOME/bing-wallpaper"
    mkdir -p "$out_dir"

    printf 'cached\n' > "$out_dir/cached.jpg"
    printf '%s\n' "$out_dir/cached.jpg" > "$out_dir/latest-paths"
    printf '{"version":1,"refreshedDate":"2026-01-01","market":"de-DE","displayPaths":["%s"],"bingStartdate":"20260101","nasaDate":null}\n' "$out_dir/cached.jpg" > "$out_dir/state.json"

    export BING_WALLPAPER_BING_API="file://$PWD/missing.json"
    export BING_WALLPAPER_TEST_OUT="$PWD/setter.out"

    ${bingWallpaperTestPackage}/bin/my-bing-wallpaper login 2>stderr

    printf '%s\n' "$out_dir/cached.jpg" > expected
    cmp expected "$BING_WALLPAPER_TEST_OUT"
    grep -F "Failed to fetch Bing metadata" stderr
    touch "$out"
  '';

  bing-wallpaper-refresh-if-stale-skips-when-fresh = pkgs.runCommand "bing-wallpaper-refresh-if-stale-skips-when-fresh" {} ''
    export HOME="$PWD/home"
    export XDG_CACHE_HOME="$PWD/cache"
    out_dir="$XDG_CACHE_HOME/bing-wallpaper"
    mkdir -p "$out_dir"

    printf 'cached\n' > "$out_dir/cached.jpg"
    printf '%s\n' "$out_dir/cached.jpg" > "$out_dir/latest-paths"
    today="$(date +%F)"
    printf '{"version":1,"refreshedDate":"%s","market":"de-DE","displayPaths":["%s"],"bingStartdate":"20260429","nasaDate":null}\n' "$today" "$out_dir/cached.jpg" > "$out_dir/state.json"

    printf 'fresh-fetch\n' > "$PWD/fresh-fetch.jpg"
    printf '{"images":[{"urlbase":"/unused/fresh","url":"file://%s","startdate":"20260430"}]}\n' "$PWD/fresh-fetch.jpg" > "$PWD/bing.json"

    export BING_WALLPAPER_BING_API="file://$PWD/bing.json"
    export BING_WALLPAPER_TEST_OUT="$PWD/setter.out"

    ${bingWallpaperTestPackage}/bin/my-bing-wallpaper refresh-if-stale

    test ! -e "$BING_WALLPAPER_TEST_OUT"
    test ! -e "$out_dir/20260430_0.jpg"
    touch "$out"
  '';

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
      condition = andromeda.home-manager.users.pallon.programs.nvf.settings.vim.theme.enable == false;
      message = "andromeda: nvf built-in theme must be disabled for external Enfocado";
    }
    {
      condition = earth.home-manager.users.jelias.my.hm.features.nvf.enable == true;
      message = "earth: nvf feature must be enabled for jelias";
    }
    {
      condition = earth.home-manager.users.jelias.programs.nvf.settings.vim.theme.enable == false;
      message = "earth: nvf built-in theme must be disabled for external Enfocado";
    }
    {
      condition = andromeda.home-manager.users.pallon.programs.nvf.settings.vim.extraPlugins ? "vim-enfocado";
      message = "andromeda: nvf must include the Vim Enfocado plugin";
    }
    {
      condition = lib.hasInfix "colorscheme" pallonNvfLua && lib.hasInfix "enfocado" pallonNvfLua;
      message = "andromeda: nvf must apply the Enfocado colorscheme in Lua";
    }
    {
      condition = lib.hasInfix "my-theme/mode" pallonNvfLua && lib.hasInfix "SIGUSR1" pallonNvfLua;
      message = "andromeda: nvf must follow the shared theme state via SIGUSR1";
    }
    {
      condition = lib.hasInfix "colorscheme" jeliasNvfLua && lib.hasInfix "enfocado" jeliasNvfLua;
      message = "earth: nvf must apply the Enfocado colorscheme in Lua";
    }
    {
      condition = lib.hasInfix "my-theme/mode" jeliasNvfLua && lib.hasInfix "SIGUSR1" jeliasNvfLua;
      message = "earth: nvf must follow the shared theme state via SIGUSR1";
    }
  ];

  style-config = mkAssertionCheck "style-config" [
    {
      condition = andromeda.my.nixos.features.style.enable == true && earth.my.nixos.features.style.enable == true;
      message = "both hosts must enable the public NixOS style API through the Stylix migration shim";
    }
    {
      condition = andromeda.stylix.enable == true && andromeda.stylix.autoEnable == true;
      message = "andromeda: Stylix must be enabled with autoEnable for full coverage";
    }
    {
      condition = earth.stylix.enable == true && earth.stylix.autoEnable == true;
      message = "earth: Stylix must be enabled with autoEnable for full coverage";
    }
    {
      condition = andromeda.stylix.base16Scheme.base00 == "181818" && earth.stylix.base16Scheme.base00 == "181818";
      message = "Stylix must use dark palette for boot readability (VT console)";
    }
    {
      condition = pallonHome.my.hm.features.style.enable == true && jeliasHome.my.hm.features.style.enable == true;
      message = "both Home Manager users must enable dynamic style";
    }
    {
      condition =
        !(inputs ? wired)
        && !(builtins.pathExists wiredFeaturePath)
        && !(lib.hasInfix "wired.url" flakeText)
        && !(lib.hasInfix "./features/wired.nix" hmDefaultText)
        && !(lib.hasInfix "inputs.wired" andromedaHostText)
        && !(lib.hasInfix "inputs.wired" earthHostText);
      message = "wired must be removed from flake inputs, hosts, and Home Manager imports";
    }
    {
      condition =
        pallonHome.my.hm.features ? dunst
        && jeliasHome.my.hm.features ? dunst
        && pallonHome.my.hm.features.dunst.enable
        && jeliasHome.my.hm.features.dunst.enable;
      message = "both Home Manager users must enable the dunst feature";
    }
    {
      condition =
        (pallonHome.services.dunst.enable or false)
        == false
        && (jeliasHome.services.dunst.enable or false) == false;
      message = "dunst must not be managed through services.dunst or D-Bus activation";
    }
    {
      condition =
        builtins.any (p: (p.pname or p.name or "") == "dunst") pallonHome.home.packages
        && builtins.any (p: (p.pname or p.name or "") == "dunst") jeliasHome.home.packages;
      message = "both users must have pkgs.dunst in home.packages";
    }
    {
      condition =
        lib.hasInfix dunstCommand i3ConfigText
        && builtins.elem dunstCommand pallonHome.wayland.windowManager.hyprland.settings.exec-once
        && builtins.elem dunstCommand jeliasHome.wayland.windowManager.hyprland.settings.exec-once;
      message = "dunst must start explicitly from i3 and Hyprland session startup";
    }
    {
      condition =
        pallonHome.my.hm.features.yazi.enable
        && jeliasHome.my.hm.features.yazi.enable
        && pallonHome.programs.yazi.enable
        && jeliasHome.programs.yazi.enable;
      message = "both users must enable the Yazi feature and HM Yazi program";
    }
    {
      condition =
        pallonHome.my.hm.features.rofi.enable
        && jeliasHome.my.hm.features.rofi.enable
        && pallonHome.programs.rofi.enable
        && jeliasHome.programs.rofi.enable;
      message = "both users must enable managed rofi";
    }
    {
      condition =
        pallonHome.my.hm.features.style.adapters.yazi.enable
        && !pallonHome.my.hm.features.style.adapters.ghostty.enable
        && !pallonHome.my.hm.features.style.adapters.vscode.enable;
      message = "style must enable Yazi adapter and keep Ghostty/VSCode stubs disabled";
    }
    {
      condition =
        pallonHome.my.hm.features.style.adapters.rofi.enable
        && jeliasHome.my.hm.features.style.adapters.rofi.enable;
      message = "style must enable rofi adapter when rofi feature is enabled";
    }
    {
      condition =
        pallonHome.programs.yazi.theme.flavor.dark
        == "enfocado-dark"
        && pallonHome.programs.yazi.theme.flavor.light == "enfocado-light"
        && pallonHome.programs.yazi.flavors ? "enfocado-dark"
        && pallonHome.programs.yazi.flavors ? "enfocado-light";
      message = "Yazi must use generated Enfocado light/dark flavors";
    }
    {
      condition = lib.hasInfix "~/.config/my/theme/current/rofi.rasi" pallonRofiConfigText;
      message = "rofi config must use the dynamic current theme";
    }
    {
      condition =
        lib.hasInfix "#ffffff" pallonFiles."my/theme/rofi/light.rasi".text
        && lib.hasInfix "#181818" pallonFiles."my/theme/rofi/dark.rasi".text
        && lib.hasInfix "#0064e4" pallonFiles."my/theme/rofi/light.rasi".text;
      message = "rofi light/dark themes must be generated from Enfocado";
    }
    {
      condition = pallonHome.services.darkman.enable == true && jeliasHome.services.darkman.enable == true;
      message = "both users must run darkman as the mode source";
    }
    {
      condition = pallonHome.services.darkman.settings.portal == true && jeliasHome.services.darkman.settings.portal == true;
      message = "darkman must expose the XDG Settings portal";
    }
    {
      condition = andromeda.xdg.portal.config.common."org.freedesktop.impl.portal.Settings" == "darkman";
      message = "andromeda NixOS portal Settings backend must be darkman";
    }
    {
      condition = earth.xdg.portal.config.common."org.freedesktop.impl.portal.Settings" == "darkman";
      message = "earth NixOS portal Settings backend must be darkman";
    }
    {
      condition =
        builtins.any
        (p: (p.pname or p.name or "") == "darkman")
        andromeda.xdg.portal.extraPortals;
      message = "andromeda NixOS portal backends must include darkman";
    }
    {
      condition =
        builtins.any
        (p: (p.pname or p.name or "") == "darkman")
        earth.xdg.portal.extraPortals;
      message = "earth NixOS portal backends must include darkman";
    }
    {
      condition = !pallonHome.xdg.portal.enable && !jeliasHome.xdg.portal.enable;
      message = "Home Manager portals must stay disabled because NixOS owns portal services";
    }
    {
      condition = builtins.any (p: (p.pname or p.name or "") == "xdg-desktop-portal-gtk") andromeda.xdg.portal.extraPortals;
      message = "andromeda NixOS portals must include xdg-desktop-portal-gtk as fallback";
    }
    {
      condition = builtins.any (p: (p.pname or p.name or "") == "xdg-desktop-portal-gtk") earth.xdg.portal.extraPortals;
      message = "earth NixOS portals must include xdg-desktop-portal-gtk as fallback";
    }
    {
      condition =
        lib.hasInfix "my-style-switch" pallonDarkmanScript
        && lib.hasInfix ''"$@"'' pallonDarkmanScript;
      message = "pallon darkman must call the shared style dispatcher with mode arguments";
    }
    {
      condition =
        lib.hasInfix "my-style-switch" pallonDarkmanDataScript
        && lib.hasInfix ''"$@"'' pallonDarkmanDataScript;
      message = "pallon darkman data script must call the shared style dispatcher with mode arguments";
    }
    {
      condition =
        lib.hasInfix "my-style-switch" jeliasDarkmanScript
        && lib.hasInfix ''"$@"'' jeliasDarkmanScript;
      message = "jelias darkman must call the shared style dispatcher with mode arguments";
    }
    {
      condition = pallonHome.xdg.portal.config.common.default == "*" && jeliasHome.xdg.portal.config.common.default == "*";
      message = "style must preserve existing common portal defaults";
    }
    {
      condition = pallonHome.xdg.portal.config.common."org.freedesktop.impl.portal.Settings" == "darkman";
      message = "pallon Settings portal must prefer darkman";
    }
    {
      condition = jeliasHome.xdg.portal.config.common."org.freedesktop.impl.portal.Settings" == "darkman";
      message = "jelias Settings portal must prefer darkman";
    }
    {
      condition = (builtins.length pallonHome.xdg.portal.extraPortals) > 0 && (builtins.length jeliasHome.xdg.portal.extraPortals) > 0;
      message = "style must preserve existing GTK portal packages";
    }
    {
      condition = pallonHome.programs.alacritty.settings.general.import == ["~/.config/my/theme/current/alacritty.toml"];
      message = "pallon Alacritty must import the dynamic style theme";
    }
    {
      condition = jeliasHome.programs.alacritty.settings.general.import == ["~/.config/my/theme/current/alacritty.toml"];
      message = "jelias Alacritty must import the dynamic style theme";
    }
    {
      condition = lib.hasInfix ''background = "#ffffff"'' pallonFiles."my/theme/alacritty/enfocado_light.toml".text;
      message = "pallon Enfocado light Alacritty theme must be generated";
    }
    {
      condition = lib.hasInfix ''background = "#181818"'' pallonFiles."my/theme/alacritty/enfocado_dark.toml".text;
      message = "pallon Enfocado dark Alacritty theme must be generated";
    }
    {
      condition = lib.hasInfix "background #ffffff" pallonFiles."kitty/light-theme.auto.conf".text;
      message = "pallon Kitty native light auto theme must use Enfocado light";
    }
    {
      condition = lib.hasInfix "background #181818" pallonFiles."kitty/dark-theme.auto.conf".text;
      message = "pallon Kitty native dark auto theme must use Enfocado dark";
    }
    {
      condition = lib.hasInfix "#ffffff" pallonI3LightThemeText && !(lib.hasInfix "$theme_" pallonI3LightThemeText);
      message = "pallon i3 light theme must use literal Enfocado light colors";
    }
    {
      condition =
        pallonFiles ? "my/theme/dunst/light.conf"
        && pallonFiles ? "my/theme/dunst/dark.conf"
        && jeliasFiles ? "my/theme/dunst/light.conf"
        && jeliasFiles ? "my/theme/dunst/dark.conf";
      message = "dunst light and dark theme files must be generated for both users";
    }
    {
      condition =
        lib.hasInfix ''background = "#ffffff"'' pallonFiles."my/theme/dunst/light.conf".text
        && lib.hasInfix ''foreground = "#474747"'' pallonFiles."my/theme/dunst/light.conf".text
        && lib.hasInfix ''font = "'' pallonFiles."my/theme/dunst/light.conf".text;
      message = "dunst light config must use Enfocado light colors and central notification fonts";
    }
    {
      condition = lib.hasInfix "background-color: #ffffff" pallonFiles."my/theme/waybar/light.css".text;
      message = "pallon Waybar light theme must use Enfocado light";
    }
    {
      condition = lib.hasInfix "col.active_border   = rgba(0064e4ee)" pallonFiles."my/theme/hyprland/light.conf".text;
      message = "pallon Hyprland light theme must use Enfocado light";
    }
    {
      condition = pallonActivation ? "styleCurrentLinks";
      message = "pallon style module must provide styleCurrentLinks home.activation entry";
    }
    {
      condition =
        let data = (pallonActivation.styleCurrentLinks or {data = "";}).data; in
        lib.hasInfix "enfocado_" data
        && lib.hasInfix "current/dunst.conf" data
        && lib.hasInfix "current/waybar.css" data
        && lib.hasInfix "my-theme/mode" data;
      message = "styleCurrentLinks activation must wire alacritty, dunst, waybar symlinks and read persisted mode";
    }
    {
      condition =
        !(pallonFiles ? "my/theme/current/alacritty.toml")
        && !(pallonFiles ? "my/theme/current/dunst.conf")
        && !(pallonFiles ? "my/theme/current/waybar.css")
        && !(pallonFiles ? "my/theme/current/hyprland.conf")
        && !(pallonFiles ? "my/theme/current/rofi.rasi")
        && !(pallonFiles ? "my/theme/current/i3status-rust.toml");
      message = "current/ theme files must be managed by home.activation, not xdg.configFile";
    }
    {
      condition = builtins.any (p: (p.pname or p.name or "") == "my-style-switch") pallonHome.home.packages;
      message = "pallon home must include the style dispatcher package";
    }
    {
      condition = lib.hasInfix ''pkill -u "$USER" -SIGUSR2 i3status-rs || true'' styleSwitchText;
      message = "style dispatcher must restart i3status-rust after switching its theme symlink";
    }
    {
      condition =
        pallonFiles ? "my/theme/i3status-rust/enfocado_light.toml"
        && pallonFiles ? "my/theme/i3status-rust/enfocado_dark.toml"
        && (builtins.fromTOML pallonFiles."my/theme/i3status-rust/enfocado_light.toml".text).idle_bg == "#ffffff"
        && (builtins.fromTOML pallonFiles."my/theme/i3status-rust/enfocado_dark.toml".text).idle_bg == "#181818";
      message = "pallon i3status-rust Enfocado light and dark themes must be generated";
    }
    {
      condition =
        earthFiles ? "my/theme/i3status-rust/enfocado_light.toml"
        && (builtins.fromTOML earthFiles."my/theme/i3status-rust/enfocado_light.toml".text).idle_bg == "#ffffff";
      message = "earth i3status-rust light theme must use Enfocado light";
    }
  ];

  theme-dispatcher-runtime = pkgs.runCommand "theme-dispatcher-runtime" {} ''
    export HOME="$TMPDIR/home"
    export USER="pallon"
    export XDG_CONFIG_HOME="$HOME/.config"
    export XDG_STATE_HOME="$HOME/.local/state"

    mkdir -p \
      "$XDG_CONFIG_HOME/my/theme/alacritty" \
      "$XDG_CONFIG_HOME/my/theme/i3" \
      "$XDG_CONFIG_HOME/my/theme/i3status-rust" \
      "$XDG_CONFIG_HOME/my/theme/hyprland" \
      "$XDG_CONFIG_HOME/my/theme/dunst" \
      "$XDG_CONFIG_HOME/my/theme/rofi" \
      "$XDG_CONFIG_HOME/my/theme/waybar"

    touch "$XDG_CONFIG_HOME/my/theme/alacritty/enfocado_light.toml"
    touch "$XDG_CONFIG_HOME/my/theme/alacritty/enfocado_dark.toml"
    touch "$XDG_CONFIG_HOME/my/theme/i3/light.conf"
    touch "$XDG_CONFIG_HOME/my/theme/i3/dark.conf"
    touch "$XDG_CONFIG_HOME/my/theme/i3status-rust/enfocado_light.toml"
    touch "$XDG_CONFIG_HOME/my/theme/i3status-rust/enfocado_dark.toml"
    touch "$XDG_CONFIG_HOME/my/theme/hyprland/light.conf"
    touch "$XDG_CONFIG_HOME/my/theme/hyprland/dark.conf"
    touch "$XDG_CONFIG_HOME/my/theme/dunst/light.conf"
    touch "$XDG_CONFIG_HOME/my/theme/dunst/dark.conf"
    touch "$XDG_CONFIG_HOME/my/theme/rofi/light.rasi"
    touch "$XDG_CONFIG_HOME/my/theme/rofi/dark.rasi"
    touch "$XDG_CONFIG_HOME/my/theme/waybar/light.css"
    touch "$XDG_CONFIG_HOME/my/theme/waybar/dark.css"

    ${pallonHome.my.hm.features.style.dispatcher.package}/bin/my-style-switch light
    test "$(cat "$XDG_STATE_HOME/my-theme/mode")" = light
    test "$(readlink "$XDG_CONFIG_HOME/my/theme/current/alacritty.toml")" = "$XDG_CONFIG_HOME/my/theme/alacritty/enfocado_light.toml"
    test "$(readlink "$XDG_CONFIG_HOME/my/theme/current/dunst.conf")" = "$XDG_CONFIG_HOME/my/theme/dunst/light.conf"

    ${pallonHome.my.hm.features.style.dispatcher.package}/bin/my-style-switch dark
    test "$(cat "$XDG_STATE_HOME/my-theme/mode")" = dark
    test "$(readlink "$XDG_CONFIG_HOME/my/theme/current/dunst.conf")" = "$XDG_CONFIG_HOME/my/theme/dunst/dark.conf"
    test "$(readlink "$XDG_CONFIG_HOME/my/theme/current/rofi.rasi")" = "$XDG_CONFIG_HOME/my/theme/rofi/dark.rasi"
    test "$(readlink "$XDG_CONFIG_HOME/my/theme/current/waybar.css")" = "$XDG_CONFIG_HOME/my/theme/waybar/dark.css"

    if ${pallonHome.my.hm.features.style.dispatcher.package}/bin/my-style-switch invalid; then
      echo "invalid mode must fail" >&2
      exit 1
    fi

    touch "$out"
  '';

  theme-operations-doc = mkAssertionCheck "theme-operations-doc" [
    {
      condition = builtins.pathExists themeDocPath;
      message = "theme operations document must exist";
    }
    {
      condition =
        lib.hasInfix "darkman" themeDoc
        && lib.hasInfix "my-style-switch" themeDoc
        && lib.hasInfix "darkman set light" themeDoc
        && lib.hasInfix "org.freedesktop.appearance color-scheme" themeDoc
        && lib.hasInfix "browser portal validation" themeDoc
        && lib.hasInfix "darkman.portal" themeDoc
        && lib.hasInfix ''matchMedia("(prefers-color-scheme: dark)")'' themeDoc
        && lib.hasInfix "pallon@andromeda" themeDoc;
      message = "theme operations document must cover runtime validation";
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
      condition = lib.hasInfix "include ~/.config/my/theme/current/i3.conf" i3ConfigText;
      message = "andromeda: i3 config must include the managed style theme";
    }
    {
      condition = !(lib.hasInfix "$theme_" i3ConfigText);
      message = "andromeda: parent i3 config must not reference theme variables from an include";
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
      condition = lib.hasInfix "bar {" pallonI3LightThemeText;
      message = "andromeda: generated light i3 theme must own the bar block";
    }
    {
      condition =
        lib.hasInfix "focused_workspace" pallonI3LightThemeText
        && lib.hasInfix "#0064e4" pallonI3LightThemeText
        && lib.hasInfix "#474747" pallonI3LightThemeText;
      message = "andromeda: generated light i3 bar colors must be literal and visible";
    }
    {
      condition =
        lib.hasInfix "#181818" pallonI3DarkThemeText
        && lib.hasInfix "#b9b9b9" pallonI3DarkThemeText
        && !(lib.hasInfix "$theme_" pallonI3DarkThemeText);
      message = "andromeda: generated dark i3 theme must use literal Enfocado colors";
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
      condition = lib.hasInfix "i3status-rs" pallonI3LightThemeText;
      message = "andromeda: generated light i3 theme must reference i3status-rs";
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
      condition = lib.hasInfix ''theme = "${pallonI3StatusThemePath}"'' pallonI3StatusText;
      message = "andromeda: i3status-rust must use the generated Enfocado theme";
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

  earth-i3-config = mkAssertionCheck "earth-i3-config" [
    {
      condition = jeliasHome.my.hm.features.i3.enable == true;
      message = "earth: i3 feature must be enabled for jelias";
    }
    {
      condition = earthFiles ? "i3/config";
      message = "earth: i3 config must be deployed for jelias";
    }
    {
      condition = earthFiles ? "i3status-rust/config.toml";
      message = "earth: i3status-rust config must be deployed for jelias";
    }
    {
      condition =
        builtins.all
        (cmd: lib.hasInfix "exec --no-startup-id ${cmd}" earthI3ConfigText)
        [
          "ETESYNC_URL=https://scal.metacosmos.space etesync-dav"
          "syncthingtray"
          "nm-applet"
          "protonvpn-app"
          "protonmail-bridge -n"
          "pasystray"
        ];
      message = "earth: i3 config must contain expected startup commands";
    }
    {
      condition = lib.hasInfix ''workspace "1: mail" output primary'' earthI3ConfigText;
      message = "earth: i3 config must assign workspace 1 to primary";
    }
    {
      condition = lib.hasInfix ''workspace "11: terminal" output nonprimary primary'' earthI3ConfigText;
      message = "earth: i3 config must assign workspace 11 to nonprimary primary";
    }
    {
      condition = lib.hasInfix "xrandr --output DP-2" earthI3ConfigText;
      message = "earth: i3 config must use DP-2 in xrandr commands";
    }
    {
      condition = lib.hasInfix "--output DP-4" earthI3ConfigText;
      message = "earth: i3 config must use DP-4 in xrandr commands";
    }
    {
      condition = !(lib.hasInfix "$OUT" earthI3ConfigText);
      message = "earth: i3 config must not contain obsolete $OUT variables";
    }
    {
      condition = !(lib.hasInfix "$OUT2" earthI3ConfigText);
      message = "earth: i3 config must not contain obsolete $OUT2 variables";
    }
    {
      condition = !(lib.hasInfix "qsyncthingtray" earthI3ConfigText);
      message = "earth: i3 config must use syncthingtray, not qsyncthingtray";
    }
    {
      condition = !(lib.hasInfix "include ~/.config/i3" earthI3ConfigText);
      message = "earth: i3 config must not include unmanaged ~/.config/i3 snippets";
    }
    {
      condition = lib.hasInfix "include ~/.config/my/theme/current/i3.conf" earthI3ConfigText;
      message = "earth: i3 config must include the managed style theme";
    }
    {
      condition = andromeda.services.xserver.windowManager.i3.enable == true;
      message = "andromeda: system i3 must remain enabled";
    }
    {
      condition = pallonHome.my.hm.features.i3.enable == true;
      message = "andromeda: pallon Home Manager i3 must remain enabled";
    }
    {
      condition = lib.hasInfix "alacritty --working-directory ~/projects/pallon/webapp/frontend" i3ConfigText;
      message = "andromeda: pallon alternate terminal binding must be preserved";
    }
  ];

  earth-i3-statusbar = mkAssertionCheck "earth-i3-statusbar" [
    {
      condition = lib.hasInfix ''theme = "${jeliasI3StatusThemePath}"'' earthI3StatusText;
      message = "earth: i3status-rust must use the generated Enfocado theme";
    }
    {
      condition = lib.hasInfix ''gpu = "🎮"'' earthI3StatusText;
      message = "earth: i3status-rust must override the GPU icon";
    }
    {
      condition = lib.hasInfix ''block = "nvidia_gpu"'' earthI3StatusText;
      message = "earth: i3status-rust must include nvidia_gpu block";
    }
    {
      condition = lib.hasInfix ''format = " $icon$clocks $power $memory"'' earthI3StatusText;
      message = "earth: nvidia_gpu block must use the migrated format";
    }
    {
      condition = lib.hasInfix "[[block.click]]" earthI3StatusText && lib.hasInfix ''cmd = "pavucontrol"'' earthI3StatusText;
      message = "earth: sound block must open pavucontrol on click";
    }
    {
      condition = lib.hasInfix ''device = "enp8s0"'' earthI3StatusText;
      message = "earth: i3status-rust must include enp8s0";
    }
    {
      condition = !(lib.hasInfix ''device = "wlp7s0"'' earthI3StatusText);
      message = "earth: i3status-rust must not include wlp7s0";
    }
    {
      condition = lib.hasInfix ''format = "{$graph_down}⮃{$graph_up}"'' earthI3StatusText;
      message = "earth: net block must use graph format";
    }
    {
      condition = lib.hasInfix "%d/%m %R" earthI3StatusText;
      message = "earth: time block must use migrated date/time format";
    }
    {
      condition = !(lib.hasInfix "network_speed_" earthI3StatusText);
      message = "earth: i3status-rust must not render unsupported network_speed fields";
    }
    {
      condition = !(lib.hasInfix "timezone =" earthI3StatusText);
      message = "earth: i3status-rust must omit timezone when unset";
    }
    {
      condition = lib.hasInfix ''device = "enp2s0f0"'' pallonHome.xdg.configFile."i3status-rust/config.toml".text;
      message = "andromeda: i3status-rust must still include ethernet device";
    }
    {
      condition = lib.hasInfix ''device = "wlp3s0"'' pallonHome.xdg.configFile."i3status-rust/config.toml".text;
      message = "andromeda: i3status-rust must still include wifi device";
    }
  ];

  earth-i3-syntax = pkgs.runCommand "earth-i3-syntax" {} ''
    export XDG_RUNTIME_DIR="$TMPDIR"
    configFile=${pkgs.writeText "earth-i3-config" earthI3ConfigText}
    ${pkgs.i3}/bin/i3 -C -c "$configFile"
    touch "$out"
  '';

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

  lw-module-isolation = mkAssertionCheck "lw-module-isolation" [
    {
      condition = librewolfTest.programs.librewolf.enable;
      message = "lw module: programs.librewolf.enable must be true when feature is enabled";
    }
    {
      condition = builtins.hasAttr "nix-managed" librewolfTest.programs.librewolf.profiles;
      message = "lw module: profile 'nix-managed' must exist";
    }
    {
      condition =
        librewolfTest.programs.librewolf.profiles."nix-managed".id == 0
        && librewolfTest.programs.librewolf.profiles."nix-managed".isDefault;
      message = "lw module: profile 'nix-managed' must have id=0 and isDefault=true";
    }
    {
      condition = lib.getName librewolfTest.programs.librewolf.package == "librewolf";
      message = "lw module: package option must thread through to programs.librewolf.package";
    }
  ];

  lw-jelias-enabled = mkAssertionCheck "lw-jelias-enabled" [
    {
      condition = jeliasHome.my.hm.features.librewolf.enable;
      message = "earth/jelias: my.hm.features.librewolf.enable must be true";
    }
    {
      condition = jeliasHome.programs.librewolf.enable;
      message = "earth/jelias: programs.librewolf.enable must be true";
    }
    {
      condition = builtins.hasAttr "nix-managed" jeliasHome.programs.librewolf.profiles;
      message = "earth/jelias: librewolf profile 'nix-managed' must exist";
    }
    {
      condition =
        jeliasHome.programs.librewolf.profiles."nix-managed".id == 0
        && jeliasHome.programs.librewolf.profiles."nix-managed".isDefault;
      message = "earth/jelias: librewolf profile 'nix-managed' must have id=0 and isDefault=true";
    }
    {
      condition = lib.getName jeliasHome.programs.librewolf.package == "librewolf-bin";
      message = "earth/jelias: librewolf package must be librewolf-bin";
    }
  ];

  lw-pallon-enabled = mkAssertionCheck "lw-pallon-enabled" [
    {
      condition = pallonHome.my.hm.features.librewolf.enable;
      message = "andromeda/pallon: my.hm.features.librewolf.enable must be true";
    }
    {
      condition = pallonHome.programs.librewolf.enable;
      message = "andromeda/pallon: programs.librewolf.enable must be true";
    }
    {
      condition = builtins.hasAttr "nix-managed" pallonHome.programs.librewolf.profiles;
      message = "andromeda/pallon: librewolf profile 'nix-managed' must exist";
    }
    {
      condition =
        pallonHome.programs.librewolf.profiles."nix-managed".id == 0
        && pallonHome.programs.librewolf.profiles."nix-managed".isDefault;
      message = "andromeda/pallon: librewolf profile 'nix-managed' must have id=0 and isDefault=true";
    }
    {
      condition = lib.getName pallonHome.programs.librewolf.package == "librewolf-bin";
      message = "andromeda/pallon: librewolf package must be librewolf-bin";
    }
  ];

  lw-settings-shared = mkAssertionCheck "lw-settings-shared" [
    {
      condition =
        librewolfTest.programs.librewolf.profiles."nix-managed".settings."privacy.fingerprintingProtection" == true;
      message = "lw module: nix-managed profile must enable privacy.fingerprintingProtection";
    }
    {
      condition =
        jeliasHome.programs.librewolf.profiles."nix-managed".settings."privacy.fingerprintingProtection" == true;
      message = "earth/jelias: nix-managed profile must enable privacy.fingerprintingProtection";
    }
    {
      condition =
        pallonHome.programs.librewolf.profiles."nix-managed".settings."privacy.fingerprintingProtection" == true;
      message = "andromeda/pallon: nix-managed profile must enable privacy.fingerprintingProtection";
    }
    {
      condition =
        pallonHome.programs.librewolf.profiles."nix-managed".settings."privacy.trackingprotection.enabled" == true
        && pallonHome.programs.librewolf.profiles."nix-managed".settings."network.predictor.enabled" == false
        && pallonHome.programs.librewolf.profiles."nix-managed".settings."places.history.enabled" == false
        && pallonHome.programs.librewolf.profiles."nix-managed".settings."browser.contentblocking.category" == "strict";
      message = "andromeda/pallon: representative privacy/UX prefs must be present in nix-managed profile settings";
    }
    {
      condition =
        pallonHome.programs.librewolf.profiles."nix-managed".settings."services.sync.engine.history" == false
        && pallonHome.programs.librewolf.profiles."nix-managed".settings."services.sync.engine.tabs" == false
        && pallonHome.programs.librewolf.profiles."nix-managed".settings."services.sync.engine.prefs.modified" == false;
      message = "andromeda/pallon: sync engines for history/tabs/prefs must be disabled to avoid conflicting with Nix";
    }
  ];

  lw-extensions = mkAssertionCheck "lw-extensions" [
    {
      condition =
        librewolfTest.programs.librewolf.profiles."nix-managed".extensions.packages != [];
      message = "lw module: extensions.packages must be non-empty";
    }
    {
      condition =
        lwHasExt
          librewolfTest.programs.librewolf.profiles."nix-managed".extensions.packages
          "ublock-origin";
      message = "lw module: ublock-origin must be in extensions.packages";
    }
    {
      condition =
        lwHasExt
          jeliasHome.programs.librewolf.profiles."nix-managed".extensions.packages
          "ublock-origin";
      message = "earth/jelias: ublock-origin must be in extensions.packages";
    }
    {
      condition =
        lwHasExt
          pallonHome.programs.librewolf.profiles."nix-managed".extensions.packages
          "ublock-origin";
      message = "andromeda/pallon: ublock-origin must be in extensions.packages";
    }
    {
      condition =
        builtins.length
          pallonHome.programs.librewolf.profiles."nix-managed".extensions.packages
        >= 10;
      message = "andromeda/pallon: at least 10 extensions must be installed";
    }
  ];

  lw-3rdparty = mkAssertionCheck "lw-3rdparty" [
    {
      condition =
        librewolfTest.programs.librewolf.policies ? "3rdparty";
      message = "lw module: policies must contain '3rdparty' key";
    }
    {
      condition =
        librewolfTest.programs.librewolf.policies ? "3rdparty"
        && librewolfTest.programs.librewolf.policies."3rdparty".Extensions
          ? "uBlock0@raymondhill.net";
      message = "lw module: 3rdparty.Extensions must have uBlock0@raymondhill.net";
    }
    {
      condition =
        librewolfTest.programs.librewolf.policies ? "3rdparty"
        && librewolfTest.programs.librewolf.policies."3rdparty".Extensions
          ? "uBlock0@raymondhill.net"
        && (builtins.length
          librewolfTest.programs.librewolf.policies."3rdparty"
            .Extensions."uBlock0@raymondhill.net".toOverwrite.filterLists) > 0;
      message = "lw module: uBlock Origin toOverwrite.filterLists must be non-empty";
    }
    {
      condition =
        librewolfTest.programs.librewolf.policies ? "3rdparty"
        && librewolfTest.programs.librewolf.policies."3rdparty".Extensions
          ? "{1ea2fa75-677e-4702-b06a-50fc7d06fe7e}";
      message = "lw module: 3rdparty.Extensions must have Temporary Containers Plus";
    }
    {
      condition =
        pallonHome.programs.librewolf.policies ? "3rdparty"
        && pallonHome.programs.librewolf.policies."3rdparty".Extensions
          ? "uBlock0@raymondhill.net"
        && pallonHome.programs.librewolf.policies."3rdparty".Extensions
          ? "{1ea2fa75-677e-4702-b06a-50fc7d06fe7e}";
      message = "andromeda/pallon: 3rdparty Extensions must contain uBO and TempContainers+";
    }
  ];

  lw-tempcontainers-prefs = let
    tcPrefs =
      librewolfTest.programs.librewolf.policies."3rdparty"
        .Extensions."{1ea2fa75-677e-4702-b06a-50fc7d06fe7e}";
  in mkAssertionCheck "lw-tempcontainers-prefs" [
    {
      condition =
        tcPrefs.automaticMode.active == true
        && tcPrefs.automaticMode.newTab == "created";
      message = "tc: automaticMode must be active with newTab=\"created\"";
    }
    {
      condition = tcPrefs.notifications == false;
      message = "tc: notifications must be false";
    }
    {
      condition =
        tcPrefs.container.namePrefix == "_"
        && tcPrefs.container.color == "red"
        && tcPrefs.container.icon == "circle"
        && tcPrefs.container.numberMode == "reuse"
        && tcPrefs.container.removal == 900000;
      message = "tc: container shape (prefix/color/icon/numberMode/removal) mismatch";
    }
    {
      condition = tcPrefs.iconColor == "default";
      message = "tc: iconColor must be \"default\"";
    }
    {
      condition =
        tcPrefs.isolation.reactivateDelay == 0
        && tcPrefs.isolation.global.navigation.action == "never";
      message = "tc: isolation.global.navigation.action must be \"never\" (was \"always\" in stub)";
    }
    {
      condition =
        tcPrefs.isolation.global.mouseClick.middle.action == "notsamedomain"
        && tcPrefs.isolation.global.mouseClick.middle.container == "deleteshistory"
        && tcPrefs.isolation.global.mouseClick.ctrlleft.action == "notsamedomain"
        && tcPrefs.isolation.global.mouseClick.left.action == "notsamedomain";
      message = "tc: isolation.global.mouseClick must be notsamedomain/deleteshistory";
    }
    {
      condition = tcPrefs.isolation.global.excluded ? "paypal.com";
      message = "tc: isolation.global.excluded must contain paypal.com";
    }
    {
      condition =
        builtins.length tcPrefs.isolation.domain == 1
        && (builtins.head tcPrefs.isolation.domain).pattern == "runescape.com"
        && (builtins.head tcPrefs.isolation.domain).always.action == "disabled"
        && (builtins.head tcPrefs.isolation.domain).excluded ? "jagex.com";
      message = "tc: isolation.domain[0] must be runescape.com rule with jagex.com excluded";
    }
    {
      condition = tcPrefs.isolation.mac.action == "disabled";
      message = "tc: isolation.mac.action must be \"disabled\"";
    }
    {
      condition =
        tcPrefs.contextMenu == true
        && tcPrefs.browserActionPopup == false
        && tcPrefs.pageAction == false
        && tcPrefs.contextMenuBookmarks == false;
      message = "tc: contextMenu/browserActionPopup/pageAction/contextMenuBookmarks shape mismatch";
    }
    {
      condition =
        builtins.all (k: tcPrefs.keyboardShortcuts.${k} == false)
          ["AltC" "AltP" "AltN" "AltShiftC" "AltX" "AltO" "AltI"];
      message = "tc: all keyboardShortcuts must be disabled";
    }
    {
      condition =
        tcPrefs.closeRedirectorTabs.active == false
        && tcPrefs.closeRedirectorTabs.delay == 2000
        && builtins.elem "t.co" tcPrefs.closeRedirectorTabs.domains
        && builtins.elem "slack-redir.net" tcPrefs.closeRedirectorTabs.domains
        && builtins.elem "outgoing.prod.mozaws.net" tcPrefs.closeRedirectorTabs.domains;
      message = "tc: closeRedirectorTabs domain set mismatch";
    }
    {
      condition =
        tcPrefs.deletesHistory.active == true
        && tcPrefs.deletesHistory.automaticMode == "automatic"
        && tcPrefs.deletesHistory.containerRemoval == 900000
        && tcPrefs.deletesHistory.statistics == true;
      message = "tc: deletesHistory must be active/automatic with 900000ms removal";
    }
    {
      condition =
        tcPrefs.statistics == true
        && tcPrefs.ui.expandPreferences == true
        && tcPrefs.ui.popupDefaultTab == "isolation-global";
      message = "tc: ui shape mismatch";
    }
  ];

  lw-mozpermissions = let
    ubo = lwAddons.ublock-origin;
  in mkAssertionCheck "lw-mozpermissions" [
    {
      condition = ubo ? meta && ubo.meta ? mozPermissions;
      message = "ublock-origin: meta.mozPermissions must be present (rycee NUR audit trail)";
    }
    {
      condition =
        ubo ? meta
        && ubo.meta ? mozPermissions
        && builtins.elem "webRequest" ubo.meta.mozPermissions;
      message = "ublock-origin: webRequest must be in meta.mozPermissions";
    }
  ];

  lw-system-insecure = mkAssertionCheck "lw-system-insecure" [
    {
      condition = builtins.elem "openssl-1.1.1w" lwAndromedaNixpkgsCfg.permittedInsecurePackages;
      message = "andromeda: openssl-1.1.1w must remain in permittedInsecurePackages";
    }
    {
      condition = !(builtins.elem "librewolf-bin-149.0.2-2" lwAndromedaNixpkgsCfg.permittedInsecurePackages);
      message = "andromeda: pinned librewolf-bin-149.0.2-2 must not be in permittedInsecurePackages (use predicate instead)";
    }
    {
      condition = !(builtins.elem "librewolf-bin-unwrapped-149.0.2-2" lwAndromedaNixpkgsCfg.permittedInsecurePackages);
      message = "andromeda: pinned librewolf-bin-unwrapped-149.0.2-2 must not be in permittedInsecurePackages (use predicate instead)";
    }
    {
      condition = lwAllowInsecurePred lwFakeBin;
      message = "andromeda: allowInsecurePredicate must permit librewolf-bin (any version)";
    }
    {
      condition = lwAllowInsecurePred lwFakeUnwrapped;
      message = "andromeda: allowInsecurePredicate must permit librewolf-bin-unwrapped (any version)";
    }
    {
      condition = !(lwAllowInsecurePred lwFakeOther);
      message = "andromeda: allowInsecurePredicate must not permit unrelated packages";
    }
  ];

  # ---------------------------------------------------------------------------
  # Waybar multi-WM assertions (T1-T8, per user)
  # Negative coverage (enforced by types, not run): listOf-enum rejects unknown
  # WMs; xdg.configFile collision prevents re-introducing programs.waybar.settings.
  # ---------------------------------------------------------------------------

  andromeda-waybar-wm-list-nonempty =
    mkCheck "andromeda-waybar-wm-list-nonempty"
    (pallonHome.my.hm.features.waybar.windowManagers != [])
    "andromeda pallon: waybar.windowManagers must be non-empty";

  andromeda-waybar-has-hyprland =
    mkCheck "andromeda-waybar-has-hyprland"
    (builtins.elem "hyprland" pallonHome.my.hm.features.waybar.windowManagers)
    "andromeda pallon: waybar.windowManagers must include hyprland";

  andromeda-waybar-has-sway =
    mkCheck "andromeda-waybar-has-sway"
    (builtins.elem "sway" pallonHome.my.hm.features.waybar.windowManagers)
    "andromeda pallon: waybar.windowManagers must include sway";

  andromeda-waybar-file-hyprland =
    mkCheck "andromeda-waybar-file-hyprland"
    (pallonFiles ? "waybar/config-hyprland")
    "andromeda pallon: xdg.configFile must contain waybar/config-hyprland";

  andromeda-waybar-file-sway =
    mkCheck "andromeda-waybar-file-sway"
    (pallonFiles ? "waybar/config-sway")
    "andromeda pallon: xdg.configFile must contain waybar/config-sway";

  andromeda-waybar-no-legacy-settings =
    mkCheck "andromeda-waybar-no-legacy-settings"
    ((pallonHome.programs.waybar.settings or null) == null
      || pallonHome.programs.waybar.settings == [])
    "andromeda pallon: programs.waybar.settings must not be set (use xdg.configFile instead)";

  andromeda-waybar-hypr-exec-flag =
    mkCheck "andromeda-waybar-hypr-exec-flag"
    (lib.any
      (s: lib.hasInfix "waybar -c" s && lib.hasInfix "waybar/config-hyprland" s)
      (pallonHome.wayland.windowManager.hyprland.settings.exec-once or []))
    "andromeda pallon: hyprland exec-once must launch waybar with -c .../waybar/config-hyprland";

  andromeda-sway-start-waybar =
    mkCheck "andromeda-sway-start-waybar"
    (pallonHome.my.hm.features.sway.startWaybar == true)
    "andromeda pallon: sway.startWaybar must default to true when sway is in waybar.windowManagers";

  andromeda-sway-config-has-waybar =
    mkAssertionCheck "check-andromeda-sway-config-has-waybar" [
      {
        condition = lib.hasInfix "waybar -c"
          (pallonFiles."sway/config".text or "");
        message = "andromeda pallon: sway/config must exec waybar with -c flag";
      }
      {
        condition = lib.hasInfix "waybar/config-sway"
          (pallonFiles."sway/config".text or "");
        message = "andromeda pallon: sway/config must reference waybar/config-sway";
      }
    ];

  andromeda-waybar-hypr-modules-left =
    mkCheck "andromeda-waybar-hypr-modules-left"
    (builtins.elem "hyprland/workspaces"
      (builtins.head
        (builtins.fromJSON
          (pallonFiles."waybar/config-hyprland".text or "[]"))).modules-left)
    "andromeda pallon: waybar/config-hyprland modules-left must contain hyprland/workspaces";

  andromeda-waybar-sway-modules-left =
    mkCheck "andromeda-waybar-sway-modules-left"
    (builtins.elem "sway/workspaces"
      (builtins.head
        (builtins.fromJSON
          (pallonFiles."waybar/config-sway".text or "[]"))).modules-left)
    "andromeda pallon: waybar/config-sway modules-left must contain sway/workspaces";

  earth-waybar-wm-list-nonempty =
    mkCheck "earth-waybar-wm-list-nonempty"
    (jeliasHome.my.hm.features.waybar.windowManagers != [])
    "earth jelias: waybar.windowManagers must be non-empty";

  earth-waybar-has-hyprland =
    mkCheck "earth-waybar-has-hyprland"
    (builtins.elem "hyprland" jeliasHome.my.hm.features.waybar.windowManagers)
    "earth jelias: waybar.windowManagers must include hyprland";

  earth-waybar-has-sway =
    mkCheck "earth-waybar-has-sway"
    (builtins.elem "sway" jeliasHome.my.hm.features.waybar.windowManagers)
    "earth jelias: waybar.windowManagers must include sway";

  earth-waybar-file-hyprland =
    mkCheck "earth-waybar-file-hyprland"
    (jeliasFiles ? "waybar/config-hyprland")
    "earth jelias: xdg.configFile must contain waybar/config-hyprland";

  earth-waybar-file-sway =
    mkCheck "earth-waybar-file-sway"
    (jeliasFiles ? "waybar/config-sway")
    "earth jelias: xdg.configFile must contain waybar/config-sway";

  earth-waybar-no-legacy-settings =
    mkCheck "earth-waybar-no-legacy-settings"
    ((jeliasHome.programs.waybar.settings or null) == null
      || jeliasHome.programs.waybar.settings == [])
    "earth jelias: programs.waybar.settings must not be set (use xdg.configFile instead)";

  earth-waybar-hypr-exec-flag =
    mkCheck "earth-waybar-hypr-exec-flag"
    (lib.any
      (s: lib.hasInfix "waybar -c" s && lib.hasInfix "waybar/config-hyprland" s)
      (jeliasHome.wayland.windowManager.hyprland.settings.exec-once or []))
    "earth jelias: hyprland exec-once must launch waybar with -c .../waybar/config-hyprland";

  earth-sway-start-waybar =
    mkCheck "earth-sway-start-waybar"
    (jeliasHome.my.hm.features.sway.startWaybar == true)
    "earth jelias: sway.startWaybar must default to true when sway is in waybar.windowManagers";

  earth-sway-config-has-waybar =
    mkAssertionCheck "check-earth-sway-config-has-waybar" [
      {
        condition = lib.hasInfix "waybar -c"
          (jeliasFiles."sway/config".text or "");
        message = "earth jelias: sway/config must exec waybar with -c flag";
      }
      {
        condition = lib.hasInfix "waybar/config-sway"
          (jeliasFiles."sway/config".text or "");
        message = "earth jelias: sway/config must reference waybar/config-sway";
      }
    ];

  earth-waybar-hypr-modules-left =
    mkCheck "earth-waybar-hypr-modules-left"
    (builtins.elem "hyprland/workspaces"
      (builtins.head
        (builtins.fromJSON
          (jeliasFiles."waybar/config-hyprland".text or "[]"))).modules-left)
    "earth jelias: waybar/config-hyprland modules-left must contain hyprland/workspaces";

  earth-waybar-sway-modules-left =
    mkCheck "earth-waybar-sway-modules-left"
    (builtins.elem "sway/workspaces"
      (builtins.head
        (builtins.fromJSON
          (jeliasFiles."waybar/config-sway".text or "[]"))).modules-left)
    "earth jelias: waybar/config-sway modules-left must contain sway/workspaces";
}
