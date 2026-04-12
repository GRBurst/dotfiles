{ config, pkgs, ... }: {
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
      git.enable = true;
      misc.enable = true;
      zsh.enable = true;
      kitty.enable = true;
    };
  };

  home.sessionVariables = {
    EDITOR = "nvim";
    BROWSER = "librewolf";
    NIXOS_OZONE_WL = "1";
  };
}
