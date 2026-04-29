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
  i3ConfigText = pallonHome.xdg.configFile."i3/config".text;
  i3ConfigFiles = builtins.attrValues pallonHome.xdg.configFile;
  earthFiles = jeliasHome.xdg.configFile or {};
  earthI3ConfigText = earthFiles."i3/config".text or "";
  earthI3StatusText = earthFiles."i3status-rust/config.toml".text or "";
  pallonNvfLua = pallonHome.programs.nvf.settings.vim.luaConfigRC.custom-functions.data or "";
  jeliasNvfLua = jeliasHome.programs.nvf.settings.vim.luaConfigRC.custom-functions.data or "";
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

  mkCheck = name: cond: msg:
    mkAssertionCheck "check-${name}" [
      {
        condition = cond;
        message = msg;
      }
    ];
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

  andromeda-dm-sddm =
    mkCheck "andromeda-dm-sddm"
    cfgs.andromeda.config.services.displayManager.sddm.enable
    "andromeda must still use sddm";

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
      condition = andromeda.stylix.enable == true && andromeda.stylix.autoEnable == false;
      message = "andromeda: style must keep Stylix enabled only as an explicit migration target";
    }
    {
      condition = earth.stylix.enable == true && earth.stylix.autoEnable == false;
      message = "earth: style must keep Stylix enabled only as an explicit migration target";
    }
    {
      condition = andromeda.stylix.base16Scheme.base00 == "ffffff" && earth.stylix.base16Scheme.base00 == "ffffff";
      message = "Stylix migration palette must default to Enfocado light";
    }
    {
      condition = pallonHome.my.hm.features.style.enable == true && jeliasHome.my.hm.features.style.enable == true;
      message = "both Home Manager users must enable dynamic style";
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
      condition = lib.hasInfix "my-style-switch" pallonHome.services.darkman.scripts."theme-dispatch";
      message = "pallon darkman must call the shared style dispatcher";
    }
    {
      condition = lib.hasInfix "my-style-switch" jeliasHome.services.darkman.scripts."theme-dispatch";
      message = "jelias darkman must call the shared style dispatcher";
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
      condition = lib.hasInfix "set $theme_bg #ffffff" pallonFiles."my/theme/current/i3.conf".text;
      message = "pallon i3 current theme must default to Enfocado light";
    }
    {
      condition = lib.hasInfix "background-color: #ffffff" pallonFiles."my/theme/current/waybar.css".text;
      message = "pallon Waybar current theme must default to Enfocado light";
    }
    {
      condition = lib.hasInfix "col.active_border = rgba(0064e4ee)" pallonFiles."my/theme/current/hyprland.conf".text;
      message = "pallon Hyprland current theme must default to Enfocado light";
    }
    {
      condition = builtins.any (p: (p.pname or p.name or "") == "my-style-switch") pallonHome.home.packages;
      message = "pallon home must include the style dispatcher package";
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
      condition = lib.hasInfix ''theme = "slick"'' earthI3StatusText;
      message = "earth: i3status-rust must use slick theme";
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
}
