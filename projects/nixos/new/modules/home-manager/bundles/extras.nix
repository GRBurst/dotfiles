{ config, lib, pkgs, ... }:
let cfg = config.my.hm.bundles.extras;
in {
  options.my.hm.bundles.extras.enable = lib.mkEnableOption "Extra User Packages";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      # --- System / Admin ---
      arandr autorandr acpi avahi atop htop iotop btop iftop nmon
      bc calc beep cryptsetup linuxPackages.cpupower dmidecode psmisc
      hdparm hd-idle hddtemp lm_sensors gnumake pwgen
      rofi rofi-systemd btrfs-progs lsof pciutils pv screen scrot
      flameshot speechd zenity pistol
      
      # --- X11 / Window Management ---
      xcwd xclip unclutter-xfixes xdpyinfo xev xmodmap xkill xwininfo xhost
      vanilla-dmz xsettingsd gnome-control-center xdotool xprintidle
      
      # --- Security ---
      gnome-keyring libgnome-keyring seahorse libsecret openssl
      keepass keepassxc keybase-gui
      
      # --- Networking ---
      bind wget netcat-gnu nmap miniserve nload nethogs speedtest-cli
      traceroute mtr inetutils vpn-slice socat sshuttle wireshark
      networkmanagerapplet networkmanager_dmenu
      caddy
      
      # --- Terminal ---
      termite alacritty alacritty-theme nix-zsh-completions tldr wezterm
      
      # --- Filesystem ---
      nvme-cli nautilus gvfs ncdu dust duf sd fzf fasd file
      silver-searcher television autossh sshfs-fuse lsyncd bindfs
      bat tree gparted broot ntfs3g inotify-tools smartmontools
      exfat gptfdisk shared-mime-info desktop-file-utils usbutils
      ripgrep trashy yazi rsync rclone
      
      # --- Office ---
      calibre exif profile-sync-daemon libreoffice-still
      hunspell hunspellDicts.en-us hunspellDicts.de-de languagetool mythes
      samba cifs-utils gcolor3 gedit jmtpfs qrencode syncthingtray
      simple-scan zathura thunderbird birdtray poppler-utils xournalpp
      
      # --- Browser Overrides ---
      (librewolf.override { wmClass = "browser"; })
      (chromium.override { enableWideVine = false; })
      brave
      
      # --- Media ---
      blueman bluez-tools feh imv nitrogen
      # (gimp-with-plugins.override { plugins = with gimpPlugins; []; })
      inkscape atril mimeo mpv imagemagick
      pamixer pavucontrol playerctl ponymix spotify cheese
      xdg-utils ffmpeg-full seafile-client seafile-shared
      openai-whisper megasync
      
      # --- Communication ---
      signal-desktop telegram-desktop wasistlos ausweisapp
      discord-ptb discord zoom-us teams-for-linux irssi kvirc
      
      # --- Development ---
      qemu qemu_kvm gdb glib mesa-demos git tig gh hub gitRepo
      neovim tree-sitter editorconfig-core-c typora
      # clang
      shfmt shellcheck nixd lua lua-language-server stylua
      fd lazygit unzip tmate meld kdiff3 difftastic
      jq yq-go devbox opencode docker-compose # cmakeCurses
      oxker cruise lazydocker entr graphviz gthumb filezilla
      jetbrains.idea-oss nodejs nix-index nix-prefetch-git
      nox patchelf aichat steam-run
      
      # --- Laptop / Hardware ---
      brillo cbatticon linuxPackages.tp_smapi linuxPackages.acpi_call
      brightnessctl # light
      tlp zbar amdgpu_top nvtopPackages.amd
      
      # --- Desktop Extras ---
      protonmail-desktop proton-pass audacity brasero clementine
      evince epson-escpr2 sane-airscan brscan4 fwupd
      gnomeExtensions.random-wallpaper kdePackages.okular josm
      kdePackages.kdenlive libnotify nextcloud-client peek shotwell
      tesseract texstudio vlc vokoscreen-ng bolt-launcher
      
      # --- Wayland / Hyprland specific ---
      kondo eww waybar ironbar awww wofi yofi anyrun satty jay
      hyprpaper hyprpicker hyprlock hypridle hyprcursor hyprsunset
      
      # --- Misc ---
      aider-chat yek timewarrior
      kdePackages.breeze adwaita-qt adwaita-icon-theme papirus-icon-theme
      dconf-editor lxqt.lxqt-config lxappearance

      # --- Misc ---
      lmstudio
      claude-code-bin claude-monitor
      codex
      opencode

    ];
  };
}
