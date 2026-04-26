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
      desktop = {
        enable = true;
        wayland = true;
        x11 = true;
      };
      dev.enable = true;
      extras.enable = true;
      general.enable = true;
      laptop.enable = true;
      media.enable = true;
    };
    features = {
      alacritty.enable = true;
      env.enable = true;
      hyprland = {
        enable = true;
        nvidia = false;
        monitors = [
          {
            name = "eDP-1";
            resolution = "1920x1080";
            position = "0x0";
            scale = 1.0;
          }
        ];
      };
      git = {
        enable = true;
        name = "GRBurst";
        email = "GRBurst@protonmail.com";
      };
      gnome.enable = true;
      misc.enable = true;
      nvf.enable = true;
      waybar = {
        enable = true;
        battery = true;
      };
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
    "$HOME/projects/bin:$PATH"
    "$HOME/local/bin:$PATH"
    "$HOME/.local/bin:$PATH"
  ];
}
