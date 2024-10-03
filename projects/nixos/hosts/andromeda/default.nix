# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  nix = {
    daemonIOSchedPriority = 7;
    settings = {
      sandbox = true;
      experimental-features = [ "nix-command" "flakes" ];
    };
    gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 90d";
    };
  };

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
      extraPackages32 = with pkgs.driversi686Linux; [ amdvlk ];
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  networking = {
    networkmanager = {
      enable = true;
      wifi.macAddress = "random";
      appendNameservers = [ "9.9.9.9" "149.112.112.112" "2620:fe::fe" "2620:fe::9" ];
    };
    enableIPv6 = true;
    firewall.enable = true;
    firewall.allowedTCPPorts = [ 12345 15432 53292 ];
    firewall.allowedUDPPorts = [ 50624 50625 ]; # Firefox WebIDE
    hostName = "andromeda";
    extraHosts = ''
      127.0.0.1       *.localhost *.localhost.localdomain
    '';
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

  console = { # Select internationalisation properties.
    keyMap = "neo";
  };

  i18n.defaultLocale = "en_US.UTF-8";

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  # These are installed system-wide
  environment = {
    systemPackages = with pkgs; [
      neovim vim
      git
      wget
      curl

      protonvpn-cli protonvpn-gui protonmail-bridge
      hdparm
      adapta-gtk-theme adapta-kde-theme
    ];

    shellAliases = {
      l = "ls -l";
      t = "tree -C"; # -C is for color=always
      vn = "vim /etc/nixos/configuration.nix";
    };

    # TODO: Move to .profile

    #wget "https://github.com/chenkelmann/neo2-awt-hack/blob/master/releases/neo2-awt-hack-0.4-java8oracle.jar?raw=true" -O ~/local/jars/neo2-awt-hack-0.4-java8oracle.jar
    variables = {
      EDITOR = "nvim";
      SUDO_EDITOR = "nvim";
      VISUAL = "nvim";

      BROWSER = "librewolf";

      # _JAVA_OPTIONS = "-Xms1G -Xmx4G -Xss16M -XX:MaxMetaspaceSize=2G -XX:+UseCompressedOops -Dawt.useSystemAAFontSettings=lcd";
      #SBT_OPTS="$SBT_OPTS -Xms2G -Xmx8G -Xss4M -XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC";
      SBT_OPTS="-Xms1G -Xmx4G -Xss16M";

      AUTOSSH_GATETIME = "0";

      DE = "gnome";
      XDG_CURRENT_DESKTOP = "gnome";

      GTK_IM_MODULE = "ibus";
      XMODIFIERS = "@im=ibus";
      QT_IM_MODULE = "ibus";

      _JAVA_AWT_WM_NONREPARENTING = "1";

      AWT_TOOLKIT = "MToolkit";
      GDK_USE_XFT = "1";

      QT_STYLE_OVERRIDE = "gtk2";
      QT_QPA_PLATFORMTHEME = "gtk2";

      # _JAVA_OPTIONS = "-Dsun.java2d.uiScale=2";
      # QT_AUTO_SCREEN_SCALE_FACTOR = "1";
      # QT_AUTO_SCREEN_SCALE_FACTOR = "0";
      # QT_SCALE_FACTOR = "1";
      # GDK_SCALE = "2";
      # GDK_DPI_SCALE = "0.5";
      # QT_FONT_DPI = "192";
      # QT_STYLE_OVERRIDE="Adapta";
    };
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
    screen.screenrc = 
    ''term screen-256color
      termcapinfo xterm*|xs|rxvt* ti@:te@
      startup_message off
      caption string '%{= G}[ %{G}%H %{g}][%= %{= w}%?%-Lw%?%{= R}%n*%f %t%?%{= R}(%u)%?%{= w}%+Lw%?%= %{= g}][ %{y}Load: %l %{g}][%{B}%Y-%m-%d %{W}%c:%s %{g}]'
      caption always
    '';

    light.enable = true;
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
      ports = [ 53292 ];
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
      videoDrivers = [ "modesetting" ];
      xkb = {
      	layout = "de,de";
      	variant = "neo,basic";
      	options = "grp:menu_toggle";
      };
      displayManager = {
        lightdm.enable = true;
      };

      desktopManager.xterm.enable  = false;
      windowManager = {
        i3 = {
          enable = true;
          extraPackages = with pkgs; [ feh rofi i3status-rust i3lock gnome-keyring ];
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
        enable   = true;
        settings = {
          TCPAddr = "127.0.0.1";
          TCPSocket = 3310;
        };
      };
      updater.enable  = true;
    };

    gvfs.enable  = true;
    gnome = {
      gnome-keyring.enable = true;
      gnome-settings-daemon.enable = false;
    };

    upower.enable  = true;
    udisks2.enable = true;

    acpid.enable = true;
    avahi.enable = true;
    flatpak.enable = true;
  };

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
      defaultFonts.monospace = [ "Roboto Mono" "DejaVu Sans Mono" ];
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


  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.pallon = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "vboxusers" "docker" "fuse" "adbusers" "networkmanager" ];
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDeEb4AnnxoSa1OJS1Byr6GvxeTiino4nLgxhEi3nb3k jelias@mars->earth on 2024-09-03"
    ];
  };


  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "24.05"; # Did you read the comment?

}
