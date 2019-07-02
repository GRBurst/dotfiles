{ config, pkgs, lib, ... }:

# let
#   # from: https://gist.github.com/LnL7/e645b9075933417e7fd8f93207787581
#   # Import unstable channel.
#   # sudo nix-channel --add https://nixos.org/channels/nixpkgs-unstable nixpkgs-unstable
#   # sudo nix-channel --update nixpkgs-unstable
#   unstable = import <nixpkgs-unstable> {};
# in

{
  imports =
  [
    ./hardware-configuration.nix
  ];

  boot = {
    loader = {
      # Use the systemd-boot EFI boot loader
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;

      grub = {
        efiSupport = true;
        device = "/dev/nvme0n1";
        memtest86.enable = true;
      };
    };

    kernelParams = ["processor.max_cstate=1"]; # fix for ryzen freeze?

    # kernelPackages = pkgs.linuxPackages_4_14;
    # kernelPackages = pkgs.linuxPackages_latest;

    tmpOnTmpfs = true;

    kernel.sysctl = {
      "kernel.sysrq" = 1;
      "vm.swappiness" = 0;
      "fs.inotify.max_user_watches" = "409600";
    };
  };


  # fileSystems = {
    # "/media/ateam" = {
    #     device = "//ateam/ateam";
    #     fsType = "cifs";
    #     options = [ "uid=felix" "ro" "username=x" "password=" "x-systemd.automount" "noauto" "x-systemd.idle-timeout=1800" "x-systemd.device-timeout=60" ];
    # };
    # "/media/ateamUpload" = {
    #     device = "//ateam/upload";
    #     fsType = "cifs";
    #     options = [ "uid=felix" "username=x" "password=" "x-systemd.automount" "noauto" "x-systemd.idle-timeout=1800" "x-systemd.device-timeout=60" ];
    # };
    # "/media/trommel" = {
    #     device = "/dev/disk/by-uuid/452fb057-8990-4ce8-91dc-a97b26175447";
    #     fsType = "ext4";
    #     options = [ "defaults" "x-systemd.automount" "noauto" ];
    # };
  # };

  nixpkgs.config = {
    allowUnfree = true;
    # chromium = {
    #   # enablePepperFlash = true;
    #   enableWideVine = false;
    # };
    # #  --param l1-cache-line-size=64 --param l2-cache-size=8192 -mtune=nehalem
    # # stdenv.userHook = ''
    # #   NIX_CFLAGS_COMPILE+="-march=native"
    # # '';

    # programs.qt5ct.enable = true;

  };

  # nix.extraOptions = ''
  #   auto-optimise-store = true
  #   build-fallback = true
  # '';

  hardware = {
    pulseaudio.enable = true;
    pulseaudio.support32Bit = true; # This might be needed for Steam games
    opengl.driSupport32Bit = true;
    sane.enable = true;

    cpu.amd.updateMicrocode = true;
  };

  networking = {
    networkmanager.enable = true;
    firewall.enable = true;
    hostName = "fff";
    extraHosts = ''
      134.130.57.2    sylvester
      134.130.57.13   neptun
      134.130.59.240  ateam
    '';
    # networking.wireless.enable = true;
    firewall.allowedUDPPorts = [ 137 138 5353 ]; # for mosh: { from = 60000; to = 61000; } 
    firewall.allowedTCPPorts = [ 139 445 12345 ];
  };

  powerManagement = {
    enable = true;
    # powertop.enable = true;
  };

  i18n = {
    #consoleFont = "Lat2-Terminus16";
    consoleKeyMap = "neo";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Europe/Berlin";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  environment = {
    systemPackages = with pkgs; [
      vim
      # wirelesstools
      # wget pv htop atop git netcat nmap xorg.xkill psmisc lm_sensors calc tree gparted gksu ntfs3g inotify-tools unzip
      # ncdu fzf fasd silver-searcher tig ctags xclip tmate pmount scrot nix-zsh-completions haskellPackages.yeganesh
      # termite xcwd nitrogen grc #cope
      # dmenu polybar # panel
      # libnotify dunst
      # xdotool
      # chromium firefox
      # jdk scala sbt maven visualvm
      # virtualbox
      # gnumake cmake clang gcc autoconf automake
      # nodejs-10_x yarn
      # docker docker_compose
      # # rust.rustc rust.cargo
      # nim
      # texlive.combined.scheme-full
      # biber

      # boost
      # wine winetricks mono

      # libreoffice-fresh hunspell hunspellDicts.en-us languagetool mythes
      # samba cifs-utils

      # neovim

      # mosh

      # mate.atril inkscape gimp
      # sane-frontends
      # mpv vlc playerctl pamixer imv

      # vulkan-loader

      # mimeo
      # xdg_utils
      # shared_mime_info # file-type associations?
      # desktop_file_utils

      # gnome3.dconf # needed for meld
      # gnome3.nautilus gnome3.gvfs gnome3.file-roller
      # gnome3.gnome_keyring gnome3.seahorse libsecret

      # # numix-gtk-theme 
      # gnome3.adwaita-icon-theme
      # paper-icon-theme
      # vanilla-dmz

      # vdirsyncer
    ];

    shellAliases = {
      l = "ls -l";
      t = "tree -C"; # -C is for color=always
      vn = "vim /etc/nixos/configuration.nix";
    };

    variables = {
      EDITOR = "nvim";
      SUDO_EDITOR = "nvim";
      VISUAL = "nvim";

      BROWSER = "firefox";

      _JAVA_OPTIONS = "-Xms1G -Xmx4G -Xss1M -XX:+CMSClassUnloadingEnabled -XX:+UseCompressedOops -Dawt.useSystemAAFontSettings=lcd";

      AUTOSSH_GATETIME = "0";

      DE = "gnome";
      XDG_CURRENT_DESKTOP = "gnome";
      QT_AUTO_SCREEN_SCALE_FACTOR = "0";
      QT_SCALE_FACTOR = "1";

      GTK_IM_MODULE = "ibus";
      XMODIFIERS = "@im=ibus";
      QT_IM_MODULE = "ibus";

      _JAVA_AWT_WM_NONREPARENTING = "1";

      AWT_TOOLKIT = "MToolkit";
      GDK_USE_XFT = "1";

    };
    #QT_QPA_PLATFORMTHEME = "qt5ct";
    # _JAVA_OPTIONS=" -Xbootclasspath/p:$HOME/local/jars/neo2-awt-hack-0.4-java8oracle.jar";
    # SBT_OPTS="-J-Xms1G -J-Xmx4G -J-Xss4M -J-XX:+CMSClassUnloadingEnabled -J-XX:+UseConcMarkSweepGC";
    # _JAVA_OPTIONS = "-Xms1G -Xmx4G -Xss1M -XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC -XX:+UseCompressedOops -Dawt.useSystemAAFontSettings=lcd -Xbootclasspath/p:$HOME/local/jars/neo2-awt-hack-0.4-java8oracle.jar";
    #SSH_AUTH_SOCK = "%t/keyring/ssh";

  };

  nix.gc = {
    automatic = true;
    dates = "monthly";
    options = "--delete-older-than 7d";
  };
  system.autoUpgrade.enable = true;
  system.autoUpgrade.dates = "23:15";

    # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs = {
	command-not-found.enable = true;

	bash.enableCompletion = true;

	zsh = {
	  enable = true;
	  enableCompletion = true;
	};

	adb.enable = true;

	ccache = {
	  enable = true;
	  cacheDir = "/tmp/ccache";
	};

	# ssh.startAgent = true;
	gnupg.agent = { 
	  enable = true;
	  enableSSHSupport = true;
	};

	qt5ct.enable = true;
	# mtr.enable = true;

	dconf.enable = true;
  };

  users.defaultUserShell = "/run/current-system/sw/bin/zsh";

  security = {
	pam.services.lightdm.enableGnomeKeyring = true;
	pam.services.login.enableGnomeKeyring = true;
	pam.services.i3lock.enableGnomeKeyring = true;
	# pam.services."pam_gnome_keyring".enableGnomeKeyring = true;
	# pam.services = [
	  #   {
		#      name = "gnome_keyring";
		#      text = ''
		#        auth     optional    pam_gnome_keyring.so
		#        session  optional    pam_gnome_keyring.so auto_start
		#        password optional    pam_gnome_keyring.so
		#      '';
		#    }
		# ];

		#// TODO: pmount needs /media folder (create it automatically)
	wrappers = {
	  pmount.source = "${pkgs.pmount}/bin/pmount";
	  pumount.source = "${pkgs.pmount}/bin/pumount";
	  eject.source = "${pkgs.eject}/bin/eject";
	  # light.source = "${pkgs.light}/bin/light";
	  # slock.source = "${pkgs.slock}/bin/slock";
	};

	sudo = {
	  enable = true;
	  wheelNeedsPassword = true;
	};
  };

    # xserver = {
    #   enable = true;
    #   videoDrivers = [ "nvidia" ];
    #   screenSection = ''
    #     Option "metamodes" "nvidia-auto-select +0+0 {ForceCompositionPipeline=On}"
    #   '';
    #   layout = "de,de,us";
    #   xkbVariant = "neo,basic,basic";
    #   xkbOptions = "grp:menu_toggle";

    #   displayManager = {
    #     lightdm = {
    #       enable = true;
    #       autoLogin = {
    #         enable = true;
    #         user = "felix";
    #       };
    #     };
    #   };
    #   desktopManager.xterm.enable = false;
    #   desktopManager.default      = "none";
    #   windowManager.default       = "xmonad";
    #   windowManager.xmonad = {
    #     enable = true;
    #     enableContribAndExtras = true;
    #   };
    #   windowManager.herbstluftwm.enable = true;
    #   desktopManager.plasma5.enable = false;
    #   windowManager.i3.enable = true;
    # };
  services = {

    keybase.enable = true;
    kbfs = {
      enable = true;
      mountPoint = "/keybase"; # mountpoint important for keybase-gui
    };

    dbus.packages = with pkgs; [ gnome3.dconf gnome2.GConf gnome3.gnome-keyring gcr ];

    openssh = {
      enable = true;
      ports = [ 53292 ];
      passwordAuthentication = false;
      forwardX11 = true;
    };

    # autossh.sessions = [
    #   {
    #   user = "jelias";
    #   name = "juptiter-pluto";
    #   extraArguments = "-M 0 -N -q -o 'ServerAliveInterval=60' -o 'ServerAliveCountMax=3' -o 'ExitOnForwardFailure=yes' pluto -R 53292:127.0.0.1:53292 -i /home/jelias/.ssh/jupiter->pluto";
    #   }
    # ];

    avahi.enable = true;

    journald = {
      extraConfig = ''
        Storage=persistent
        Compress=yes
        SystemMaxUse=128M
        RuntimeMaxUse=8M
      '';
    };

    fstrim.enable = true;
    smartd.enable = true;

    printing = {
      enable = true;
      drivers = [ pkgs.gutenprint pkgs.hplip pkgs.epson-escpr ];
    };

    xserver = {
      enable = true;
      dpi = 192;
      videoDrivers = [ "nvidia" ];
      screenSection = ''
        Option "metamodes" "nvidia-auto-select +0+0 {ForceCompositionPipeline=On}"
      '';
      layout = "de,de";
      xkbVariant = "neo,basic,basic";
      xkbOptions = "grp:menu_toggle";

      xrandrHeads = [
        { output = "DP-0"; primary = true; }
        { output = "HDMI-1"; }
      ];

      # libinput = {
      #   enable = true;
      #   scrollMethod = "twofinger";
      #   disableWhileTyping = true;
      #   tapping = false;
      # };

      displayManager = {
        lightdm = {
          enable = true;
          autoLogin = {
            enable = false;
            user = "jelias";
          };
        };
      };

      desktopManager = {
        xterm.enable = false;
        plasma5.enable = false;
        default = "none";
      };

      windowManager = {
        i3 = {
          enable = true;
          extraPackages = with pkgs; [ feh rofi i3status i3lock gnome3.gnome-keyring ];
          extraSessionCommands = ''
            xsetroot -bg black
            xsetroot -cursor_name left_ptr
            gnome-keyring-daemon --start -d --components=pkcs11,secrets,ssh
          '';
        };
		# xmonad = {
		#   enable = true;
		#   enableContribAndExtras = true;
		# };
        # herbstluftwm.enable = true;
        default = "i3";
      };
    };

    compton.enable = true;

    redshift = {
      enable = true;
      latitude = "50.77";
      longitude = "6.08";
      temperature.day = 5000;
      temperature.night = 3000;
      brightness.day = "0.9";
      brightness.night = "0.75";
    };

    unclutter-xfixes.enable = true; # not working?

    syncthing = {
      enable = true;
      user = "jelias";
      configDir = "/home/jelias/.config/syncthing";
      dataDir = "/home/jelias/.config/syncthing";
      openDefaultPorts = true;
      systemService = true;
    };

    locate = {
      enable = true;
      interval = "22:00";
    };

    psd = {
      enable = true;
      # users = [ "jelias" ];
    };

    clamav = {
      daemon.enable   = true;
      daemon.extraConfig = ''
        TCPAddr   127.0.0.1
        TCPSocket 3310
      '';
      updater.enable  = true;
    };

    gnome3 = {
      gvfs.enable  = true;
      gnome-keyring.enable = true;
      gpaste.enable = true;
      seahorse.enable = true;
    };

    upower.enable  = true;
    udisks2.enable = true;

    # acpid.enable = true;

    # ipfs = {
    #   enable = true;
    # };

    saned = {
      enable = true;
      extraConfig = "192.168.1.20";
    };

  };

  # systemd.user = {
    # https://vdirsyncer.pimutils.org/en/stable/tutorials/systemd-timer.html
    # services.vdirsyncer = {
    #   description = "Synchronize calendars and contacts";
    #   serviceConfig = {
    #     Type = "oneshot";
    #     ExecStart = "${pkgs.vdirsyncer}/bin/vdirsyncer sync";
    #   };
    # };
    # timers.vdirsyncer = {
    #   description = "Synchronize vdirs";
    #   wantedBy = [ "timers.target" ];

    #   timerConfig = {
    #      OnBootSec = "2m";
    #      OnUnitInactiveSec = "30m";
    #      Unit = "vdirsyncer.service";
    #   };

    #   wants = [ "network-online.target" ];
    #   after = [ "network-online.target" ];
    # };

    # services.localnpm = {
    #   description = "Local npm cache";
    #   serviceConfig = {
    #     Type = "simple";
    #     ExecStart = "${pkgs.nodejs}/bin/node /home/felix/.node_modules/bin/local-npm -d /home/felix/.cache/local-npm";
    #   };
    #   wantedBy = [ "multi-user.target" ];
    # };
  # };

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;

    fonts = with pkgs; [
      corefonts
      dejavu_fonts
      google-fonts
      liberation_ttf
      symbola
      ubuntu_font_family
    ];

    fontconfig = {
      includeUserConf = false;
      defaultFonts.monospace = [ "Inconsolata" "DejaVu Sans Mono" ];
    };
  };

  virtualisation.virtualbox.host.enable = true;
  virtualisation.virtualbox.host.enableExtensionPack = true;
  virtualisation.docker.enable = true;

  #users.mutableUsers = false;

  users.extraUsers.jelias = {
    isNormalUser = true;
    extraGroups = ["wheel" "vboxusers" "docker" "scanner" "adbusers" "networkmanager" "wireshark" ];
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+BIE+0anEEYK0fBIEpjedblyGW0UnuYBCDtjZ5NW6P jelias@merkur"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAILM3FfAcv98v6F4a9GrJHLzBE7K0FiUKT4rZN9Hd++NE jelias@venus->fff on 2018-01-30"
    ];
  };

 system.stateVersion = "19.03"; # Did you read the comment?

}