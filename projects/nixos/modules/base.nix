{
  pkgs,
  hostname,
  ...
}: {
  imports = [
    # ./<module>.nix
  ];

  boot = {
    loader = {
      systemd-boot.enable = true; # Use the systemd-boot EFI boot loader
      efi.canTouchEfiVariables = true;
    };

    tmp.useTmpfs = true;

    kernel.sysctl = {
      "fs.inotify.max_user_watches" = "409600";
      "kernel.sysrq" = 1;
      "vm.swappiness" = 1;
    };
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    sane.enable = true;
    cpu.amd.updateMicrocode = true;
    graphics = {
      enable = true;
      enable32Bit = true;
      extraPackages = with pkgs; [
        amdvlk
      ];
      extraPackages32 = with pkgs.driversi686Linux; [amdvlk];
    };
  };

  networking = {
    networkmanager = {
      enable = true;
      wifi.macAddress = "random";
      # quad9 dns server, https://www.quad9.net/
      appendNameservers = ["9.9.9.9" "149.112.112.112" "2620:fe::fe" "2620:fe::9"];
    };
    enableIPv6 = true;
    firewall = {
      enable = true;
      allowedTCPPorts = [12345 15432 53292];
      allowedUDPPorts = [50624 50625]; # Firefox WebIDE
    };
    hostName = hostname;
    extraHosts = ''
      127.0.0.1       *.localhost *.localhost.localdomain
    '';
  };

  nix = {
    daemonIOSchedPriority = 7;
    settings = {
      sandbox = true;
      experimental-features = ["nix-command" "flakes"];
    };
    gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 90d";
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  system.autoUpgrade.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs = {
    noisetorch = {
      enable = true;
    };

    command-not-found.enable = true;

    bash.completion.enable = true;

    zsh = {
      enable = true;
      enableCompletion = true;
    };
    fish.enable = true;

    adb.enable = true;

    # ssh.startAgent = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    seahorse.enable = true;
    gpaste.enable = true;

    java.enable = true; # Global, otherwise JAVA_HOME is not set

    # mtr.enable = true;

    dconf.enable = true;

    screen.enable = true;
    screen.screenrc = ''
      term screen-256color
      termcapinfo xterm*|xs|rxvt* ti@:te@
      startup_message off
      caption string '%{= G}[ %{G}%H %{g}][%= %{= w}%?%-Lw%?%{= R}%n*%f %t%?%{= R}(%u)%?%{= w}%+Lw%?%= %{= g}][ %{y}Load: %l %{g}][%{B}%Y-%m-%d %{W}%c:%s %{g}]'
      caption always
    '';

    light.enable = true;

    # ssh.startAgent = true;
    gnupg.agent = {
      enable = true;
      enableSSHSupport = true;
    };
    seahorse.enable = true;
  };

  users.defaultUserShell = "/run/current-system/sw/bin/zsh";

  security = {
    #// TODO: pmount needs /media folder (create it automatically)
    wrappers = {
      pmount = {
        setgid = true;
        owner = "root";
        group = "users";
        source = "${pkgs.pmount}/bin/pmount";
      };
      pumount = {
        setgid = true;
        owner = "root";
        group = "users";
        source = "${pkgs.pmount}/bin/pumount";
      };
      eject = {
        setgid = true;
        owner = "root";
        group = "users";
        source = "${pkgs.eject}/bin/eject";
      };
      light = {
        setgid = true;
        owner = "root";
        group = "users";
        source = "${pkgs.light}/bin/light";
      };
      beep = {
        setgid = true;
        owner = "root";
        group = "users";
        source = "${pkgs.beep}/bin/beep";
      };
    };

    sudo = {
      enable = true;
      wheelNeedsPassword = true;
    };
  };

  # List services that you want to enable:
  services = {
    openssh = {
      enable = true;
      ports = [53292];
    };

    cron.enable = true;

    lorri.enable = true;

    fwupd = {
      enable = true;
    };

    tlp = {
      enable = true;
      settings = {
        tlp_DEFAULT_MODE = "BAT";
        CPU_SCALING_GOVERNOR_ON_AC = "powersave";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_HWP_ON_AC = "balance_performance";
        CPU_HWP_ON_BAT = "balance_power";
        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 100;
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 1;
      };
    };

    journald = {
      extraConfig = ''
        Storage=persist
        Compress=yes
        SystemMaxUse=128M
        RuntimeMaxUse=8M
      '';
    };

    usbmuxd.enable = true;

    fstrim.enable = true;

    printing = {
      enable = true;
    };

    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
    };

    libinput = {
      enable = true;
      touchpad = {
        scrollMethod = "twofinger";
        disableWhileTyping = true;
        tapping = false;
      };
    };

    displayManager = {
      autoLogin = {
        enable = false;
        user = "pallon";
      };
      defaultSession = "none+i3";

      #setupCommands = ''
      #  gnome-keyring-daemon --start --components=pkcs11,secrets,ssh
      #'';
    };

    xserver = {
      enable = true;
      dpi = 192;
      videoDrivers = ["modesetting"];
      xkb = {
        layout = "de,de";
        variant = "neo,basic";
        options = "grp:menu_toggle";
      };
      displayManager = {
        lightdm.enable = true;
      };

      desktopManager.xterm.enable = false;
      windowManager = {
        i3 = {
          enable = true;
          extraPackages = with pkgs; [feh rofi i3status-rust i3lock gnome-keyring];
          extraSessionCommands = ''
            xsetroot -bg black
            xsetroot -cursor_name left_ptr
            gnome-keyring-daemon --start -d --components=pkcs11,secrets,ssh
            feh --bg-scale '/home/pallon/.config/i3/background0.jpg' '/home/pallon/.config/i3/background1.jpg' &
          '';
        };
      };
    };

    picom = {
      enable = true;
      backend = "glx";
      vSync = true;
    };

    redshift = {
      enable = true;
      executable = "/bin/redshift-gtk";
      temperature.day = 5000;
      temperature.night = 3000;
      brightness.day = "1.0";
      brightness.night = "0.75";
    };

    unclutter-xfixes.enable = true;

    syncthing = {
      enable = true;
      user = "pallon";
      configDir = "/home/pallon/.config/syncthing";
      dataDir = "/home/pallon/.config/syncthing";
      openDefaultPorts = true;
      systemService = true;
      # package = pkgs.unstable.syncthing;
    };

    locate = {
      enable = true;
      interval = "22:00";
    };

    psd = {
      enable = true;
    };

    clamav = {
      daemon = {
        enable = true;
        settings = {
          TCPAddr = "127.0.0.1";
          TCPSocket = 3310;
        };
      };
      updater.enable = true;
    };

    gvfs.enable = true;
    gnome = {
      gnome-keyring.enable = true;
      gnome-settings-daemon.enable = false;
    };

    upower.enable = true;
    udisks2.enable = true;

    acpid.enable = true;
    avahi.enable = true;
    flatpak.enable = true;
  };

  location = {
    provider = "manual";
    latitude = 50.77;
    longitude = 6.08;
  };

  powerManagement = {
    enable = true;
    #cpuFreqGovernor = lib.mkDefault "powersave";
    #powertop.enable = true;
  };

  console = {
    # Select internationalisation properties.
    keyMap = "neo";
  };

  i18n.defaultLocale = "en_US.UTF-8";

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  xdg.portal.enable = true;
  xdg.portal.config.common.default = "*";

  qt = {
    platformTheme = "gnome";
    style = "Adapta";
  };

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;

    packages = with pkgs; [
      corefonts
      dejavu_fonts
      google-fonts
      liberation_ttf
      powerline-fonts
      ubuntu_font_family
      symbola # many unicode symbols
      vistafonts
      font-awesome
      # inconsolata
    ];

    fontconfig = {
      includeUserConf = true;
      defaultFonts.monospace = ["Roboto Mono" "DejaVu Sans Mono"];
    };
  };

  virtualisation = {
    # virtualbox.host = {
    #   enable = true;
    #   enableExtensionPack = true;
    # };
    docker = {
      enable = true;
      enableOnBoot = false;
    };
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "24.05"; # Did you read the comment?
}
