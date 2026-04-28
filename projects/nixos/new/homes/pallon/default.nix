{
  config,
  pkgs,
  ...
}: {
  imports = [
    ../../modules/home-manager
  ];

  home.username = "pallon";
  home.homeDirectory = "/home/pallon";
  home.stateVersion = "25.11";

  # -- Enable User Bundles --
  my.hm = {
    bundles = {
      desktop.enable = true;
      dev.enable = true;
      extras.enable = true;
      general.enable = true;
      laptop.enable = true;
      media.enable = true;
    };
    features = {
      alacritty.enable = true;
      env.enable = true;
      git = {
        enable = true;
        name = "GRBurst";
        email = "GRBurst@protonmail.com";
      };
      i3 = {
        enable = true;
        defaultOutputs.primary = "eDP-1";
        commonStartupCommands = ["nm-applet" "protonmail-bridge -n"];
        localStartupCommands = ["cbatticon" "blueman-applet"];
        statusBar.networkDevices = [
          {
            device = "enp2s0f0";
            type = "wired";
          }
          {
            device = "wlp3s0";
            type = "wifi";
          }
        ];
      };
      misc.enable = true;
      nvf.enable = true;
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
    NIXOS_OZONE_WL = "1";
  };
  home.sessionPath = [
    "$HOME/projects/bin:$PATH"
    "$HOME/local/bin:$PATH"
    "$HOME/.local/bin:$PATH"
  ];
}
