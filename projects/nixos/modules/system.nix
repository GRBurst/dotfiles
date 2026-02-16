{ config, pkgs, ... }:

{
  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  # These are installed system-wide
  environment = {
    systemPackages = with pkgs; [
      neovim vim
      git
      wget
      curl

      protonvpn-cli protonvpn-gui protonmail-bridge
      hdparm
      adapta-gtk-theme adapta-kde-theme
    ];

    shellAliases = {
      l = "ls -l";
      t = "tree -C"; # -C is for color=always
    };

    #wget "https://github.com/chenkelmann/neo2-awt-hack/blob/master/releases/neo2-awt-hack-0.4-java8oracle.jar?raw=true" -O ~/local/jars/neo2-awt-hack-0.4-java8oracle.jar
    # variables = {
      # EDITOR = "nvim";
      # SUDO_EDITOR = "nvim";
      # VISUAL = "nvim";

      # BROWSER = "librewolf";

      # _JAVA_OPTIONS = "-Xms1G -Xmx4G -Xss16M -XX:MaxMetaspaceSize=2G -XX:+UseCompressedOops -Dawt.useSystemAAFontSettings=lcd";
      #SBT_OPTS="$SBT_OPTS -Xms2G -Xmx8G -Xss4M -XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC";
      # SBT_OPTS="-Xms1G -Xmx4G -Xss16M";

      # AUTOSSH_GATETIME = "0";

      # DE = "gnome";
      # XDG_CURRENT_DESKTOP = "gnome";

      # GTK_IM_MODULE = "ibus";
      # XMODIFIERS = "@im=ibus";
      # QT_IM_MODULE = "ibus";

      # _JAVA_AWT_WM_NONREPARENTING = "1";

      # AWT_TOOLKIT = "MToolkit";
      # GDK_USE_XFT = "1";

      # QT_STYLE_OVERRIDE = "gtk2";
      # QT_QPA_PLATFORMTHEME = "gtk2";

      # _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
      # QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      # QT_AUTO_SCREEN_SCALE_FACTOR = "0";
      # QT_SCALE_FACTOR = "1";
      # GDK_SCALE = "2";
      # GDK_DPI_SCALE = "0.5";
      # QT_FONT_DPI = "192";
      # QT_STYLE_OVERRIDE="Adapta";
    # };
  };
}
