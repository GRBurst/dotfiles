with (import <nixpkgs> {});
with import <nixpkgs/lib>;

let
  localpkgs = import ~/projects/nixpkgs/default.nix {};
  nixpkgs   = import <nixpkgs/nixos> {};
in {

  allowUnfree = true;

  # Install local packages with localpkgs.X,
  # e.g.: localpkgs.xcwd

  # Install a package collection with:
  # nix-env -iA common-packages -f "<nixpkgs>"
  # Uninstall all packages with
  # nix-env -e common-packages
  packageOverrides = pkgs: rec {

    # inherit pkgs;

    pidgin-with-plugins = pkgs.pidgin-with-plugins.override {
      plugins = [ pidginotr purple-facebook telegram-purple toxprpl pidginotr pidgin-skypeweb pidgin-opensteamworks ]; #localpkgs.purple-gnome-keyring ];
    };

    common-packages = buildEnv {

      name = "common-packages";

      paths = [
        # Linux tools
        binutils
        atop htop iotop
        wget netcat nmap
        psmisc
        hdparm hd-idle hddtemp
        pv xclip xorg.xkill unclutter-xfixes
        lm_sensors calc gksu
        haskellPackages.yeganesh
        numix-gtk-theme
        nitrogen scrot
        networkmanagerapplet
        dmenu rofi
        btrfs-progs
        dbus-map
        lsof
        nload
        p7zip
        speedtest-cli
        traceroute
        unzip
        xcwd
        xorg.xev
        gnome3.dconf

        # Terminal
        termite nix-zsh-completions

        # Filesystem
        gnome3.nautilus gnome3.gvfs
        ncdu fzf fasd file silver-searcher
        pmount
        tree gparted
        ntfs3g inotify-tools smartmontools
        exfat
        file
        gnome3.file-roller
        gptfdisk
        spaceFM	shared_mime_info desktop_file_utils
        usbutils

        # Office
        firefox
        # profile-sync-daemon
        libreoffice-fresh hunspell hunspellDicts.en-us aspell aspellDicts.de languagetool mythes
        samba cifs-utils
        sane-frontends
        gnome3.gedit
        filezilla
        jmtpfs
        libnotify
        simple-scan
        typora
        zathura
        texlive.combined.scheme-full
        biber
        pdfshuffler
        poppler_utils
        xournal

        # Programming
        ctags
        git tig
        neovim
        python27Packages.neovim # ensime
        python35Packages.neovim
        tmate
        #mosh
        meld

        # Media
        gimp
        inkscape 
        mate.atril
        mimeo
        mpv imv feh
        imagemagick7
        pamixer
        pavucontrol
        playerctl
        spotify
        gnome3.cheese
        xdg_utils

        # Security
        keepass
        keepassx-community
        keybase-gui

        # Communication
        pidgin-with-plugins
        qtox
        signal-desktop

      ];

    };

    dev-packages = buildEnv {

      inherit (nixpkgs.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "dev-packages";

      paths = [
        scala-packages
        cmakeCurses
        docker_compose
        graphviz gthumb
        irssi irssi_otr
        jetbrains.idea-community
        scalafmt
        swiProlog
      ];

    };

    scala-packages = buildEnv {

      inherit (nixpkgs.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "scala-packages";

      paths = [
        sbt
        scala
      ];

    };

    highres-packages = buildEnv {

      inherit (nixpkgs.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "highres-packages";

      paths = [
        common-packages

        brasero
        chromium
        clementine
        cryptsetup
        evince
        jbidwatcher
        # jdownloader
        josm
        kodi
        openjdk
        qutebrowser
        screen
        shotwell
        texmaker texstudio #lyx
        tor-browser-bundle-bin
        thunderbird
        vlc
        vokoscreen
        # (localpkgs.xmr-stak.override {cudaSupport = true;})
      ];

    };

    lowres-packages = buildEnv {

      inherit (nixpkgs.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "lowres-packages";

      paths = [
        common-packages
        claws-mail
        mutt
        llpp
        ranger
      ];

    };

    test-packages = buildEnv {

      inherit (nixpkgs.config.system.path) pathsToLink ignoreCollisions postBuild;
      name = "test-packages";

      paths = [
        (xmr-stak.override {cudaSupport = true; openclSupport = false; devDonationLevel = "0.0";})
        # (localpkgs.xmr-stak.override {cudaSupport = true;})
        # localpkgs.protonmail-bridge
        # localpkgs.jbidwatcher
        # localpkgs.iri
        # localpkgs.purple-gnome-keyring
      ];

    };

    # services.psd = {
    #   enable  = true;
    #   users   = [ "jelias" ];
    # };

    # firefox = {
    #   enableGoogleTalkPlugin  = false;
    #   enableAdobeFlash        = false;
    #   enableAdobeFlashDRM     = true;
    #   icedtea                 = true;
    # };

   # chromium = {
   #   enablePepperPDF = true;
   #   enableWideVine = false;
   # };

  };

}
