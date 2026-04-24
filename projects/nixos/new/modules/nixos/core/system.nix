{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.nixos.core.system;
in {
  options.my.nixos.core.system = {
    enable = lib.mkEnableOption "System Tweaks & Maintenance";
    commandLookup = lib.mkOption {
      type = lib.types.enum ["none" "command-not-found" "nix-index"];
      default = "none";
      description = "Which missing-command helper to enable. They are mutually exclusive.";
    };
    bashCompletion = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable programs.bash.completion.";
    };
  };

  config = lib.mkIf cfg.enable {
    # Nix Settings
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

    # Kernel & Boot
    boot.tmp.useTmpfs = true;
    boot.kernel.sysctl = {
      "fs.inotify.max_user_watches" = "409600";
      "kernel.sysrq" = 1;
      "vm.swappiness" = 1;
    };

    # Insecure Packages (Required for OpenSSL 1.1.1w)
    nixpkgs.config.permittedInsecurePackages = [
      "openssl-1.1.1w"
    ];

    # Security Wrappers (PMount, Light, Beep)
    security.wrappers = {
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
      beep = {
        setgid = true;
        owner = "root";
        group = "users";
        source = "${pkgs.beep}/bin/beep";
      };
    };

    # Power Management (Powertop)
    powerManagement = {
      enable = true;
      cpuFreqGovernor = "performance";
      powertop.enable = true;
    };

    programs = {
      fish.enable = true;
      nix-ld.enable = true;
      command-not-found.enable = cfg.commandLookup == "command-not-found";
      nix-index.enable = cfg.commandLookup == "nix-index";
      bash.completion.enable = cfg.bashCompletion;
    };
  };
}
