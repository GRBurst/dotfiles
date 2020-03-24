with (import <nixos-unstable> {});
with import <nixos-unstable/lib>;

let
  localpkgs = import ~/projects/nixpkgs/default.nix {};
  unstable  = import <nixos-unstable/nixos> {};
in {

  allowUnfree = true;
  oraclejdk.accept_license = true;
  android_sdk.accept_license = true;

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
        bc calc
        binutils
        cryptsetup
        linuxPackages.cpupower
        psmisc
        hdparm hd-idle hddtemp
        lm_sensors
        gksu
        gnumake
        openjdk
        pwgen
        rofi rofi-systemd #dmenu
        btrfs-progs
        dbus-map
        lsof
        #mosh
        pciutils
        p7zip
        pv
        screen
        scrot
        unzip # zip

        # x-server
        xcwd
        xclip
        unclutter-xfixes 
        xorg.xdpyinfo xorg.xev xorg.xmodmap xorg.xkill xorg.xwininfo
        vanilla-dmz # x cursor

        # Security
        gnome3.gnome-keyring gnome3.libgnome-keyring gnome3.seahorse libsecret
        openssl
        keepass
        keepassx-community
        keybase-gui
        
        # Network
        bind
        wget
        netcat
        nmap
        miniserve
        networkmanagerapplet
        networkmanager_dmenu
        nload
        speedtest-cli
        traceroute
        whois
        wireshark

        # Terminal
        termite nix-zsh-completions
        haskellPackages.yeganesh

        # Filesystem
        gnome3.nautilus gnome3.gvfs
        ncdu fzf fasd file silver-searcher
        fuse-common
        bindfs
        pmount
        tree gparted
        broot
        ntfs3g
        inotify-tools
        smartmontools
        exfat
        # gnome3.file-roller # mimeinfo collides with nautilus
        gptfdisk
        spaceFM
        shared_mime_info
        desktop_file_utils
        usbutils

        # Office
        calibre
        firefox profile-sync-daemon
        libreoffice-still hunspell hunspellDicts.en-us hunspellDicts.de-de languagetool mythes
        samba cifs-utils
        sane-frontends
        gcolor3
        gnome3.gedit
        jmtpfs
        libnotify
        qrencode
        simple-scan
        typora
        zathura
        texlive.combined.scheme-full
        thunderbird protonmail-bridge
        # biber # collides texlive full
        pdftk #pdfshuffler
        pdfsandwich
        poppler_utils
        xournal

        # Media
        feh imv nitrogen 
        gimp
        inkscape 
        mate.atril
        mimeo
        mpv
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
        signal-desktop

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

        atom
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
        # google-chrome
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
        avidemux
        audacity
        brasero
        (chromium.override { enablePepperFlash = false; enableWideVine = false;})
        clementine
        evince
        fwupd # bios + firmware updates
        guvcview
        irssi
        okular
        jbidwatcher
        # jdownloader
        josm
        kdeApplications.kdenlive
        peek # record gif videos || green-recorder / gifcurry / screenToGif
        kodi
        linphone # ekiga -> breaks on 2019-12-09
        qutebrowser
        qtox
        skypeforlinux
        shotwell
        tesseract # open source ocr engine
        # texmaker #breaks on 2019-10-22
        texstudio #lyx
        # tor-browser-bundle-bin # -> cannot be build
        vlc
        vokoscreen # keymon -> abandoned
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
        discord
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
