{
  config,
  lib,
  ...
}: let
  cfg = config.my.hm.features.env;
in {
  options.my.hm.features.env.enable = lib.mkEnableOption "Environment Variables";

  config = lib.mkIf cfg.enable {
    home.sessionVariables = {
      EDITOR = "nvim";
      SUDO_EDITOR = "nvim";
      VISUAL = "nvim";
      BROWSER = "librewolf";

      SBT_OPTS = "-Xms1G -Xmx4G -Xss16M";
      _JAVA_AWT_WM_NONREPARENTING = "1";
      AWT_TOOLKIT = "MToolkit";

      AUTOSSH_GATETIME = "0";

      GTK_IM_MODULE = "ibus";
      XMODIFIERS = "@im=ibus";
      QT_IM_MODULE = "ibus";

      QT_QPA_PLATFORMTHEME = "gnome";
      XCURSOR_SIZE = "64";
      NIXOS_OZONE_WL = "1";
    };
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableZshIntegration = true;
    };
  };
}
