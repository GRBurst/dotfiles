{
  pkgs,
  inputs,
  ...
}: {
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
    kernelParams = ["usbcore.autosuspend=-1"];
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
      caches.enable = true;
      input.enable = true;
      laptop.enable = true;
      networking.enable = true;
      packages.enable = true;
      system = {
        enable = true;
        commandLookup = "none";
      };
      user.users.pallon = {
        enable = true;
        isPrimary = true;
        trusted = true;
        extraGroups = ["wheel" "video" "audio" "vboxusers" "docker" "fuse" "adbusers" "networkmanager"];
        authorizedKeys = [
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDeEb4AnnxoSa1OJS1Byr6GvxeTiino4nLgxhEi3nb3k jelias@mars->earth on 2024-09-03"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINeE9P89x92Ru53ts6tn0WYo+RuB/vwJl02b3++91Wqg localphone"
          "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDVjFtnb4ZAITM+fsju2v+bjADy5pECM+U+BDHoZZHYu jelias@earth->andromeda on 2026-04-23"
        ];
      };
    };
    features = {
      ai.enable = true;
      desktop = {
        addons.enable = true;
        hyprland.enable = true;
        i3.enable = true;
        xserver = {
          enable = true;
          dpi = 192;
          videoDrivers = ["modesetting"];
          xkb = {
            layout = "de,de";
            variant = "neo,basic";
            options = "grp:menu_toggle";
          };
        };
        displayManager = "sddm";
        defaultSession = "none+i3";
      };
      firefox.enable = true;
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
    sharedModules = [
      inputs.wired.homeManagerModules.default
      inputs.nix-index-database.homeModules.nix-index
      inputs.nvf.homeManagerModules.default
    ];
    users.pallon = {
      imports = [../../homes/pallon];
      my.hm.features.env.enable = true;
      # my.hm.features.wired.enable = true;

      programs.autorandr = let
        mkHook = {
          primary,
          secondary ? null,
        }: let
          sec =
            if secondary != null
            then secondary
            else primary;
        in ''
          "$HOME/.config/i3/scripts/write-display-config.sh" "${primary}" "${sec}"
          ${pkgs.i3}/bin/i3-msg reload
        '';
      in {
        enable = true;
        profiles = {
          laptop = {
            fingerprint = {
              "eDP-1" = "00ffffffffffff0030ae6b4100000000001e0104b51f1178e2d89eaf4f45b1270f52540000000101010101010101010101010101010140ce00a0f07028803020350035ae1000001840ce00a0f07028803020350035ae100000180000000f00ff093cff093c320a020e6f0714000000fe004d4e453030314541312d350a20011802031d00e3058000e60605016a6a246d1a00000203283c00046a246a2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007c";
            };
            config = {
              "eDP-1" = {
                enable = true;
                primary = true;
                mode = "3840x2160";
                position = "0x0";
                rate = "60.00";
                gamma = "1.0:0.667:0.455";
              };
            };
            hooks.postswitch = mkHook {primary = "eDP-1";};
          };

          docked = {
            fingerprint = {
              "DP-3" = "00ffffffffffff001ab39e08000000001e1c0103803c22782e2895a7554ea3260f5054bb8d80e1c0d140d100d1c0b300a9409500904022cc0050f0703e801810350055502100001a000000ff005956424b3030333832360a2020000000fd0018780fa03c000a202020202020000000fc005032372d38205453205548440a01f1020340f156616065666463625d5e5f100403021f2021221312110123097f07830100006d030c001000183c20006001020367d85dc401788801e3050301e20f7f4dd000a0f0703e803020350055502100001a1a6800a0f0381f4030203a0055502100001a565e00a0a0a029503020350055502100001a000000000000000000b4";
              "DP-4" = "00ffffffffffff001ab3a108000000001e1c0104b53c22783f2895a7554ea3260f5054bb8d00e1c0d140d100d1c0b300a94095009040e2ca0038f0703e801810350055502100001a000000ff005956424b3030343032380a2020000000fd0018780fa03c000a202020202020000000fc005032372d38205453205548440a0186020321f15461666463625d5e5f100403021f2021221312110123097f07830100004dd000a0f0703e803020350055502100001a04740030f2705a80b0588a0055502100001e1a6800a0f0381f4030203a0055502100001a565e00a0a0a029503020350055502100001a0000000000000000000000000000000000000000000064";
              "eDP-1" = "00ffffffffffff0030ae6b4100000000001e0104b51f1178e2d89eaf4f45b1270f52540000000101010101010101010101010101010140ce00a0f07028803020350035ae1000001840ce00a0f07028803020350035ae100000180000000f00ff093cff093c320a020e6f0714000000fe004d4e453030314541312d350a20011802031d00e3058000e60605016a6a246d1a00000203283c00046a246a2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007c";
            };
            config = {
              "DP-4" = {
                enable = true;
                primary = true;
                mode = "3840x2160";
                position = "0x0";
                rate = "60.00";
                gamma = "1.0:0.667:0.455";
              };
              "DP-3" = {
                enable = true;
                mode = "3840x2160";
                position = "3840x0";
                rate = "60.00";
                gamma = "1.0:0.667:0.455";
              };
              "eDP-1".enable = false;
            };
            hooks.postswitch = mkHook {
              primary = "DP-4";
              secondary = "DP-3";
            };
          };

          docked2 = {
            fingerprint = {
              "DP-5" = "00ffffffffffff001ab39e08000000001e1c0103803c22782e2895a7554ea3260f5054bb8d80e1c0d140d100d1c0b300a9409500904022cc0050f0703e801810350055502100001a000000ff005956424b3030333832360a2020000000fd0018780fa03c000a202020202020000000fc005032372d38205453205548440a01f1020340f156616065666463625d5e5f100403021f2021221312110123097f07830100006d030c001000183c20006001020367d85dc401788801e3050301e20f7f4dd000a0f0703e803020350055502100001a1a6800a0f0381f4030203a0055502100001a565e00a0a0a029503020350055502100001a000000000000000000b4";
              "DP-6" = "00ffffffffffff001ab3a108000000001e1c0104b53c22783f2895a7554ea3260f5054bb8d00e1c0d140d100d1c0b300a94095009040e2ca0038f0703e801810350055502100001a000000ff005956424b3030343032380a2020000000fd0018780fa03c000a202020202020000000fc005032372d38205453205548440a0186020321f15461666463625d5e5f100403021f2021221312110123097f07830100004dd000a0f0703e803020350055502100001a04740030f2705a80b0588a0055502100001e1a6800a0f0381f4030203a0055502100001a565e00a0a0a029503020350055502100001a0000000000000000000000000000000000000000000064";
              "eDP-1" = "00ffffffffffff000e6f071400000000011e0104b51f117803d89eaf4f45b1270f52540000000101010101010101010101010101010140ce00a0f07028803020350035ae10000018000000fd00283c848435010a202020202020000000fe0043534f542054330a2020202020000000fe004d4e453030314541312d350a2001aa02031d00e3058000e60605016a6a246d1a00000203283c00046a246a2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007c";
            };
            config = {
              "DP-6" = {
                enable = true;
                primary = true;
                mode = "3840x2160";
                position = "0x0";
                rate = "60.00";
                gamma = "1.0:0.667:0.455";
              };
              "DP-5" = {
                enable = true;
                mode = "3840x2160";
                position = "3840x0";
                rate = "60.00";
                gamma = "1.0:0.667:0.455";
              };
              "eDP-1".enable = false;
            };
            hooks.postswitch = mkHook {
              primary = "DP-6";
              secondary = "DP-5";
            };
          };

          docked-alternative = {
            fingerprint = {
              "DP-5" = "00ffffffffffff001ab39e08000000001e1c0103803c22782e2895a7554ea3260f5054bb8d80e1c0d140d100d1c0b300a9409500904022cc0050f0703e801810350055502100001a000000ff005956424b3030333832360a2020000000fd0018780fa03c000a202020202020000000fc005032372d38205453205548440a01f1020340f156616065666463625d5e5f100403021f2021221312110123097f07830100006d030c001000183c20006001020367d85dc401788801e3050301e20f7f4dd000a0f0703e803020350055502100001a1a6800a0f0381f4030203a0055502100001a565e00a0a0a029503020350055502100001a000000000000000000b4";
              "DP-6" = "00ffffffffffff001ab3a108000000001e1c0104b53c22783f2895a7554ea3260f5054bb8d00e1c0d140d100d1c0b300a94095009040e2ca0038f0703e801810350055502100001a000000ff005956424b3030343032380a2020000000fd0018780fa03c000a202020202020000000fc005032372d38205453205548440a0186020321f15461666463625d5e5f100403021f2021221312110123097f07830100004dd000a0f0703e803020350055502100001a04740030f2705a80b0588a0055502100001e1a6800a0f0381f4030203a0055502100001a565e00a0a0a029503020350055502100001a0000000000000000000000000000000000000000000064";
              "eDP-1" = "00ffffffffffff0030ae6b4100000000001e0104b51f1178e2d89eaf4f45b1270f52540000000101010101010101010101010101010140ce00a0f07028803020350035ae1000001840ce00a0f07028803020350035ae100000180000000f00ff093cff093c320a020e6f0714000000fe004d4e453030314541312d350a20011802031d00e3058000e60605016a6a246d1a00000203283c00046a246a2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007c";
            };
            config = {
              "DP-6" = {
                enable = true;
                primary = true;
                mode = "3840x2160";
                position = "0x0";
                rate = "60.00";
                gamma = "1.0:0.667:0.455";
              };
              "DP-5" = {
                enable = true;
                mode = "3840x2160";
                position = "3840x0";
                rate = "60.00";
                gamma = "1.0:0.667:0.455";
              };
              "eDP-1".enable = false;
            };
            hooks.postswitch = mkHook {
              primary = "DP-6";
              secondary = "DP-5";
            };
          };

          docked-single = {
            fingerprint = {
              "DP-4" = "00ffffffffffff001ab3a108000000001e1c0104b53c22783f2895a7554ea3260f5054bb8d00e1c0d140d100d1c0b300a9409500904022cc0050f0703e801810350055502100001a000000ff005956424b3030343032380a2020000000fd0018780fa03c000a202020202020000000fc005032372d38205453205548440a012c020321f15461666463625d5e5f100403021f2021221312110123097f07830100004dd000a0f0703e803020350055502100001a04740030f2705a80b0588a0055502100001e1a6800a0f0381f4030203a0055502100001a565e00a0a0a029503020350055502100001a0000000000000000000000000000000000000000000064";
              "eDP-1" = "00ffffffffffff000e6f071400000000011e0104b51f117803d89eaf4f45b1270f52540000000101010101010101010101010101010140ce00a0f07028803020350035ae10000018000000fd00283c848435010a202020202020000000fe0043534f542054330a2020202020000000fe004d4e453030314541312d350a2001aa02031d00e3058000e60605016a6a246d1a00000203283c00046a246a2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007c";
            };
            config = {
              "eDP-1" = {
                enable = true;
                primary = true;
                mode = "3840x2160";
                position = "0x0";
                rate = "60.00";
                gamma = "1.0:0.833:0.769";
              };
              "DP-4" = {
                enable = true;
                mode = "3840x2160";
                position = "3840x0";
                rate = "60.00";
                gamma = "1.0:0.833:0.769";
              };
            };
            hooks.postswitch = mkHook {
              primary = "eDP-1";
              secondary = "DP-4";
            };
          };

          pallon-office = {
            fingerprint = {
              "DP-2" = "00ffffffffffff001e6d0777b41b0400031f0104b53c22789e3e31ae5047ac270c50542108007140818081c0a9c0d1c08100010101014dd000a0f0703e803020650c58542100001a286800a0f0703e800890650c58542100001a000000fd00383d1e8738000a202020202020000000fc004c472048445220344b0a20202001970203197144900403012309070783010000e305c000e3060501023a801871382d40582c45001e4e3100001e565e00a0a0a02950302035001e4e3100001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000029";
              "eDP-1" = "00ffffffffffff000e6f071400000000011e0104b51f117803d89eaf4f45b1270f52540000000101010101010101010101010101010140ce00a0f07028803020350035ae10000018000000fd00283c848435010a202020202020000000fe0043534f542054330a2020202020000000fe004d4e453030314541312d350a2001aa02031d00e3058000e60605016a6a246d1a00000203283c00046a246a2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007c";
            };
            config = {
              "eDP-1" = {
                enable = true;
                primary = true;
                mode = "3840x2160";
                position = "0x0";
                rate = "60.00";
              };
              "DP-2" = {
                enable = true;
                mode = "3840x2160";
                position = "3840x0";
                rate = "60.00";
              };
            };
            hooks.postswitch = mkHook {
              primary = "eDP-1";
              secondary = "DP-2";
            };
          };

          florian = {
            fingerprint = {
              "DP-1" = "00ffffffffffff004c2da3745536533008220104b55022783aee95a3544c99260f5054bfef80714f810081c081809500a9c0b3000101e77c70a0d0a0295030203a001e4e3100001a000000fd0032641e9737000a202020202020000000fc0053333443363578540a20202020000000ff00484e54583230303336340a2020016902031ef146901f041303122309070783010000e305c000e60605015a5a004ed470a0d0a0465030203a001e4e3100001a565e00a0a0a02950302035001e4e3100001a023a801871382d40582c45001e4e3100001e000000000000000000000000000000000000000000000000000000000000000000000000000000000000008f";
              "eDP-1" = "00ffffffffffff000e6f071400000000011e0104b51f117803d89eaf4f45b1270f52540000000101010101010101010101010101010140ce00a0f07028803020350035ae10000018000000fd00283c848435010a202020202020000000fe0043534f542054330a2020202020000000fe004d4e453030314541312d350a2001aa02031d00e3058000e60605016a6a246d1a00000203283c00046a246a2400000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000007c";
            };
            config = {
              "eDP-1" = {
                enable = true;
                primary = true;
                mode = "3840x2160";
                position = "0x0";
                rate = "60.00";
                gamma = "1.0:0.833:0.769";
              };
              "DP-1" = {
                enable = true;
                mode = "3440x1440";
                position = "3840x0";
                rate = "59.97";
                gamma = "1.0:0.833:0.769";
              };
            };
            hooks.postswitch = mkHook {
              primary = "eDP-1";
              secondary = "DP-1";
            };
          };
        };
      };
    };
    extraSpecialArgs = {inherit inputs;};
  };
}
