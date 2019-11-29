with (import <nixos-unstable> {});
with import <nixos-unstable/lib>;

let
  localpkgs = import ~/projects/nixpkgs/default.nix {};
  unstable  = import <nixos-unstable/nixos> {};
in {

  allowUnfree = true;
  oraclejdk.accept_license = true;

  # Install local packages with localpkgs.X,
  # e.g.: localpkgs.xcwd

  # Install a package collection with:
  # nix-env -iA common-packages -f "<nixos-unstable>"
  # Uninstall all packages with
  # nix-env -e common-packages
  packageOverrides = pkgs: rec {

    # inherit pkgs;

    pidgin-with-plugins = pkgs.pidgin-with-plugins.override {
      plugins = [ pidginotr purple-facebook telegram-purple toxprpl pidginotr pidgin-skypeweb pidgin-opensteamworks ];
      # plugins = [ pidginotr purple-facebook telegram-purple toxprpl pidginotr pidgin-skypeweb pidgin-opensteamworks localpkgs.purple-gnome-keyring ];
    };

    common-packages = buildEnv {

      inherit (unstable.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "common-packages";

      paths = [
        # Linux tools
        arandr
        acpi
        avahi
        atop htop iotop
        bc
        bind
        binutils
        linuxPackages.cpupower
        wget netcat nmap
        psmisc
        hdparm hd-idle hddtemp
        pv xclip xorg.xkill unclutter-xfixes xorg.xwininfo
        lm_sensors calc gksu
        haskellPackages.yeganesh
        gnumake
        nitrogen scrot
        networkmanagerapplet
        pwgen
        rofi rofi-systemd #dmenu
        btrfs-progs
        dbus-map
        lsof
        #mosh
        nload
        pciutils
        p7zip
        speedtest-cli
        traceroute
        # zip
        unzip
        xcwd
        xorg.xdpyinfo
        xorg.xev
        xorg.xmodmap
        gnome3.adwaita-icon-theme
        vanilla-dmz
        wireshark

        # Security
        gnome3.gnome-keyring gnome3.libgnome-keyring gnome3.seahorse libsecret
        openssl
        keepass
        keepassx-community
        keybase-gui

        # Terminal
        termite nix-zsh-completions

        # Filesystem
        gnome3.nautilus gnome3.gvfs
        ncdu fzf fasd file silver-searcher
        fuse-common
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
        profile-sync-daemon
        libreoffice-still hunspell hunspellDicts.en-us hunspellDicts.de-de languagetool mythes
        samba cifs-utils
        sane-frontends
        gcolor3
        gnome3.gedit
        jmtpfs
        libnotify
        networkmanager_dmenu
        qrencode
        simple-scan
        typora
        zathura
        texlive.combined.scheme-full
        # biber # collides texlive full
        pdftk #pdfshuffler
        pdfsandwich
        tesseract
        poppler_utils
        xournal

        # Media
        avidemux
        audacity
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
        ffmpeg-full
        # (ffmpeg-full.override { nonfreeLicensing = true;})

        # Communication
        pidgin-with-plugins
        qtox
        signal-desktop
        irssi

        # Themes
        breeze-gtk breeze-icons breeze-qt5 
        adwaita-qt gnome3.adwaita-icon-theme 
        papirus-icon-theme
        gnome3.dconf
        gnome3.dconf-editor
        lxqt.lxqt-config
        lxappearance

      ];

    };

    dev-packages = buildEnv {

      inherit (unstable.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "dev-packages";

      paths = [
        scala-packages

        ctags
        gdb
        git tig gitRepo
        neovim
        python27Packages.pynvim # ensime
        python37Packages.pynvim
        tmate
        meld
        kdiff3

        cmakeCurses
        docker_compose
        entr
        ghc
        graphviz
        gthumb
        filezilla
        jetbrains.idea-community
        nodejs-10_x
        nixops
        nox

        swiProlog
        vscode

        brave
        google-chrome
        firefox-devedition-bin
      ];

    };

    scala-packages = buildEnv {

      inherit (unstable.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "scala-packages";

      paths = [
        ammonite
        sbt
        scala
        # scalafmt #-> cannot be build
        visualvm
      ];

    };

    ssd-packages = buildEnv {

      inherit (unstable.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "ssd-packages";

      paths = [
        nvme-cli
      ];

    };

    laptop-packages = buildEnv {

      inherit (unstable.config.system.path) pathsToLink ignoreCollisions postBuild;
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

      inherit (unstable.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "highres-packages";

      paths = [
        brasero
        (chromium.override { enablePepperFlash = false; enableWideVine = false;})
        clementine
        cryptsetup
        evince
        fwupd # bios + firmware updates
        guvcview
        okular
        jbidwatcher
        # jdownloader
        josm
        peek # record gif videos || green-recorder / gifcurry / screenToGif
        kodi
        linphone ekiga
        openjdk
        protonmail-bridge
        qutebrowser
        screen
        skypeforlinux
        shotwell
        texmaker texstudio #lyx
        # tor-browser-bundle-bin # -> cannot be build
        thunderbird
        vlc
        vokoscreen keymon
        zoom-us
      ];

    };

    lowres-packages = buildEnv {

      inherit (unstable.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "lowres-packages";

      paths = [
        claws-mail
        mutt
        llpp
        ranger
      ];

    };

    gaming-packages = buildEnv {

      inherit (unstable.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "gaming-packages";

      paths = [
        runelite
        linux-steam-integration
        xboxdrv
        # steam
        # steam-run
      ];

    };

    test-packages = buildEnv {

      inherit (unstable.config.system.path) pathsToLink ignoreCollisions postBuild;
      name = "test-packages";

      paths = [
        # localpkgs.protonmail-bridge
        # localpkgs.jbidwatcher
        # localpkgs.iri
        # localpkgs.purple-gnome-keyring
      ];

    };

    mining-packages = buildEnv {

      inherit (unstable.config.system.path) pathsToLink ignoreCollisions postBuild;
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
