{
  description = "NixOS configuration of GRBurst";

  nixConfig = {
    experimental-features = ["nix-command" "flakes"];
    extra-substituters = [
      # Nix community's cache server
      "https://nix-community.cachix.org"
      "https://hyprland.cachix.org"
    ];
    extra-trusted-public-keys = [
      "nix-community.cachix.org-1:mB9FSh9qf2dCimDSUo8Zy7bkq5CX+/rkCWyvRCYg3Fs="
      "hyprland.cachix.org-1:a7pgxzMz7+chwVL3/pzj6jIBMioiJM7ypFP8PwtkuGc="
    ];
  };

  inputs = {
    # NixOS official package source, using the nixos-24.11 branch here
    # nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    # nixpkgs-stable.url = "github:NixOS/nixpkgs/nixos-24.11";
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nix-snapd = {
      url = "github:nix-community/nix-snapd";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    stylix = {
      url = "github:danth/stylix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      # url = "github:nix-community/home-manager/release-24.11";
      # The `follows` keyword in inputs is used for inheritance.
      # Here, `inputs.nixpkgs` of home-manager is kept consistent with
      # the `inputs.nixpkgs` of the current flake,
      # to avoid problems caused by different versions of nixpkgs.
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wired.url = "github:Toqozz/wired-notify";
    # hyprland.url = "github:hyprwm/Hyprland";
    # hy3 = {
    #   url = "github:outfoxxed/hy3";
    #   inputs.hyprland.follows = "hyprland";
    # };
  };

  # outputs = { nixpkgs, nixos-hardware, home-manager, hyprland, hy3, wired, nix-snapd, ... } @ inputs: {
  outputs = {
    nixpkgs,
    nixos-hardware,
    home-manager,
    nix-snapd,
    stylix,
    ...
  } @ inputs: let
    system = "x86_64-linux";
  in {
    formatter.${system} = nixpkgs.legacyPackages.${system}.alejandra;
    # Please replace my-nixos with your hostname
    nixosConfigurations = {
      andromeda = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = inputs;
        modules = [
          nixos-hardware.nixosModules.lenovo-thinkpad-p14s-amd-gen2

          home-manager.nixosModules.home-manager
          {
            nixpkgs.overlays = [
              inputs.wired.overlays.default
            ];
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              sharedModules = [
                inputs.wired.homeManagerModules.default
              ];
              users.pallon = import ./home/work.nix;
              # hyprland.homeManagerModules.default
              # imports = [
              #   ./modules/hyprland
              # ];
              # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
            };
          }

          {
            nix.settings.trusted-users = ["pallon"];
            programs.hyprland = {
              enable = true;
              xwayland.enable = true;
              withUWSM = true;
              # package = inputs.hyprland.packages.${system}.hyprland;
              # portalPackage = inputs.hyprland.packages.${system}.xdg-desktop-portal-hyprland;
            };
          }

          nix-snapd.nixosModules.default
          {
            services.snap.enable = true;
          }

          stylix.nixosModules.stylix

          ./hosts/andromeda
          # ./modules/hyprland
        ];
      };

      # mars = nixpkgs.lib.nixosSystem {
      #   system = "x86_64-linux";
      #   specialArgs = inputs;
      #   modules = [
      #     nixos-hardware.nixosModules.lenovo-thinkpad-t480s

      #     ./hosts/mars
      #     {nix.settings.trusted-users = ["jelias"];}

      #     home-manager.nixosModules.home-manager
      #     {
      #       home-manager = {
      #         useGlobalPkgs = true;
      #         useUserPackages = true;
      #         users.jelias = import ./home/home.nix;
      #         # Optionally, use home-manager.extraSpecialArgs to pass arguments to home.nix
      #       };
      #     }
      #   ];
      # };

      # earth = nixpkgs.lib.nixosSystem {
      #   system = "x86_64-linux";
      #   specialArgs = inputs;
      #   modules = [
      #     ./configuration.nix

      #     home-manager.nixosModules.home-manager
      #     {
      #       home-manager = {
      #         useGlobalPkgs = true;
      #         useUserPackages = true;
      #         users.jelias = import ./home/home.nix;
      #       };
      #     }
      #   ];
      # };
    };
  };
}
