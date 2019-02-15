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
        arandr
        acpi
        avahi
        binutils
        atop htop iotop
        arandr
        wget netcat nmap
        psmisc
        hdparm hd-idle hddtemp
        pv xclip xorg.xkill unclutter-xfixes
        lm_sensors calc gksu
        gnome3.dconf
        haskellPackages.yeganesh
        gnumake
        nitrogen scrot
        networkmanagerapplet
        pwgen
        rofi #dmenu 
        btrfs-progs
        dbus-map
        lsof
        #mosh
        nload
        pciutils
        p7zip
        speedtest-cli
        traceroute
        unzip
        xcwd
        xorg.xdpyinfo
        xorg.xev
        xorg.xmodmap
        lxappearance
        gnome3.adwaita-icon-theme
        vanilla-dmz
        wireshark

        # Security
        gnome3.gnome_keyring gnome3.seahorse libsecret
        openssl
        keepass
        keepassx-community
        keybase-gui

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
        # gnome3.file-roller # mimeinfo collides with nautilus
        gptfdisk
        spaceFM
        shared_mime_info
        desktop_file_utils
        usbutils

        # Office
        calibre
        firefox
        # profile-sync-daemon
        libreoffice-fresh hunspell hunspellDicts.en-us aspell aspellDicts.de languagetool mythes
        samba cifs-utils
        sane-frontends
        gcolor3
        gnome3.gedit
        filezilla
        jmtpfs
        libnotify
        networkmanager_dmenu
        simple-scan
        typora
        zathura
        texlive.combined.scheme-full
        # biber # collides texlive full
        pdfshuffler
        poppler_utils
        xournal

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

        # Communication
        pidgin-with-plugins
        qtox
        signal-desktop
        irssi_otr #irssi

      ];

    };

    dev-packages = buildEnv {

      inherit (nixpkgs.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "dev-packages";

      paths = [
        scala-packages

        ctags
        git tig
        neovim
        python27Packages.neovim # ensime
        python36Packages.neovim
        tmate
        meld

        cmakeCurses
        docker_compose
        entr
        ghc
        graphviz
        gthumb
        jetbrains.idea-community
        nodejs-10_x
        nixops
        nox

        swiProlog
        vscode
      ];

    };

    scala-packages = buildEnv {

      inherit (nixpkgs.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "scala-packages";

      paths = [
        ammonite
        sbt
        scala
        scalafmt
      ];

    };

    ssd-packages = buildEnv {

      inherit (nixpkgs.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "ssd-packages";

      paths = [
        nvme-cli
      ];

    };

    laptop-packages = buildEnv {

      inherit (nixpkgs.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "laptop-packages";

      paths = [
        # libqmi
        blueman
        cbatticon
        light
        linuxPackages.tp_smapi
        linuxPackages.acpi_call
        tlp
      ];

    };


    highres-packages = buildEnv {

      inherit (nixpkgs.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "highres-packages";

      paths = [
        brasero
        (chromium.override { enablePepperFlash = false; enableWideVine = false;})
        clementine
        cryptsetup
        evince
        okular
        jbidwatcher
        # jdownloader
        josm
        kodi
        openjdk
        qutebrowser
        screen
        skypeforlinux
        shotwell
        texmaker texstudio #lyx
        tor-browser-bundle-bin # prevented highres from upgrade
        thunderbird
        protonmail-bridge
        vlc
        vokoscreen
      ];

    };

    lowres-packages = buildEnv {

      inherit (nixpkgs.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "lowres-packages";

      paths = [
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
        # localpkgs.protonmail-bridge
        # localpkgs.jbidwatcher
        # localpkgs.iri
        # localpkgs.purple-gnome-keyring
      ];

    };

    mining-packages = buildEnv {

      inherit (nixpkgs.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "mining-packages";

      paths = [
        # (localpkgs.xmr-stak.override {cudaSupport = true;})
        (xmr-stak.override {cudaSupport = true; openclSupport = false; devDonationLevel = "0.0";})
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
    #   enablePepperFlash = true;
    #   enablePepperPDF = true;
    #   enableWideVine = false;
    # };

  };

}
