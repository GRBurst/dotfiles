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
    kernelParams = [ "usbcore.autosuspend=-1" ];
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = false;
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
      plugins = with pkgs; [
        networkmanager-openconnect
        networkmanager-openvpn
      ];
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
    cpuFreqGovernor = "performance";
    powertop.enable = true;
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
      tailscale
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

      XCURSOR_SIZE = "64";

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

    appimage.enable = true;

    # hyprland = {
    #   enable = true;
    # };
    noisetorch = {
      enable = true;
    };

    command-not-found.enable = true;

    # bash.completion.enable = true;
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

    i3lock.enable = true;

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

    nix-ld.enable = true;

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

    tailscale = {
      enable = true;
    };

    cron.enable = true;

    lorri.enable = true;

    fwupd = {
      enable = true;
    };

    power-profiles-daemon.enable = false;
    # auto-cpufreq = {
    #   enable = true;
    #   settings = {
    #     battery = {
    #       governor = "powersave";
    #       turbo = "auto";
    #       enable_thresholds = true;
    #       start_threshold = 20;
    #       stop_threshold = 80;
    #     };
    #     charger = {
    #       governor = "performance";
    #       turbo = "auto";
    #     };
    #   };
    # };
    tlp = {
      enable = true;
      settings = {
        TLP_DEFAULT_MODE = "BAT";
        START_CHARGE_THRESH_BAT0 = 20;
        STOP_CHARGE_THRESH_BAT0 = 80;
        PLATFORM_PROFILE_ON_AC = "performance";
        PLATFORM_PROFILE_ON_BAT = "low-power";
        CPU_SCALING_GOVERNOR_ON_AC = "performance";
        CPU_SCALING_GOVERNOR_ON_BAT = "powersave";
        CPU_MIN_PERF_ON_AC = 0;
        CPU_MAX_PERF_ON_AC = 100;
        CPU_MIN_PERF_ON_BAT = 0;
        CPU_MAX_PERF_ON_BAT = 100;
        CPU_BOOST_ON_AC = 1;
        CPU_BOOST_ON_BAT = 1;
        DEVICES_TO_DISABLE_ON_STARTUP = "bluetooth wwan";
        DEVICES_TO_DISABLE_ON_BAT = "bluetooth wwan";
        DEVICES_TO_DISABLE_ON_LAN_CONNECT = "wifi wwan";
        DEVICES_TO_DISABLE_ON_WIFI_CONNECT = "wwan";
        DEVICES_TO_DISABLE_ON_WWAN_CONNECT = "wifi";
        DEVICES_TO_ENABLE_ON_LAN_DISCONNECT = "wifi wwan";
        DEVICES_TO_ENABLE_ON_WIFI_DISCONNECT = "";
        DEVICES_TO_ENABLE_ON_WWAN_DISCONNECT = "";
        DEVICES_TO_ENABLE_ON_UNDOCK = "wifi";
        DEVICES_TO_DISABLE_ON_UNDOCK = "";
        USB_AUTOSUSPEND = 1; # Maybe set to 0 if facing issues
        USB_EXCLUDE_AUDIO = 1;
        USB_EXCLUDE_BTUSB = 1;
        USB_EXCLUDE_PHONE = 1;
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
      # lightdm.enable = true;
      # gdm.enable = true;
      sddm = {
        enable = true;
        wayland.enable = true;
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

    # picom = {
    #   enable = true;
    #   backend = "glx";
    #   vSync = true;
    # };

    redshift = {
      enable = false;
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
      core-os-services.enable = true;
      core-shell.enable = true;
      gnome-keyring.enable = true;
      gnome-settings-daemon.enable = true;
    };

    upower.enable  = true;
    udisks2.enable = true;

    acpid.enable = true;
    avahi.enable = true;
    flatpak.enable = true;

    autorandr = {
      enable = true;
      # profiles."laptop" = {
      #   fingerprint = {
      #     eDP1 = "00ffffffffffff000e6f071400000000011e0104b51f117803d89eaf4f45b1270f52540000000101010101010101010101010101010140ce00a0f07028803020350035ae10000018000000fd00283c848435010a202020202020000000fe0043534f542054330a2020202020000000fe004d4e453030314541312d350a2001aa02031d00e3058000e60605016a6a246d1a00000203283c00046a246a2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007";
      #     DP3 = "00ffffffffffff001ab39f08000000001e1c0103803c22782e2895a7554ea3260f5054bb8d80e1c0d140d100d1c0b300a9409500904022cc0050f0703e801810350055502100001a000000ff005956424b3030333832360a2020000000fd0018780fa03c000a202020202020000000fc005032372d38205453205548440a01f0020340f156616065666463625d5e5f100403021f2021221312110123097f07830100006d030c002000183c20006001020367d85dc401788801e3050301e20f7f4dd000a0f0703e803020350055502100001a1a6800a0f0381f4030203a0055502100001a565e00a0a0a029503020350055502100001a000000000000000000a4";
      #     DP4 = "00ffffffffffff001ab3a108000000001e1c0104b53c22783f2895a7554ea3260f5054bb8d00e1c0d140d100d1c0b300a94095009040e2ca0038f0703e801810350055502100001a000000ff005956424b3030343032380a2020000000fd0018780fa03c000a202020202020000000fc005032372d38205453205548440a0186020321f15461666463625d5e5f100403021f2021221312110123097f07830100004dd000a0f0703e803020350055502100001a04740030f2705a80b0588a0055502100001e1a6800a0f0381f4030203a0055502100001a565e00a0a0a029503020350055502100001a0000000000000000000000000000000000000000000064";
      #   };
      #   config = {
      #     eDP1.enable = true;
      #     DP3.enable = false;
      #     DP4.enable = false;
      #   };
      #   hooks.postswitch = {
      #   };
      # };
      # profiles."docked" = {
      #   fingerprint = {
      #     eDP1 = "00ffffffffffff000e6f071400000000011e0104b51f117803d89eaf4f45b1270f52540000000101010101010101010101010101010140ce00a0f07028803020350035ae10000018000000fd00283c848435010a202020202020000000fe0043534f542054330a2020202020000000fe004d4e453030314541312d350a2001aa02031d00e3058000e60605016a6a246d1a00000203283c00046a246a2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007";
      #     DP3 = "00ffffffffffff001ab39f08000000001e1c0103803c22782e2895a7554ea3260f5054bb8d80e1c0d140d100d1c0b300a9409500904022cc0050f0703e801810350055502100001a000000ff005956424b3030333832360a2020000000fd0018780fa03c000a202020202020000000fc005032372d38205453205548440a01f0020340f156616065666463625d5e5f100403021f2021221312110123097f07830100006d030c002000183c20006001020367d85dc401788801e3050301e20f7f4dd000a0f0703e803020350055502100001a1a6800a0f0381f4030203a0055502100001a565e00a0a0a029503020350055502100001a000000000000000000a4";
      #     DP4 = "00ffffffffffff001ab3a108000000001e1c0104b53c22783f2895a7554ea3260f5054bb8d00e1c0d140d100d1c0b300a94095009040e2ca0038f0703e801810350055502100001a000000ff005956424b3030343032380a2020000000fd0018780fa03c000a202020202020000000fc005032372d38205453205548440a0186020321f15461666463625d5e5f100403021f2021221312110123097f07830100004dd000a0f0703e803020350055502100001a04740030f2705a80b0588a0055502100001e1a6800a0f0381f4030203a0055502100001a565e00a0a0a029503020350055502100001a0000000000000000000000000000000000000000000064";
      #   };
      #   config = {
      #     eDP1.enable = false;
      #     DP3.enable = true;
      #     DP4.enable = true;
      #   };
      #   hooks.postswitch = {
      #   };
      # };
      # profiles."florian" = {
      #   fingerprint = {
      #     eDP1 = "00ffffffffffff000e6f071400000000011e0104b51f117803d89eaf4f45b1270f52540000000101010101010101010101010101010140ce00a0f07028803020350035ae10000018000000fd00283c848435010a202020202020000000fe0043534f542054330a2020202020000000fe004d4e453030314541312d350a2001aa02031d00e3058000e60605016a6a246d1a00000203283c00046a246a2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007c";
      #     DP1 = "00ffffffffffff004c2da3745536533008220104b55022783aee95a3544c99260f5054bfef80714f810081c081809500a9c0b3000101e77c70a0d0a0295030203a001e4e3100001a000000fd0032641e9737000a202020202020000000fc0053333443363578540a20202020000000ff00484e54583230303336340a2020016902031ef146901f041303122309070783010000e305c000e60605015a5a004ed470a0d0a0465030203a001e4e3100001a565e00a0a0a02950302035001e4e3100001a023a801871382d40582c45001e4e3100001e000000000000000000000000000000000000000000000000000000000000000000000000000000000000008f";
      #   };
      #   config = {
      #     eDP1.enable = true;
      #     DP1.enable = true;
      #   };
      #   hooks.postswitch = {
      #   };
      # };
    };

    ollama.enable = true;
    qdrant.enable = true;

    open-webui.enable = true;
  };

  xdg.portal.enable = true;
  xdg.portal.config.common.default = "*";

  qt = {
    platformTheme = "gnome";
    style = "Adapta";
  };

  fonts = {
    enableDefaultPackages = true;
    enableGhostscriptFonts = true;
    fontDir.enable = true;

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
      gsettings-desktop-schemas
      nerd-fonts.symbols-only
      # inconsolata
    ];

    fontconfig = {
      includeUserConf = false;
      defaultFonts.monospace = [ "Roboto Mono" "DejaVu Sans Mono" ];
    };
  };

  stylix = {
    # https://stylix.danth.me/index.html
    enable = false;
    autoEnable = false;
    base16Scheme = {
      # tokyo-night-moon
      base00 = "222436"; # bg
      base01 = "2f334d"; # bg_highlight
      base02 = "2d3f76"; # bg_visual
      base03 = "636da6"; # comment
      base04 = "828bb8"; # fg_dark
      base05 = "c8d3f5"; # fg
      base06 = "c8d3f5"; # fg (reused)
      base07 = "c8d3f5"; # terminal.white_bright
      base08 = "ff757f"; # red
      base09 = "ff966c"; # orange
      base0A = "ffc777"; # yellow
      base0B = "c3e88d"; # green
      base0C = "86e1fc"; # cyan
      base0D = "82aaff"; # blue
      base0E = "c099ff"; # magenta
      base0F = "4fd6be"; # teal
    };
    targets = { console.enable = true; };
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
