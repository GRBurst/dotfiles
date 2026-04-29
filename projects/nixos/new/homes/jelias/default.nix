{pkgs, ...}: {
  imports = [
    ../../modules/home-manager
  ];

  home.username = "jelias";
  home.homeDirectory = "/home/jelias";
  home.stateVersion = "25.11";

  my.hm = {
    bundles = {
      desktop = {
        enable = true;
        wayland = true;
        x11 = true;
      };
      dev.enable = true;
      extras = {
        enable = true;
        gpuMonitor = "nvidia";
      };
      general.enable = true;
      media.enable = true;
    };
    features = {
      alacritty = {
        enable = true;
        scrollingMultiplier = 5;
        saveSelectionToClipboard = true;
      };
      env.enable = true;
      hyprland = {
        enable = true;
        nvidia = true;
        monitors = [
          {
            name = "DP-2";
            resolution = "3840x2160";
            position = "0x0";
            scale = 2.0;
          }
          {
            name = "DP-4";
            resolution = "3840x2160";
            position = "1920x0";
            scale = 2.0;
          }
        ];
      };
      git = {
        enable = true;
        name = "GRBurst";
        email = "GRBurst@protonmail.com";
      };
      i3 = {
        enable = true;
        commonStartupCommands = [
          "ETESYNC_URL=https://scal.metacosmos.space etesync-dav"
          "syncthingtray"
          "nm-applet"
          "protonvpn-app"
          "protonmail-bridge -n"
          "pasystray"
        ];
        display = {
          primaryOutput = "DP-2";
          secondaryOutput = "DP-4";
        };
        extraPackages = with pkgs; [
          brightnessctl
          pasystray
          pavucontrol
          syncthingtray
        ];
        statusBar = {
          iconOverrides.gpu = "🎮";
          disk = {
            format = "$icon$free.eng(w:2)";
            formatAlt = "$icon$available.eng(w:2)/$total.eng(w:2)";
            iconOverrides.disk_drive = "🏠";
          };
          memory = {
            format = " $icon$mem_avail.eng(prefix:Gi)";
            formatAlt = " $icon$swap_used_percents.eng(w:2)";
          };
          cpu.format = " $icon$utilization";
          gpu = "nvidia";
          gpuFormat = " $icon$clocks $power $memory";
          gpuInterval = null;
          sound = {
            sinkFormat = " $icon{$volume|}";
            sourceFormat = " $icon{$volume|}";
            clickCommand = "pavucontrol";
          };
          networkDevices = [
            {
              device = "enp8s0";
              type = "wired";
              format = "{$graph_down}⮃{$graph_up}";
              formatAlt = " $ip";
            }
          ];
          timeFormat = "%d/%m %R";
          timezone = null;
        };
      };
      gnome.enable = true;
      nvf.enable = true;
      misc.enable = true;
      shellAliases.enable = true;
      style.enable = true;
      waybar.enable = true;
      yazi.enable = true;
      zsh.enable = true;
      kitty.enable = true;
    };
  };

  home.sessionVariables = {
    LC_ALL = "en_US.UTF-8";
    LANG = "en_US.UTF-8";

    SUDO_EDITOR = "nvim";
    EDITOR = "nvim";
    VISUAL = "nvim";

    BROWSER = "librewolf";
  };

  home.sessionPath = [
    "$HOME/bin:$PATH"
    "$HOME/projects/bin:$PATH"
    "$HOME/local/bin:$PATH"
    "$HOME/.local/bin:$PATH"
  ];
}
