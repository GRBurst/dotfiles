# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib, ... }:

# let
#   phpSocket = "/tmp/php-cgi.socket";
#   webserverDir = "/var/www/webserver";
# in

{
  imports =
    [ # Include the results of the hardware scan.
      <nixos-hardware/lenovo/thinkpad/t480s>
      ./hardware-configuration.nix
    ];

  boot = {
    loader = {
      systemd-boot.enable = true; # Use the systemd-boot EFI boot loader
      efi.canTouchEfiVariables = true;
    };

    # kernelPackages = pkgs.linuxKernel.packages.linux_hardened;
    # kernelPackages = pkgs.linuxPackages_latest;
    # extraModulePackages = [ config.boot.kernelPackages.exfat-nofuse ];

    initrd.luks.devices = {
      root = {
        device = "/dev/disk/by-uuid/d95b210b-6105-43d9-b527-3744578a16cd";
        preLVM = true;
        allowDiscards = true;
      };
    };

    # initrd.mdadmConf = ''
    #   DEVICE partitions
    #   ARRAY /dev/md/nixos:0 metadata=1.2 name=nixos:0 UUID=8b34463c:d38d231e:d6c35510:cd133929
    #   '';

    tmp.useTmpfs = true;

    kernel.sysctl = {
      "fs.inotify.max_user_watches" = "409600";
      "kernel.sysrq" = 1;
      "vm.swappiness" = 1;
    };
  };

  # fileSystems."/media/ateam/ateam" =
  # { device = "//ateam/ateam";
  #   fsType = "cifs";
  #   options = [ "uid=jelias" "username=x" "password=" "x-systemd.automount" "noauto" "_netdev" "x-systemd.device-timeout=30" ];
  # };

  # fileSystems."/media/ateam/upload" =
  #   { device = "//ateam/upload";
  #     fsType = "cifs";
  #     options = [ "uid=jelias" "username=x" "password=" "x-systemd.automount" "noauto" "_netdev" "x-systemd.device-timeout=30" ];
  # };

  sound.enable = true;

  hardware = {
    # pulseaudio = {
    #   enable = true;
    #   package = pkgs.pulseaudioFull;
    #   support32Bit = true; # This might be needed for Steam games
    # };
    bluetooth = {
      enable = true;
      powerOnBoot = true;
    };
    sane.enable = true;
    cpu.intel.updateMicrocode = true;
    opengl = {
      driSupport32Bit = true;
      enable = true;
      extraPackages = with pkgs; [
        mesa.drivers
        intel-media-driver # LIBVA_DRIVER_NAME=iHD
        vaapiIntel         # LIBVA_DRIVER_NAME=i965 (older but works better for Firefox/Chromium)
        vaapiVdpau
        libvdpau-va-gl
      ];
      extraPackages32 = with pkgs.pkgsi686Linux; [ vaapiIntel ];
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
    packageOverrides = pkgs: {
      unstable = import <nixos-unstable> {
        config = config.nixpkgs.config;
      };
    };
  };

  networking = {
    networkmanager = {
      enable = true;
      wifi.macAddress = "random";
      appendNameservers = [ "9.9.9.9" "149.112.112.112" "2620:fe::fe" "2620:fe::9" ];
      # logLevel = "TRACE";
      # dns = "none";
      # appendNameservers = [ "1.1.1.1" "1.0.0.1" "2606:4700:4700::1111" "2606:4700:4700::1001" ];
    };
    enableIPv6 = true;
    firewall.enable = true;
    firewall.allowedTCPPorts = [ 12345 15432 ];
    firewall.allowedUDPPorts = [ 50624 50625 ]; # Firefox WebIDE
    hostName = "mars";
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
      neovim
      adapta-gtk-theme adapta-kde-theme
      protonvpn-cli
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

  nix = {
    daemonIOSchedPriority = 7;
    settings = {
      cores = 4;
      max-jobs = 16;
      sandbox = true;
    };
    gc = {
      automatic = true;
      dates = "monthly";
      options = "--delete-older-than 90d";
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

    bash.enableCompletion = true;

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
	# pam.services.lightdm.enableGnomeKeyring = true;
	# pam.services.login.enableGnomeKeyring = true;
	# pam.services.i3lock.enableGnomeKeyring = true;

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
      # slock.source = "${pkgs.slock}/bin/slock";
    };

    sudo = {
      enable = true;
      wheelNeedsPassword = true;
    };
  };


  # List services that you want to enable:
  services = {

    # # Testing
    # amdgpu-fan = {
    #   enable = true;
    # };

    # udev.extraRules = ''
    #   SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", ATTR{capacity}=="[0-5]", RUN+="/run/current-system/sw/bin/systemctl hibernate"
    #   SUBSYSTEM=="power_supply", ATTR{status}=="Discharging", RUN+="/run/current-system/sw/bin/touch /tmp/discharging"
    # '';

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

    keybase.enable = true;
    kbfs = {
      enable = true;
      #mountPoint = "/keybase"; # mountpoint important for keybase-gui
    };

    # dbus.packages = with pkgs; [ dconf gnome2.GConf gnome3.gnome-keyring gcr ];

    openssh = {
      enable = true;
      ports = [ 53292 ];
      settings = {
        forwardX11 = true;
        # passwordAuthentication = false;
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
    # smartd.enable = true;

    printing = {
      enable = true;
      drivers = [ pkgs.gutenprint pkgs.hplip pkgs.epson-escpr ];
    };

    pipewire = {
      enable = true;
      pulse.enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      jack.enable = true;
    };

    xserver = {
      enable = true;
      dpi = 192;
      videoDrivers = [ "modesetting" ];
      layout = "de,de";
      xkbVariant = "neo,basic";
      xkbOptions = "grp:menu_toggle";

      libinput = {
        enable = true;
        touchpad = {
          scrollMethod = "twofinger";
          disableWhileTyping = true;
          tapping = false;
        };
      };

      displayManager = {
        lightdm.enable = true;
        autoLogin = {
          enable = false;
          user = "jelias";
        };
        defaultSession = "none+i3";

        #setupCommands = ''
        #  gnome-keyring-daemon --start --components=pkcs11,secrets,ssh
        #'';
      };

      desktopManager.xterm.enable  = false;
      windowManager = {
        i3 = {
          enable = true;
          extraPackages = with pkgs; [ feh rofi i3status-rust i3lock gnome3.gnome-keyring ];
          extraSessionCommands = ''
            xsetroot -bg black
            xsetroot -cursor_name left_ptr
            gnome-keyring-daemon --start -d --components=pkcs11,secrets,ssh
            feh --bg-scale '/home/jelias/.config/i3/background0.jpg' '/home/jelias/.config/i3/background1.jpg' &
            deadd-notification-center &
          '';
        };
      };
    };

    picom = {
      enable = true;
      backend = "glx";
      vSync = true;
    };

    # nginx = {
    #   enable = false;
    #   recommendedGzipSettings = true;
    #   recommendedOptimisation = true;
    #   recommendedProxySettings = true;
    #   user = "ngnix";
    #   statusPage = true;
    #   upstreams."php-upstream".extraConfig = ''
    #     server unix:${phpSocket};
    #     server 127.0.0.1:9000;
    #   '';
    #   virtualHosts."localhost" = {
    #     root = "${webserverDir}";
    #     listen = [ { addr = "127.0.0.1"; port = 80; } { addr = "localhost"; port = 80; } ];
    #     locations = {
    #       "/syncthing".proxyPass = "http://localhost:8384";
    #       "/woost".proxyPass = "http://localhost:12345";
    #       "/" = {
    #         index = "index.php index.html index.htm";
    #       };
    #       "/blog" = {
    #         index = "index.php index.html index.htm";
    #         tryFiles = "$uri $uri/ /index.php$is_args$args";
    #       };
    #       "/favicon.ico" = {
    #         extraConfig = ''
    #           log_not_found off;
    #           access_log off;
    #           expires max;
    #         '';
    #       };
    #       "/robots.txt" = {
    #         extraConfig = ''
    #           allow all;
    #           log_not_found off;
    #           access_log off;
    #         '';
    #       };
    #       "~ \.php$" = {
    #         extraConfig = ''
    #           fastcgi_intercept_errors on;
    #           fastcgi_pass php-upstream;
    #           fastcgi_buffers 16 16k;
    #           fastcgi_buffer_size 32k;
    #         '';
    #       };
    #       "~* \.(js|css|png|jpg|jpeg|gif|ico)$" = {
    #         extraConfig = ''
    #           expires max;
    #           access_log off;
    #           log_not_found off;
    #         '';
    #       };
    #       "~ /\.ht" = {
    #         extraConfig = ''deny all;'';
    #       };
    #     };
    #   };
    # };

    # mysql = {
    #   enable = false;
    #   package = pkgs.mariadb;
    #   bind = "127.0.0.1";
    #   initialDatabases = [ { name = "wp"; } { name = "wb"; } ];
    #   ensureDatabases = [ "wp" "wb" ];
    #   ensureUsers = [
    #     { ensurePermissions = { "wp.*" = "ALL PRIVILEGES"; }; name = "wp"; } # wordpress
    #     { ensurePermissions = { "wb.*" = "ALL PRIVILEGES"; }; name = "wb"; } # wallabag
    #   ];
    # };

    #phpfpm = {
    #  pools.nginx = {
    #    listen = "${phpSocket}";
    #    extraConfig = ''
    #      listen.owner = nginx
    #      listen.group = nginx
    #      user = nginx
    #      group = nginx
    #      pm = dynamic
    #      pm.max_children = 4
    #      pm.start_servers = 2
    #      pm.min_spare_servers = 1 
    #      pm.max_spare_servers = 4
    #      pm.max_requests = 32
    #      php_admin_value[error_log] = 'stderr'
    #      php_admin_flag[log_errors] = on
    #      env[PATH] = ${lib.makeBinPath [ pkgs.php ]}
    #      catch_workers_output = yes
    #    '';
    #      #php_flag[display_errors] = off
    #      #php_admin_value[error_log] = "/run/phpfpm/php-fpm.log"
    #      #php_admin_flag[log_errors] = on
    #      #php_value[date.timezone] = "UTC"
    #  };
    #    #;extension=${pkgs.phpPackages.redis}/lib/php/extensions/redis.so
    #  phpOptions = ''
    #    extension=bcmath
    #    extension=ctype
    #    extension=curl
    #    extension=dom
    #    extension=gd
    #    extension=gettext
    #    extension=hash
    #    extension=iconv
    #    extension=json
    #    extension=mbstring
    #    extension=session
    #    extension=simplexml
    #    extension=tidy
    #    extension=tokenizer
    #    extension=xml
    #    extension=zip

    #    extension=pdo_mysql
    #  '';
    #};

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
      user = "jelias";
      configDir = "/home/jelias/.config/syncthing";
      dataDir = "/home/jelias/.config/syncthing";
      openDefaultPorts = true;
      systemService = true;
      package = pkgs.unstable.syncthing;
    };

    locate = {
      enable = true;
      interval = "22:00";
    };

    psd = {
      enable = true;
      # users = ["jelias"];
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

    # ipfs = {
    #   enable = true;
    # };
  };

  # systemd.services.delayedHibernation = {
  #   description = "Delayed hibernation trigger";
  #   documentation = [ "https://wiki.archlinux.org/index.php/Power_management#Delayed_hibernation_service_file" ];
  #   conflicts = ["hibernate.target" "hybrid-sleep.target"];
  #   before = ["sleep.target"];
  #   # stopWhenUnneeded = true; # TODO
  #   serviceConfig = {
  #     Type = "oneshot";
  #     RemainAfterExit = "yes";
  #     Environment = [ "WAKEALARM=/sys/class/rtc/rtc0/wakealarm" "SLEEPLENGTH=+2hour" ];
  #     ExecStart = "-/usr/bin/sh -c 'echo -n \"alarm set for \"; date +%%s -d$SLEEPLENGTH | tee $WAKEALARM'";
  #     ExecStop = ''
  #       -/usr/bin/sh -c '\
  #         alarm=$(cat $WAKEALARM); \
  #         now=$(date +%%s); \
  #         if [ -z "$alarm" ] || [ "$now" -ge "$alarm" ]; then \
  #            echo "hibernate triggered"; \
  #            systemctl hibernate; \
  #         else \
  #            echo "normal wakeup"; \
  #         fi; \
  #         echo 0 > $WAKEALARM; \
  #       '
  #     '';
  #   };

  #   wantedBy = [ "sleep.target" ];
  # };

  # systemd.services.delayedHibernation.enable = true;

  qt = {
    platformTheme = "gnome";
    style = "Adapta";
  };

  fonts = {
    fontDir.enable = true;
    enableGhostscriptFonts = true;

    fonts = with pkgs; [
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
  users.extraUsers.jelias = {
    isNormalUser = true;
    extraGroups = [ "wheel" "video" "audio" "vboxusers" "docker" "fuse" "scanner" "adbusers" "networkmanager" ];
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+BIE+0anEEYK0fBIEpjedblyGW0UnuYBCDtjZ5NW6P jelias@merkur"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAflU8X4g3kboxgFQPAxeadUY97iZoV0IPEwK61lZFW5 jelias@venus->jupiter on 2018-02-22"
    ];
  };
  users.extraUsers.dev = {
    isNormalUser = true;
    extraGroups = [ "video" "audio" ];
    shell = pkgs.fish;
  };

  # users.extraUsers.dev = {
  #   isNormalUser = true;
  #   extraGroups = [ "vboxusers" "docker" "adbusers" "networkmanager" ];
  #   useDefaultShell = true;
  #   openssh.authorizedKeys.keys = [
  #     "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDU3dAvm/F8DksvT2fQ1804/ScajO20OxadixGD8lAPINLbCj7mRpLJmgnVjdJSSHQpaJXsDHjLul4Z4nuvgcOG2cjtI+/Z2d1AC+j5IDTJNs6yGgyzkRalPYWXKpzrOa/yQcVpJyGsliKyPuyc9puLJIQ0vvosVAUxN6TLMfnrgdtnZMsuQecToJ8AgyEgsGedOnYC2/1ELUJEdh2v2LMr2saWJW/HTptTotbS8Fwz+QWZPAxXWlEbH5r5LEma3xpn/7oiE4JKr7DL7bE4jWVgW0yrOZL0EAVm771oigqcS/ekTqLutVoFmcH0ysInsWKjnuT02+PIjDJdGODwlE5P felix@beef"
  #   ];
  # };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "22.11"; # Did you read the comment?

}
