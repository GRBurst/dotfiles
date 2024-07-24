{ config, pkgs, ... }:

{
  home.username = "jelias";
  home.homeDirectory = "/home/jelias";

  # set cursor size and dpi for 4k monitor
  # xresources.properties = {
  #   "Xcursor.size" = 64;
  #   "Xft.dpi" = 192;
  # };

  # basic configuration of git, please change to your own
  programs.git = {
    enable = true;
    userName = "GRBurst";
    userEmail = "GRBurst@protonmail.com";
  };

  programs.alacritty = {
    enable = true;
    # settings = {
    #   env.TERM = "xterm-256color";
    #   font = {
    #     size = 12;
    #     draw_bold_text_with_bright_colors = true;
    #   };
    #   scrolling.multiplier = 5;
    #   selection.save_to_clipboard = true;
    # };
  };

  programs.bash = {
    enable = true;
    enableCompletion = true;
    bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/local/bin"
    '';

    shellAliases = {
      k = "kubectl";
      urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      urlencode = "python3 -c 'import sys, urllib.parse as ul; print(ul.quote_plus(sys.stdin.read()))'";
    };
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



  # Packages that should be installed to the user profile.
  # home.packages = with pkgs; [
  #   # here is some command line tools I use frequently
  #   # feel free to add your own or remove some of them
  #
  #   neofetch
  #   nnn # terminal file manager
  #
  #   # archives
  #   zip
  #   xz
  #   unzip
  #   p7zip
  #
  #   # utils
  #   ripgrep # recursively searches directories for a regex pattern
  #   jq # A lightweight and flexible command-line JSON processor
  #   yq-go # yaml processor https://github.com/mikefarah/yq
  #   eza # A modern replacement for ‘ls’
  #   fzf # A command-line fuzzy finder
  #
  #   # networking tools
  #   mtr # A network diagnostic tool
  #   iperf3
  #   dnsutils  # `dig` + `nslookup`
  #   ldns # replacement of `dig`, it provide the command `drill`
  #   aria2 # A lightweight multi-protocol & multi-source command-line download utility
  #   socat # replacement of openbsd-netcat
  #   nmap # A utility for network discovery and security auditing
  #   ipcalc  # it is a calculator for the IPv4/v6 addresses
  #
  #   # misc
  #   cowsay
  #   file
  #   which
  #   tree
  #   gnused
  #   gnutar
  #   gawk
  #   zstd
  #   gnupg
  #
  #   # nix related
  #   #
  #   # it provides the command `nom` works just like `nix`
  #   # with more details log output
  #   nix-output-monitor
  #
  #   # productivity
  #   hugo # static site generator
  #   glow # markdown previewer in terminal
  #
  #   btop  # replacement of htop/nmon
  #   iotop # io monitoring
  #   iftop # network monitoring
  #
  #   # system call monitoring
  #   strace # system call monitoring
  #   ltrace # library call monitoring
  #   lsof # list open files
  #
  #   # system tools
  #   sysstat
  #   lm_sensors # for `sensors` command
  #   ethtool
  #   pciutils # lspci
  #   usbutils # lsusb
  # ];
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
        # binutils -> provided by clang
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
        traceroute mtr
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
	trashy
	yazi


        # Office
        # calibre broken on 2022-04-10
        # etesync-dav # broken since 2023-01-01
        exif
        # firefox profile-sync-daemon
        librewolf # (librewolf.override { wmClass = "browser"; })
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
        # texlab
        # texlive.combined.scheme-full
        # biber # collides texlive full
        # pdftk #pdfshuffler
        # pdfsandwich pdfsam-basic pdfarranger
        poppler_utils
        xournal

        # Media
        blueman
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
        gdb glib glxinfo
        git tig gh hub gitRepo
        # neovim coursier # coursier needed for neovim plugins
        # python27Packages.pynvim # ensime
        # python3Packages.pynvim
        # EDITOR
        # neovim coursier # coursier needed for neovim plugins
        # python27Packages.pynvim # ensime
        # python3Packages.pynvim
        # LazyVim
        neovim clang tree-sitter
        editorconfig-core-c
        shfmt shellcheck
        nixd
        lua lua-language-server luaPackages.jsregexp stylua
        fd
        lazygit
        unzip

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

        nix-index
        nix-prefetch-git
        nox
        patchelf

        # swiProlog
        #vscodium
        # vscode-liveshare

        brave


	#####
	## LAPTOP
	#####
        # libqmi
        brillo # control keyboard led
        cbatticon
        light
        linuxPackages.tp_smapi
        linuxPackages.acpi_call
        tlp
        zbar # read qrcodes


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
        # qutebrowser -> not using anymore
        # qtox -> not using anymore
        # skypeforlinux -> not using anymore
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


  # This value determines the home Manager release that your
  # configuration is compatible with. This helps avoid breakage
  # when a new home Manager release introduces backwards
  # incompatible changes.
  #
  # You can update home Manager without changing this value. See
  # the home Manager release notes for a list of state version
  # changes in each release.
  home.stateVersion = "24.05";

  # Let home Manager install and manage itself.
  programs.home-manager.enable = true;
}
