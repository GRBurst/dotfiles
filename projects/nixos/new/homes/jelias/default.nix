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
      gnome.enable = true;
      nvf.enable = true;
      misc.enable = true;
      shellAliases.enable = true;
      waybar.enable = true;
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
