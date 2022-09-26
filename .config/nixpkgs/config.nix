with (import <nixos-stable> {});
with (import <nixos-unstable> {});
with import <nixos-unstable/lib>;

let
  localpkgs = import ~/projects/nixpkgs/default.nix {};
  unstable  = import <nixos-unstable/nixos> {};
  stable  = import <nixos-stable/nixos> {};
in {

  permittedInsecurePackages = [
    "openssl-1.0.2u"
    "adobe-reader-9.5.5-1"
  ];
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
      plugins = [ purple-plugin-pack purple-discord purple-facebook purple-hangouts purple-slack telegram-purple toxprpl pidginotr pidginotr pidgin-skypeweb pidgin-opensteamworks localpkgs.purple-gnome-keyring ];
    };

    vscode-liveshare = pkgs.vscode-with-extensions.override {
      vscodeExtensions = [ pkgs.vscode-extensions.ms-vsliveshare.vsliveshare ];
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
        dmidecode
        psmisc
        hdparm hd-idle hddtemp
        lm_sensors
        gnumake
        pwgen
        rofi rofi-systemd #dmenu
        btrfs-progs
        dbus-map
        lsof
        #mosh
        pciutils
        # p7zip -> abandoned (2020-05-18)
        pv
        screen
        scrot
        # unzip zip

        # x-server
        xcwd
        xclip
        unclutter-xfixes 
        xorg.xdpyinfo xorg.xev xorg.xmodmap xorg.xkill xorg.xwininfo xorg.xhost
        vanilla-dmz # x cursor
        xsettingsd
        libsForQt5.qtstyleplugins

        # Security
        gnome3.gnome-keyring gnome3.libgnome-keyring gnome3.seahorse libsecret
        openssl
        keepass
        keepassxc
        keybase-gui

        # Network
        bind
        wget
        netcat
        nmap
        miniserve
        magic-wormhole
        ngrok
        nload nethogs
        speedtest-cli
        traceroute mtr
        inetutils
        vpn-slice
        sshuttle # vpn through ssh
        wireshark
        networkmanagerapplet
        networkmanager_dmenu

        # Terminal
        termite alacritty nix-zsh-completions
        haskellPackages.yeganesh
        tldr

        # Filesystem
        gnome3.nautilus gnome3.gvfs
        ncdu du-dust
        duf # du alternative
        sd # sed alternative
        fzf fasd file silver-searcher
        fuse-common
        autossh sshfs-fuse
        direnv
        lsyncd
        bindfs
        bat # cat alternative
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
        shared-mime-info
        desktop-file-utils
        usbutils
        ripgrep


        # Office
        # calibre broken on 2022-04-10
        etesync-dav
        exif
        # firefox profile-sync-daemon
        librewolf # (librewolf.override { wmClass = "browser"; })
        profile-sync-daemon
        libreoffice-still hunspell hunspellDicts.en-us hunspellDicts.de-de languagetool mythes
        samba cifs-utils
        gcolor3
        gnome3.gedit
        jmtpfs
        qrencode
        qsyncthingtray
        simple-scan
        # typora # breaks on 2020-07-08
        zathura
        texlive.combined.scheme-full
        thunderbird birdtray protonmail-bridge protonvpn-gui
        # biber # collides texlive full
        pdftk #pdfshuffler
        pdfsandwich pdfsam-basic pdfarranger
        poppler_utils
        xournal

        # Media
        blueman
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
        ponymix
        spotify
        gnome3.cheese
        xdg_utils
        ffmpeg-full
        seafile-client
        seafile-shared
        # (ffmpeg-full.override { nonfreeLicensing = true;})

        # Communication
        # pidgin-with-plugins
        element-desktop
        schildichat-desktop
        signal-desktop
        tdesktop

        # Themes
        breeze-gtk breeze-icons breeze-qt5 
        adwaita-qt gnome3.adwaita-icon-theme 
        papirus-icon-theme
        dconf
        gnome3.dconf-editor
        lxqt.lxqt-config
        lxappearance

        # Fonts
        # localpkgs.bront_fonts

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
        git tig gh hub gitRepo
        neovim coursier # coursier needed for neovim plugins
        # python27Packages.pynvim # ensime
        python37Packages.pynvim
        tmate
        meld
        kdiff3
        difftastic
        jq

        # purescript
        # nodePackages.purescript-language-server

        cmakeCurses
        docker-compose
        entr
        ghc
        graphviz
        gthumb
        filezilla
        jetbrains.idea-community
        nodejs
        # nixops # breaks 2021-01-14
        nox

        # swiProlog
        #vscodium
        vscode-liveshare

        brave
      ];

    };

    nix-packages = buildEnv {

      inherit (unstable.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "nix-packages";

      paths = [
        # nixops
        nix-index
        nix-prefetch-git
        nox
        patchelf
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
        brillo # control keyboard led
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
        (chromium.override { enableWideVine = false; })
        clementine
        deadd-notification-center
        evince
        epson-escpr2 sane-airscan brscan4
        fwupd # bios + firmware updates
        guvcview
        irssi
        kvirc
        okular
        # jbidwatcher
        # jdownloader
        josm
        libsForQt5.kdenlive
        libnotify
        nextcloud-client
        # notify-osd-customizable
        peek # record gif videos || green-recorder / gifcurry / screenToGif
        # kodi
        # linphone -> breaks 2021-01-06
        # ekiga -> breaks on 2019-12-09
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
        jellyfin-media-player
        zoom-us
      ];

    };

    lowres-packages = buildEnv {

      inherit (unstable.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "lowres-packages";

      paths = [
        claws-mail
        dunst
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
        appimage-run
        # runelite
        # linux-steam-integration -> broken (2020-05-18)
        lutris
        # heroic
        discord
        xboxdrv
        steam
        runescape
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

    work-packages = buildEnv {

      inherit (unstable.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "work-packages";

      paths = [
        _1password-gui
        slack
        teams
        kafkacat
        notion-app-enhanced
        # kafkactl
        # plantuml
        # xmlcopyeditor
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

  };

  librewolf = {
    enableTridactylNative = true;
  };

}
