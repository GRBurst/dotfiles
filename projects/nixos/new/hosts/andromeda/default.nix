{ pkgs, inputs, ... }: {
  imports = [
    ./hardware-configuration.nix
    ./../../modules/nixos/core/nixpkgs.nix
    inputs.nixos-hardware.nixosModules.lenovo-thinkpad-p14s-amd-gen2
  ];

  networking.hostName = "andromeda"; 
  system.stateVersion = "25.11"; 

  console.keyMap = "neo";

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelParams = [ "usbcore.autosuspend=-1" ];
    initrd.systemd.enable = true;
  };

  # nixpkgs.config.allowUnfree = true;
  # {
  #   nixpkgs.config.allowUnfreePredicate = pkg: builtins.elem (lib.getName pkg) [
  #     "spotify"
  #   ];
  # }

  # --- Hardware & Power ---
  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
    sane.enable = true;
  };

  # time.timeZone = "Europe/Berlin";
  i18n.defaultLocale = "en_US.UTF-8";
  location = {
    provider = "manual";
    latitude = 50.77;
    longitude = 6.08;
  };

  # -- Enable System Features --
  my.nixos = {
    core = {
      audio.enable = true;
      input.enable = true;
      laptop.enable = true;
      networking.enable = true;
      packages.enable = true;
      system.enable = true;
      user.enable = true;
    };
    features = {
      ai.enable = true;
      desktop.addons.enable = true;
      desktop.hyprland.enable = true;
      desktop.i3.enable = true;
      fonts.enable = true;
      security.enable = true;
      stylix.enable = true;
      virtualisation.enable = true;
      # wired.enable = true;
    };
    services = {
      maintenance.enable = true;
      printing.enable = true;
      ssh.enable = true;
      syncthing.enable = true;
    };
  };

  # -- User Configuration (Home Manager) --
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [ inputs.wired.homeManagerModules.default ];
    users.pallon = {
      imports = [ ../../homes/pallon ];
      my.hm.features.env.enable = true;
      # my.hm.features.wired.enable = true;
    };
    extraSpecialArgs = { inherit inputs; };
  };
}
