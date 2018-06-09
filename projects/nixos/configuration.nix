# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  # Use the systemd-boot EFI boot loader.
  boot = {
    loader = {
      # Use the systemd-boot EFI boot loader
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;

    initrd.mdadmConf = ''
      DEVICE partitions
      ARRAY /dev/md/nixos:0 metadata=1.2 name=nixos:0 UUID=8b34463c:d38d231e:d6c35510:cd133929
      '';
    tmpOnTmpfs = true;

    kernel.sysctl = {
      "vm.swappiness" = 0;
    };
  };

  nixpkgs.config = {
    allowUnfree = true;
  };

  hardware = {
    pulseaudio.enable = true;
    pulseaudio.support32Bit = true; # This might be needed for Steam games
    opengl.driSupport32Bit = true;
    sane.enable = true;
    cpu.intel.updateMicrocode = true;
  };

  networking = {
    networkmanager.enable = true;
    hostName = "jupiter";
    extraHosts = ''
      134.130.59.240  ateam
      134.130.57.2    sylvester
      134.130.57.147  godzilla
    '';
  };

  # Select internationalisation properties.
  i18n = {
    consoleKeyMap = "neo";
    defaultLocale = "en_US.UTF-8";
  };

  # Set your time zone.
  time.timeZone = "Europe/Berlin";

  # List packages installed in system profile. To search by name, run:
  # $ nix-env -qaP | grep wget
  # These are installed system-wide
  environment = {
    systemPackages = with pkgs; [
      # Security
      gnome3.gnome_keyring gnome3.seahorse libsecret
      openssl
    ];

    shellAliases = {
      l = "ls -l";
      t = "tree -C"; # -C is for color=always
      vn = "vim /etc/nixos/configuration.nix";
    };

    # TODO: Move to .profile
    variables = {
      SUDO_EDITOR = "nvim";
      EDITOR = "nvim";
      BROWSER = "firefox";
      _JAVA_OPTIONS=" -Xbootclasspath/p:$HOME/local/jars/neo2-awt-hack-0.4-java8oracle.jar";
      SBT_OPTS="$SBT_OPTS -Xms64M -Xmx4G -Xss4M -XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC";
      #SSH_AUTH_SOCK = "%t/keyring/ssh";
    };
  };


  nix.maxJobs = 16;
  nix.buildCores = 4;

  nix.gc.automatic = true;
  nix.gc.dates = "01:15";
  nix.gc.options = "--delete-older-than 7d";
  system.autoUpgrade.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  programs = {
    bash.enableCompletion = true;
    command-not-found.enable = true;
    adb.enable = true;
    #mtr.enable = true;
    gnupg.agent = { 
      enable = true;
      enableSSHSupport = true;
    };
    # ssh.startAgent = true;
    zsh.enable = true;
    zsh.enableCompletion = true;
  };
  users.defaultUserShell = "/run/current-system/sw/bin/zsh";


  security = {
    pam.services = [
      {
         name = "gnome_keyring";
         text = ''
           auth     optional    pam_gnome_keyring.so
           session  optional    pam_gnome_keyring.so auto_start
           password optional    pam_gnome_keyring.so
         '';
       }
    ];
    #// TODO: pmount needs /media folder (create it automatically)
    wrappers = {
      pmount.source = "${pkgs.pmount}/bin/pmount";
      pumount.source = "${pkgs.pmount}/bin/pumount";
      eject.source = "${pkgs.eject}/bin/eject";
    };
    sudo = {
      enable = true;
      wheelNeedsPassword = false;
    };
  };


  # List services that you want to enable:
  services = {

    keybase.enable = true;
    kbfs.enable = true;

    openssh = {
      enable = true;
      ports = [ 53292 ];
      passwordAuthentication = false;
    };

    journald = {
      extraConfig = ''
        Storage=persist
        Compress=yes
        SystemMaxUse=128M
        RuntimeMaxUse=8M
      '';
    };

    fstrim.enable = true;
    smartd.enable = true;

    printing = {
      enable = true;
      drivers = [ pkgs.hplip pkgs.epson-escpr ];
    };

    xserver = {
      enable = true;
      videoDrivers = [ "nvidia" ];
      layout = "de,de";
      xkbVariant = "neo,basic";
      xkbOptions = "grp:menu_toggle";
      displayManager.lightdm.enable = true;
      windowManager.i3.enable = true;
    };
    # compton.enable = true;
    redshift = {
      enable = true;
      latitude = "50.77";
      longitude = "6.08";
      temperature.day = 5000;
      temperature.night = 3000;
      brightness.day = "1.0";
      brightness.night = "0.75";
    };
    # unclutter-xfixes.enable = true; # not working?

    syncthing = {
      enable = true;
      user = "jelias";
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
      users = ["jelias"];
    };

    clamav = {
      daemon.enable   = true;
      daemon.extraConfig = ''
        TCPAddr   127.0.0.1
        TCPSocket 3310
      '';
      updater.enable  = true;
    };

    upower.enable  = true;
    gnome3.gvfs.enable  = true;
    gnome3.gnome-keyring.enable = true;
    udisks2.enable = true;

    # ipfs = {
    #   enable = true;
    # };
  };

  fonts = {
    enableFontDir = true;
    enableGhostscriptFonts = true;
    fonts = with pkgs; [
      corefonts
      dejavu_fonts
      # opensans-ttf
      symbola # many unicode symbols
      ubuntu_font_family
      inconsolata
      font-droid # needed for firefox
      siji # polybar icon font
    ];
    fontconfig = {
      includeUserConf = false;
      defaultFonts.monospace = [ "Inconsolata" "DejaVu Sans Mono" ];
    };
  };

  # virtualisation.virtualbox.host.enable = true;
  # nixpkgs.config.virtualbox.enableExtensionPack = true;
  virtualisation.docker.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.extraUsers.jelias = {
    isNormalUser = true;
    extraGroups = [ "wheel" "vboxusers" "docker" "scanner" "adbusers" "networkmanager" ];
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIM+BIE+0anEEYK0fBIEpjedblyGW0UnuYBCDtjZ5NW6P jelias@merkur"
      "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIAflU8X4g3kboxgFQPAxeadUY97iZoV0IPEwK61lZFW5 jelias@venus->jupiter on 2018-02-22"
    ];
  };

  users.extraUsers.dev = {
    isNormalUser = true;
    extraGroups = [ "vboxusers" "docker" "adbusers" "networkmanager" ];
    useDefaultShell = true;
    openssh.authorizedKeys.keys = [
      "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDU3dAvm/F8DksvT2fQ1804/ScajO20OxadixGD8lAPINLbCj7mRpLJmgnVjdJSSHQpaJXsDHjLul4Z4nuvgcOG2cjtI+/Z2d1AC+j5IDTJNs6yGgyzkRalPYWXKpzrOa/yQcVpJyGsliKyPuyc9puLJIQ0vvosVAUxN6TLMfnrgdtnZMsuQecToJ8AgyEgsGedOnYC2/1ELUJEdh2v2LMr2saWJW/HTptTotbS8Fwz+QWZPAxXWlEbH5r5LEma3xpn/7oiE4JKr7DL7bE4jWVgW0yrOZL0EAVm771oigqcS/ekTqLutVoFmcH0ysInsWKjnuT02+PIjDJdGODwlE5P felix@beef"
    ];
  };

  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.03"; # Did you read the comment?

}
