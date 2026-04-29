{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.hm.bundles.extras;
in {
  options.my.hm.bundles.extras = {
    enable = lib.mkEnableOption "Extra User Packages";
    gpuMonitor = lib.mkOption {
      type = lib.types.enum ["amd" "nvidia" "none"];
      default = "amd";
      description = "Which nvtop variant (if any) to install for the GPU vendor on this host.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs;
      [
        # --- System / Admin ---
        arandr
        autorandr
        acpi
        avahi
        atop
        htop
        iotop
        btop
        iftop
        nmon
        bc
        calc
        beep
        cryptsetup
        linuxPackages.cpupower
        dmidecode
        psmisc
        hdparm
        hd-idle
        hddtemp
        lm_sensors
        gnumake
        pwgen
        rofi
        rofi-systemd
        btrfs-progs
        lsof
        pciutils
        pv
        screen
        scrot
        flameshot
        speechd
        zenity
        pistol

        # --- X11 / Window Management ---
        xcwd
        xclip
        unclutter-xfixes
        xdpyinfo
        xev
        xmodmap
        xkill
        xwininfo
        xhost
        vanilla-dmz
        xsettingsd
        gnome-control-center
        xdotool
        xprintidle

        # --- Security ---
        gnome-keyring
        libgnome-keyring
        seahorse
        libsecret
        openssl
        keepass
        keepassxc
        keybase-gui

        # --- Networking ---
        bind
        wget
        netcat-gnu
        nmap
        miniserve
        nload
        nethogs
        speedtest-cli
        traceroute
        mtr
        inetutils
        vpn-slice
        socat
        sshuttle
        wireshark
        networkmanagerapplet
        networkmanager_dmenu
        caddy

        # --- Terminal ---
        termite
        alacritty
        alacritty-theme
        nix-zsh-completions
        tldr
        wezterm

        # --- Filesystem ---
        nvme-cli
        nautilus
        gvfs
        ncdu
        dust
        duf
        sd
        fzf
        fasd
        file
        silver-searcher
        television
        autossh
        sshfs-fuse
        lsyncd
        bindfs
        bat
        tree
        gparted
        broot
        ntfs3g
        inotify-tools
        smartmontools
        exfat
        gptfdisk
        shared-mime-info
        desktop-file-utils
        usbutils
        ripgrep
        trashy
        rsync
        rclone

        # --- Office ---
        # calibre        # disabled: uncached; re-enable after personal cache warms
        exif
        profile-sync-daemon
        libreoffice-still
        hunspell
        hunspellDicts.en-us
        hunspellDicts.de-de
        languagetool
        mythes
        samba
        cifs-utils
        gcolor3
        gedit
        jmtpfs
        qrencode
        syncthingtray
        simple-scan
        zathura
        # thunderbird      # disabled: heavy build currently uncached on nixpkgs-unstable
        # birdtray         # disabled: companion of thunderbird
        poppler-utils
        xournalpp

        # --- Browser Overrides ---
        # librewolf + chromium are currently uncached on nixpkgs-unstable; overrides would
        # also force a unique-hash rebuild. Keep them disabled until a cache warms them.
        # (librewolf.override {wmClass = "browser";})
        # (chromium.override {enableWideVine = false;})
        # librewolf
        # chromium
        brave

        # --- Media ---
        blueman
        bluez-tools
        feh
        imv
        nitrogen
        # (gimp-with-plugins.override { plugins = with gimpPlugins; []; })
        inkscape
        atril
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
        # ffmpeg-full  # broken since 2026-04-28
        seafile-client
        seafile-shared
        # openai-whisper  # disabled: drags torch + piper-tts + faster-whisper (all uncached)
        megasync

        # --- Communication ---
        signal-desktop
        telegram-desktop
        wasistlos
        ausweisapp
        discord-ptb
        discord
        zoom-us
        teams-for-linux
        irssi
        kvirc

        # --- Development ---
        qemu
        qemu_kvm
        gdb
        glib
        mesa-demos
        git
        tig
        gh
        hub
        gitRepo
        neovim
        tree-sitter
        editorconfig-core-c
        typora
        # clang
        shfmt
        shellcheck
        nixd
        lua
        lua-language-server
        stylua
        fd
        lazygit
        unzip
        tmate
        meld
        kdiff3
        difftastic
        jq
        yq-go
        devbox
        opencode
        docker-compose # cmakeCurses
        oxker
        cruise
        lazydocker
        entr
        graphviz
        gthumb
        filezilla
        jetbrains.idea-oss
        nodejs
        nix-prefetch-git
        nox
        patchelf
        aichat
        steam-run

        # --- Laptop / Hardware ---
        brillo
        cbatticon
        linuxPackages.tp_smapi
        linuxPackages.acpi_call
        brightnessctl # light
        tlp
        zbar
        amdgpu_top
        # nvtop is selected per-host via `my.hm.bundles.extras.gpuMonitor`

        # --- Desktop Extras ---
        protonmail-desktop
        proton-pass
        audacity
        brasero
        clementine
        evince
        epson-escpr2
        sane-airscan
        brscan4
        fwupd
        gnomeExtensions.random-wallpaper
        kdePackages.okular
        josm
        # kdePackages.kdenlive  # broken dependency since 2026-04-28
        libnotify
        nextcloud-client
        shotwell
        tesseract
        texstudio
        vlc
        vokoscreen-ng
        bolt-launcher

        # --- Wayland / Hyprland specific ---
        kondo
        eww
        waybar
        ironbar
        awww
        wofi
        yofi
        anyrun
        satty
        jay
        hyprpaper
        hyprpicker
        hyprlock
        hypridle
        hyprcursor
        hyprsunset

        # --- Misc ---
        yek
        timewarrior
        kdePackages.breeze
        adwaita-qt
        adwaita-icon-theme
        papirus-icon-theme
        dconf-editor
        lxqt.lxqt-config
        lxappearance

        # --- Misc ---
        lmstudio
        claude-code
        claude-monitor
        codex
        opencode
        antigravity
        gemini-cli-bin

        # --- Ported from ref/nixos/home.nix (parity with single-system config) ---
        # binutils         # conflicts with clang (both ship bin/ld.gold) in home-manager-path buildEnv
        coursier
        ghc
        guvcview
        haskellPackages.yeganesh
        jitsi
        kdePackages.breeze-gtk
        kdePackages.qtstyleplugin-kvantum
        ngrok
        pmount
        unison
        upterm
      ]
      ++ lib.optional (cfg.gpuMonitor == "amd") pkgs.nvtopPackages.amd
      ++ lib.optional (cfg.gpuMonitor == "nvidia") pkgs.nvtopPackages.nvidia;
  };
}
