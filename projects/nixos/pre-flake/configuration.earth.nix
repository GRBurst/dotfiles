# Edit this configuration file to define what should be installed on
# your system. Help is available in the configuration.nix(5) man page, on
# https://search.nixos.org/options and in the NixOS manual (`nixos-help`).

{ config, lib, pkgs, ... }:

{
  imports =
    [ # Include the results of the hexposeardware scan.
    ./hardware-configuration.nix
  ];

# Use the systemd-boot EFI boot loader.
  boot = {
    loader = { 
      systemd-boot.enable = true;
      # systemd-boot.enable = lib.mkForce false;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    tmp.useTmpfs = true;
    kernel.sysctl = {
      "kernel.sysrq" = 1;
      "vm.swappiness" = 1;
      "fs.inotify.max_user_instances" = "8192";
      "fs.inotify.max_user_watches" = "409600";
    };
    # lanzaboote = {
    #   enable = true;
    #   pkiBundle = "/etc/secureboot";
    # };
  };


  security.tpm2 = {
    enable = true;
    pkcs11.enable = true;
    tctiEnvironment.enable = true;
  };

  nix.settings = {
    trusted-users = [ "jelias" ];
    experimental-features = [ "nix-command" "flakes" ];
  };
  nixpkgs.config.allowUnfree = true;

  hardware = {
    pulseaudio.enable = false;
    bluetooth = {
      enable = true;
      powerOnBoot = false;
      # hsphfpd.enable = true;
      # package = pkgs.bluezFull;
    };

    graphics = {
      enable = true;
      enable32Bit = true;
    };

    cpu.amd.updateMicrocode = true;
    acpilight.enable = true;
  };


  networking = {
    networkmanager = {
      enable = true;
      ethernet.macAddress = "random";
      appendNameservers = [ "9.9.9.9" "149.112.112.112" "2620:fe::fe" "2620:fe::9" ];
      plugins = with pkgs; [
        networkmanager-openconnect
        networkmanager-openvpn
      ];
    };
    # enableIPv6 = false;
    firewall.enable = true;
    hostName = "earth";
    extraHosts = ''
      127.0.0.1       *.localhost *.localhost.localdomain
    '';
    # networking.wireless.enable = true;
    firewall.allowedUDPPorts = [ 
      8472  # k3s, flannel: required if using multi-node for inter-node networking
      12345 # General Purpose
      50624 # Firefox WebIDE
      50625 # Firefox WebIDE
    ]; 
    firewall.allowedTCPPorts = [ 
      6443  # k3s: required so that pods can reach the API server (running on port 6443 by default)
      12345 # General Purpose
      8080  # Dev General Purpose
    ];
  };

  location = {
    provider = "manual";
    latitude = 50.77;
    longitude = 6.08;
  };

  console.keyMap = "neo";
  i18n = {
    #consoleFont = "Lat2-Terminus16";
    defaultLocale = "en_US.UTF-8";
  };

  time.timeZone = "Europe/Berlin";

  environment = {
    systemPackages = with pkgs; [
      neovim vim
      git
      wget
      curl

      protonvpn-cli protonvpn-gui protonmail-bridge
      hdparm
    ];
    shellAliases = {
      l = "ls -l";
      t = "tree -C"; # -C is for color=always
      vn = "nvim /etc/nixos/configuration.nix";
    };

    variables = {
      EDITOR = "nvim";
      SUDO_EDITOR = "nvim";
      VISUAL = "nvim";

      BROWSER = "librewolf";

      SBT_OPTS="-Xms1G -Xmx4G -Xss16M";

    };
  };

  nix.gc = {
    automatic = true;
    dates = "monthly";
    options = "--delete-older-than 7d";
  };

  system.autoUpgrade.enable = true;

  programs = {

    command-not-found.enable = true;
    ausweisapp = {
      enable = true;
      openFirewall = true;
    };

    noisetorch.enable = true;

    bash.completion.enable = true;

    zsh = {
      enable = true;
      enableCompletion = true;
    };
    fish.enable = true;

    adb.enable = true;

    seahorse.enable = true;
    gpaste.enable = true;

    firefox = {
      enable = true;
      package = pkgs.librewolf;
      nativeMessagingHosts.packages = [ pkgs.tridactyl-native ];
    };
    java.enable = true;

    # ssh.startAgent = true;
    gnupg.agent = { 
    enable = true;
    enableSSHSupport = true;
    };

    # qt5ct.enable = true;
    # mtr.enable = true;

    dconf.enable = true;

    light.enable = true;
    screen = {
      enable = true;
      screenrc =
      ''term screen-256color
                termcapinfo xterm*|xs|rxvt* ti@:te@
                startup_message off
                caption string '%{= G}[ %{G}%H %{g}][%= %{= w}%?%-Lw%?%{= R}%n*%f %t%?%{= R}(%u)%?%{= w}%+Lw%?%= %{= g}][ %{y}Load: %l %{g}][%{B}%Y-%m-%d %{W}%c:%s %{g}]'
                caption always
      '';
    };

    steam.enable = true;

  };

  security = {
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
    };

    sudo = {
      enable = true;
      wheelNeedsPassword = true;
    };
  };

  users.defaultUserShell = "/run/current-system/sw/bin/zsh";

  users.users.jelias = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "vboxusers" "docker" "fuse" "adbusers" "networkmanager" "wireshark" "pipewire" "tss" ];
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [ ];
  };

  services = {

    openssh = {
      enable = true;
      ports = [ 53292 ];
      settings = {
        X11Forwarding = true;
        PasswordAuthentication = false;
      };
    };


    # resolved = {
    #   enable = true;
    # };

    # k3s = {
    #   enable = false;
    #   role = "server";
    #   extraFlags = "'--kubelet-arg=resolv-conf=/etc/k3-resolv.conf'";
    #   # extraFlags = "'--kubelet-arg=resolv-conf=/run/systemd/resolve/resolv.conf'";
    # };

    avahi.enable = true;
    avahi.nssmdns4 = true;

    journald = {
      extraConfig = ''
            Storage=persistent
            Compress=yes
            SystemMaxUse=128M
            RuntimeMaxUse=8M
      '';
    };

    fstrim.enable = true;
    smartd = {
      enable = true;
      autodetect = true;
    # devices = [
    #   {
    #     device = "/dev/disk/by-id/ata-Samsung_SSD_840_EVO_250GB_S1DBNSAF858931R";
    #   }
    # ];
    };

    pipewire = {
      enable = true;
      audio.enable = true;
      pulse.enable = true;
      jack.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
    };

    xserver = {
      enable = true;
      dpi = 192;
      videoDrivers = [ "nvidia" ];
      # screenSection = ''
      #   Option "metamodes" "nvidia-auto-select +0+0 {ForceCompositionPipeline=On}"
      # '';
      xkb = {
        layout = "de,de";
        variant = "neo,basic,basic";
        options = "grp:menu_toggle";
      };

      xrandrHeads = [
        { output = "DP-0"; primary = true; }
        { output = "HDMI-1"; }
      ];

      desktopManager = {
        xterm.enable = false;
        plasma5.enable = false;
        gnome.enable = true;
      };

      displayManager = {
        lightdm = {
          enable = true;
        };
      };

      windowManager = {
        i3 = {
          enable = true;
          extraPackages = with pkgs; [ feh rofi i3status-rust i3lock gnome-keyring ];
          extraSessionCommands = ''
            xsetroot -bg black
            xsetroot -cursor_name left_ptr
            gnome-keyring-daemon --start -d --components=pkcs11,secrets,ssh
            feh --bg-scale '/home/jelias/.config/i3/background0.jpg' '/home/jelias/.config/i3/background1.jpg'
          '';
        };
      };
    };

    displayManager = {
      autoLogin = {
        enable = false;
        user = "jelias";
      };
      defaultSession = "none+i3";
    };


    compton.enable = true;

    redshift = {
      enable = true;
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
    };

    clamav = {
      daemon.enable   = true;
      daemon.settings = {
        TCPAddr = "127.0.0.1";
        TCPSocket = 3310;
      };
      updater.enable  = true;
    };

    gvfs.enable  = true;

    gnome = {
      gnome-keyring.enable = true;
    };
    usbmuxd.enable = true;
    upower.enable  = true;
    udisks2.enable = true;
    flatpak.enable = true;

    # acpid.enable = true;

  };

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;

    packages = with pkgs; [
      corefonts # Arial, Verdana, ...
      dejavu_fonts
      google-fonts # Droid Sans, Roboto, ...
      liberation_ttf
      powerline-fonts
      ubuntu_font_family
      symbola # unicode symbols
      vistafonts # Consolas, ...
      font-awesome
# inconsalata
      ];

      fontconfig = {
        includeUserConf = true;
        defaultFonts.monospace = [ "Roboto Mono" "DejaVu Sans Mono" ];
      };
    };

    virtualisation.docker = {
      enable = true;
    };

    system.stateVersion = "24.05"; # Did you read the comment?

}

