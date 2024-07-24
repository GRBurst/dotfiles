{ config, pkgs, ... }:

{
  home.username = "jelias";
  home.homeDirectory = "/home/jelias";


  programs.alacritty = {
    enable = true;
    settings = {
      env.TERM = "xterm-256color";
      font = {
        size = 12;
      };
      scrolling.multiplier = 5;
      selection.save_to_clipboard = true;
    };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin"
    '';

  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        xdg-desktop-portal
        xdg-desktop-portal-gtk
      ];
      configPackages = [ pkgs.gnome.gnome-session ];
    };
    mime.enable = true;
  };
  # xdg.mimeApps = {
  #   enable = true;
  #   associations.added = {
  #     "application/pdf" = ["org.gnome.Evince.desktop"];
  #   };
  #   defaultApplications = {
  #     "application/pdf" = ["org.gnome.Evince.desktop"];
  #   };
  # };

  home.packages = with pkgs; [
  	#####
	# COMMON
	#####

        # Linux tools
        arandr
        acpi
        avahi
        atop htop iotop
        bc calc
        beep
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
        scrot flameshot
        speechd
        # unzip zip
        zenity
        pistol

        # x-server
        xcwd
        xclip
        unclutter-xfixes 
        xorg.xdpyinfo xorg.xev xorg.xmodmap xorg.xkill xorg.xwininfo xorg.xhost
        vanilla-dmz # x cursor
        xsettingsd
        libsForQt5.qtstyleplugins

        # Security
        gnome-keyring libgnome-keyring seahorse libsecret
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
        # magic-wormhole # broken since 2022-08-31
        ngrok
        nload nethogs
        speedtest-cli
        mtr
        inetutils
        vpn-slice
        socat
        sshuttle # vpn through ssh
        wireshark
        networkmanagerapplet
        networkmanager_dmenu

        # Terminal
        termite alacritty nix-zsh-completions
        haskellPackages.yeganesh
        tldr
        wezterm

        # Filesystem
        nvme-cli
        nautilus gnome.gvfs
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
        # gnome.file-roller # mimeinfo collides with nautilus
        gptfdisk
        spaceFM
        shared-mime-info
        desktop-file-utils
        usbutils
        ripgrep


        # Office
        # calibre broken on 2022-04-10
        # etesync-dav # broken since 2023-01-01
        exif
        # firefox profile-sync-daemon
        # librewolf # (librewolf.override { wmClass = "browser"; })
        profile-sync-daemon
        libreoffice-still hunspell hunspellDicts.en-us hunspellDicts.de-de languagetool mythes
        samba cifs-utils
        gcolor3
        gedit
        jmtpfs
        qrencode
        qsyncthingtray
        simple-scan
        # typora # breaks on 2020-07-08
        zathura
        thunderbird birdtray
        # texlive.combined.scheme-full
        # biber # collides texlive full
        # pdftk #pdfshuffler
        # pdfsandwich pdfsam-basic pdfarranger
        poppler_utils
        xournal

        # Media
        blueman
        flatpak
        feh imv nitrogen 
        (gimp-with-plugins.override { 
          plugins = with gimpPlugins; [ 
            fourier
            # resynthesizer # broken since 2023-03-20
            # gmic
          ]; 
        })
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
        cheese
        xdg-utils
        ffmpeg-full
        seafile-client
        seafile-shared
        # (ffmpeg-full.override { nonfreeLicensing = true;})

        # Communication
        # pidgin-with-plugins
        # element-desktop
        # schildichat-desktop
        signal-desktop
        wire-desktop
        tdesktop
        jitsi jitsi-meet
        ausweisapp

        # Themes
        breeze-gtk breeze-icons breeze-qt5 
        adwaita-qt adwaita-icon-theme 
        papirus-icon-theme
        dconf
        dconf-editor
        lxqt.lxqt-config
        lxappearance



	#####
	# DEV
	#####
        # pulsar
        # ctags
        gdb
        git tig gh hub gitRepo
        neovim coursier # coursier needed for neovim plugins
        # python27Packages.pynvim # ensime
        python3Packages.pynvim
        tmate
        meld
        kdiff3
        difftastic
        jq
        yq-go
        discord-ptb
        devbox

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




	#####
	## HIGHRES
	#####

        # avidemux broken
        audacity
        brasero
        (chromium.override { enableWideVine = false; })
        brave
        clementine
        deadd-notification-center
        evince
        epson-escpr2 sane-airscan brscan4
        fwupd # bios + firmware updates
        guvcview
        # gnomeExtensions.jiggle
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
        teams-for-linux
        discord

  ];

  home.stateVersion = "23.11";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
