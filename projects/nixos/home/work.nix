{ config, pkgs, ... }:

{

  home.username = "pallon";
  home.homeDirectory = "/home/pallon";
  home.sessionVariables.NIXOS_OZONE_WL = "1";

  imports = [
    ../modules/hyprland
  ];

  # set cursor size and dpi for 4k monitor
  xresources.properties = {
    # "Xcursor.size" = 64;
    "Xft.dpi" = 192;
  };
  # programs.hyprland = {
  #   enable = true;
  #   package = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.hyprland;
  #   portalPackage = inputs.hyprland.packages.${pkgs.stdenv.hostPlatform.system}.xdg-desktop-portal-hyprland;
  # };
  # basic configuration of git, please change to your own


  programs.direnv = {
    enable = true;
    enableZshIntegration = true;
    nix-direnv.enable = true;
    config = { }; # don't generate direnv.toml, use the existing one instead
  };
  programs.kitty.enable = true;
  programs.git = {
    enable = true;
    # userName = "GRBurst";
    # userEmail = "GRBurst@protonmail.com";
    settings = {
      user = {
        name = "GRBurst";
        email = "GRBurst@protonmail.com";
      };
    };
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

  fonts = {
    fontconfig.enable = true;
  };

  xdg = {
    portal = {
      enable = true;
      extraPortals = with pkgs; [
        # xdg-desktop-portal
        xdg-desktop-portal-gtk
      ];
      # configPackages = [ pkgs.gnome-session ];
    };
    mime.enable = true;
  };

  # stylix = {
  #   enable = false;
  #   autoEnable = false;
  #   cursor = {
  #     name = "Vanilla-DMZ";
  #     package = pkgs.vanilla-dmz;
  #     size = 128;
  #   };
  #   fonts.sizes.applications = 8;
  #   fonts.sizes.terminal = 8;

  #   # targets = { dunst.enable = true; };
  # };

  # xdg.mimeApps = {
  #   enable = true;
  #   associations.added = {
  #     "application/pdf" = ["org.Evince.desktop"];
  #   };
  #   defaultApplications = {
  #     "application/pdf" = ["org.Evince.desktop"];
  #   };
  # };

  # services = {
  #   wired.enable = true;
  #   wired.config = pkgs.writeTextFile {
  #     name = "wired.ron";
  #     text = ''
# (
  #   max_notifications: 5,
  #   timeout: 4000,
  #   poll_interval: 16, // 16ms ~= 60hz / 7ms ~= 144hz.
  #   history_length: 20,
  #   replacing_enabled: true,
  #   replacing_resets_timeout: true,
  #   min_window_width: 300,
  #   min_window_height: 100,

  #   debug: false,
  #   debug_color: Color(r: 0.0, g: 1.0, b: 0.0, a: 1.0),
  #   debug_color_alt: Color(r: 1.0, g: 0.0, b: 0.0, a: 1.0),

  #   layout_blocks: [
  #       (
  #           name: "app_root",
  #           parent: "",
  #           hook: Hook(parent_anchor: MM, self_anchor: MM),
  #           offset: Vec2(x: 0, y: 0),
  #           render_criteria: [AppImage],
  #           params: NotificationBlock((
  #                   monitor: 0,
  #                   border_width: 0,
  #                   border_rounding: 8,
  #                   background_color: Color(hex: "#F5F5F5"),
  #                   border_color: Color(hex: "#00000000"),
  #                   border_color_low: Color(hex: "#00000000"),
  #                   border_color_critical: Color(hex: "#FF0000"),
  #                   border_color_paused: Color(hex: "#00000000"),
  #                   gap: Vec2(x: 0.0, y: 8.0),
  #                   notification_hook: Hook(parent_anchor: BM, self_anchor: TM),
  #           )),
  #       ),

  #       (
  #           name: "app_notification",
  #           parent: "app_root",
  #           hook: Hook(parent_anchor: TM, self_anchor: TM),
  #           offset: Vec2(x: 0, y: 0),
  #           params: ImageBlock((
  #                   image_type: App,
  #                   padding: Padding(left: 40, right: 40, top: 40, bottom: 8),
  #                   rounding: 4.0,
  #                   scale_width: 152,
  #                   scale_height: 152,
  #                   filter_mode: Lanczos3,
  #           )),
  #       ),

  #       (
  #           name: "app_summary",
  #           parent: "app_notification",
  #           hook: Hook(parent_anchor: BM, self_anchor: TM),
  #           offset: Vec2(x: 0, y: 12),
  #           params: TextBlock((
  #                   text: "%s",
  #                   font: "Arial Bold 16",
  #                   ellipsize: End,
  #                   color: Color(hex: "#000000"),
  #                   padding: Padding(left: 0, right: 0, top: 0, bottom: 0),
  #                   dimensions: (width: (min: -1, max: 185), height: (min: 0, max: 0)),
  #           )),
  #       ),

  #       (
  #           name: "app_body",
  #           parent: "app_summary",
  #           hook: Hook(parent_anchor: BM, self_anchor: TM),
  #           offset: Vec2(x: 0, y: 0),
  #           params: TextBlock((
  #                   text: "%b",
  #                   font: "Arial Bold 16",
  #                   ellipsize: End,
  #                   color: Color(hex: "#000000"),
  #                   padding: Padding(left: 0, right: 0, top: 0, bottom: 24),
  #                   dimensions: (width: (min: -1, max: 250), height: (min: 0, max: 0)),
  #           )),
  #       ),

  #       (
  #           name: "app_progress",
  #           parent: "app_notification",
  #           hook: Hook(parent_anchor: BM, self_anchor: TM),
  #           offset: Vec2(x: 0, y: 50),
  #           render_criteria: [Progress],
  #           params: ProgressBlock((
  #                   padding: Padding(left: 0, right: 0, top: 0, bottom: 32),
  #                   border_width: 2,
  #                   border_rounding: 2,
  #                   border_color: Color(hex: "#000000"),
  #                   fill_rounding: 1,
  #                   background_color: Color(hex: "#00000000"),
  #                   fill_color: Color(hex: "#000000"),
  #                   width: -1.0,
  #                   height: 30.0,
  #           )),
  #       ),

  #       (
  #           name: "status_root",
  #           parent: "",
  #           hook: Hook(parent_anchor: TM, self_anchor: TM),
  #           offset: Vec2(x: 0.0, y: 60),
  #           // render_anti_criteria: [AppImage],
  #           render_criteria: [HintImage],
  #           params: NotificationBlock((
  #                   monitor: 0,
  #                   border_width: 0,
  #                   border_rounding: 8,
  #                   background_color: Color(hex: "#F5F5F5"),
  #                   border_color: Color(hex: "#00000000"),
  #                   border_color_low: Color(hex: "#00000000"),
  #                   border_color_critical: Color(hex: "#FF0000"),
  #                   border_color_paused: Color(hex: "#00000000"),
  #                   gap: Vec2(x: 0.0, y: 8.0),
  #                   notification_hook: Hook(parent_anchor: BM, self_anchor: TM),
  #           )),
  #       ),

  #       (
  #           name: "status_notification",
  #           parent: "status_root",
  #           hook: Hook(parent_anchor: TL, self_anchor: TL),
  #           offset: Vec2(x: 0, y: 0),
  #           params: TextBlock((
  #                   text: "%s",
  #                   font: "Arial Bold 16",
  #                   ellipsize: End,
  #                   color: Color(hex: "#000000"),
  #                   padding: Padding(left: 8, right: 8, top: 8, bottom: 8),
  #                   dimensions: (width: (min: 400, max: 400), height: (min: 84, max: 0)),
  #           )),
  #       ),

  #       (
  #           name: "status_body",
  #           parent: "status_notification",
  #           hook: Hook(parent_anchor: ML, self_anchor: TL),
  #           offset: Vec2(x: 0, y: -24),
  #           params: TextBlock((
  #                   text: "%b",
  #                   font: "Arial 14",
  #                   ellipsize: End,
  #                   color: Color(hex: "#000000"),
  #                   padding: Padding(left: 8, right: 8, top: 8, bottom: 8),
  #                   dimensions: (width: (min: 400, max: 400), height: (min: 0, max: 84)),
  #           )),
  #       ),

  #       (
  #           name: "status_image",
  #           parent: "status_notification",
  #           hook: Hook(parent_anchor: TL, self_anchor: TR),
  #           offset: Vec2(x: 0, y: 0),
  #           params: ImageBlock((
  #                   image_type: Hint,
  #                   padding: Padding(left: 8, right: 0, top: 8, bottom: 8),
  #                   rounding: 4.0,
  #                   scale_width: 84,
  #                   scale_height: 84,
  #                   filter_mode: Lanczos3,
  #           )),
  #       ),
  #   ],

  #   // https://github.com/Toqozz/wired-notify/wiki/Shortcuts
  #   shortcuts: ShortcutsConfig (
  #       notification_interact: 1,
  #       notification_close: 2,
  #       notification_action1: 3,
  #   ),
# )
  #   '';
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
        arandr autorandr
        acpi
        avahi
        atop htop iotop btop iftop nmon
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
        lsof
        #mosh
        pciutils
        # p7zip -> abandoned (2020-05-18)
        pv
        screen
        scrot flameshot
        speechd
        # unzip zip
        zenity # zenity
        pistol

        # x-server
        xcwd
        xclip
        unclutter-xfixes 
        xdpyinfo xev xmodmap xkill xwininfo xhost
        vanilla-dmz # x cursor
        xsettingsd
        # libsForQt5.qtstyleplugins
        gnome-control-center
        xdotool xprintidle

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
        # ngrok
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
        termite
        alacritty alacritty-theme
        nix-zsh-completions
        # haskellPackages.yeganesh
        tldr
        wezterm

        # Filesystem
        nvme-cli
        nautilus gvfs
        ncdu dust
        duf # du alternative
        sd # sed alternative
        fzf fasd file silver-searcher
        television
        autossh sshfs-fuse
        direnv
        lsyncd
        bindfs
        bat # cat alternative
        tree gparted
        broot
        ntfs3g
        inotify-tools
        smartmontools
        exfat
        # file-roller # mimeinfo collides with nautilus
        gptfdisk
        # spaceFM  # broken as of 2026-02-11
        shared-mime-info
        desktop-file-utils
        usbutils
        ripgrep
        trashy
        yazi
        rsync rclone


        # Office
        calibre
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
        syncthingtray # qsyncthingtray -> dep
        simple-scan
        # typora # breaks on 2020-07-08
        zathura
        thunderbird birdtray
        # texlab
        # texlive.combined.scheme-full
        # biber # collides texlive full
        # pdftk #pdfshuffler
        # pdfsandwich pdfsam-basic pdfarranger
        poppler-utils
        xournalpp

        # Media
        blueman bluez-tools
        feh imv nitrogen 
        (gimp-with-plugins.override { 
          plugins = with gimpPlugins; [ 
            # fourier
            # resynthesizer # broken since 2023-03-20
            # gmic
          ]; 
        })
        inkscape 
        mate.atril
        mimeo
        mpv
        imagemagick
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
        openai-whisper
        megasync

        # Communication
        # pidgin-with-plugins
        # element-desktop
        # schildichat-desktop
        signal-desktop
        # wire-desktop #insecure CVE-2024-6775
        telegram-desktop
        wasistlos
        # jitsi jitsi-meet
        ausweisapp

        # Themes
        # breeze-gtk breeze-icons breeze-qt5 
        kdePackages.breeze
        adwaita-qt adwaita-icon-theme 
        papirus-icon-theme
        dconf
        dconf-editor
        lxqt.lxqt-config
        lxappearance


    #####
    # DEV
    #####
        qemu qemu_kvm
        # pulsar
        # ctags
        gdb glib mesa-demos
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
        typora
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
        opencode

        # purescript
        # nodePackages.purescript-language-server

        cmakeCurses
        docker-compose
        oxker cruise lazydocker
        entr
        # ghc
        graphviz
        gthumb
        filezilla
        jetbrains.idea-oss
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
        aichat
        steam-run # steam-run-free


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
    ## AMD
    #####
    amdgpu_top
    nvtopPackages.amd

    #####
    ## HIGHRES
    #####

        protonmail-desktop
        proton-pass
        # avidemux broken
        audacity
        brasero
        (chromium.override { enableWideVine = false; })
        brave
        clementine
        # deadd-notification-center
        evince
        epson-escpr2 sane-airscan brscan4
        fwupd # bios + firmware updates
        # guvcview # broken: 2025-11-21
        # gnomeExtensions.jiggle
        gnomeExtensions.random-wallpaper
        irssi
        kvirc
        kdePackages.okular
        # jbidwatcher
        # jdownloader
        josm
        kdePackages.kdenlive
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
        vokoscreen-ng # keymon -> abandoned
        # jellyfin-media-player -> based on vulnerable qt5webengine
        zoom-us
        teams-for-linux
        discord
        (bolt-launcher.override { enableRS3 = true; })

        # New
        kondo
        eww waybar ironbar # ashell hybrid
        swww
        wofi yofi anyrun
        satty # watershot
        jay

        hyprpaper
        hyprpicker
        hyprlock
        hypridle
        hyprcursor
        hyprsunset

        ### AI
        aider-chat
        yek

        # time tracking
        timewarrior
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
