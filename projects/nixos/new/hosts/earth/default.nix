{
  pkgs,
  inputs,
  lib,
  ...
}: {
  imports = [
    ./hardware-configuration.nix
    ./../../modules/nixos/core/nixpkgs.nix
  ];

  networking.hostName = "earth";
  system.stateVersion = "25.11";
  time.timeZone = lib.mkForce "Europe/Berlin";
  services.automatic-timezoned.enable = lib.mkForce false;
  console.keyMap = "neo";
  i18n.defaultLocale = "en_US.UTF-8";
  location = {
    provider = "manual";
    latitude = 50.77;
    longitude = 6.08;
  };

  boot = {
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    initrd.availableKernelModules = ["r8169"];
  };

  hardware = {
    bluetooth = {
      enable = true;
      powerOnBoot = false;
    };
    graphics = {
      enable = true;
      enable32Bit = true;
    };
    acpilight.enable = true;
  };

  nixpkgs.config.cudaSupport = true;

  my.nixos = {
    core = {
      audio.enable = true;
      caches = {
        enable = true;
        extraSubstituters = ["https://cuda-maintainers.cachix.org"];
        extraTrustedPublicKeys = [
          "cuda-maintainers.cachix.org-1:0dq3bujKpuEPMCX6U4WylrUDZ9JyUG0VpVZa7CNfq5E="
        ];
      };
      input.enable = true;
      networking = {
        enable = true;
        extraTcpPorts = [6443 8080];
        extraUdpPorts = [8472 12345];
        macAddressPolicy = "random";
      };
      packages.enable = true;
      system = {
        enable = true;
        commandLookup = "command-not-found";
      };
      user.users.jelias = {
        enable = true;
        isPrimary = true;
        trusted = true;
        extraGroups = [
          "wheel"
          "video"
          "audio"
          "vboxusers"
          "docker"
          "fuse"
          "adbusers"
          "networkmanager"
          "wireshark"
          "pipewire"
          "tss"
        ];
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDeEb4AnnxoSa1OJS1Byr6GvxeTiino4nLgxhEi3nb3k jelias@mars->earth on 2024-09-03"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIOXRBBe/0pRVPcLvZVveqmdg0BdhSOs8DD/U1wp94WJa pallon@andromeda->earth on 2024-09-22"
        ];
      };
    };

    features = {
      ai = {
        enable = true;
        ollamaPackage = pkgs.ollama-cuda;
      };
      ausweisapp.enable = true;
      coolercontrol.enable = true;
      desktop = {
        addons.enable = true;
        compositor = "compton";
        displayManager = "lightdm";
        defaultSession = "none+i3";
        autoLogin = false;
        gnome.enable = true;
        i3.enable = true;
        xserver = {
          enable = true;
          dpi = 192;
          videoDrivers = ["nvidia"];
          xkb = {
            layout = "de,de";
            variant = "neo,basic,basic";
            options = "grp:menu_toggle";
          };
          xrandrHeads = [
            {
              output = "DP-2";
              primary = true;
            }
            {output = "DP-4";}
          ];
        };
      };
      firefox.enable = true;    # defaults to pkgs.librewolf (uncached); re-enable after cache warms
      fonts.enable = true;
      nvidia.enable = true;
      security = {
        enable = true;
        clamav.tcpSocket = {
          addr = "127.0.0.1";
          port = 3310;
        };
      };
      steam.enable = true;
      stylix.enable = true;
      tpm2.enable = true;
      virtualisation.enable = true;
    };

    services = {
      maintenance.enable = true;
      printing.enable = true;
      smartd.enable = true;
      ssh = {
        enable = true;
        extraSettings = {
          X11Forwarding = true;
          PasswordAuthentication = false;
        };
      };
      syncthing.enable = true;
    };
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    sharedModules = [inputs.wired.homeManagerModules.default];
    users.jelias = {
      imports = [../../homes/jelias];
      my.hm.features.env.enable = true;
    };
    extraSpecialArgs = {inherit inputs;};
  };
}
