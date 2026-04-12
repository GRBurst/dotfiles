{
  imports = [
    ./core/audio.nix
    ./core/input.nix
    ./core/laptop.nix
    ./core/networking.nix
    ./core/nixpkgs.nix
    ./core/packages.nix
    ./core/system.nix
    ./core/user.nix
    ./features/ai.nix
    ./features/desktop/addons.nix
    ./features/desktop/hyprland.nix
    ./features/desktop/i3.nix
    ./features/fonts.nix
    ./features/security.nix
    ./features/stylix.nix
    ./features/virtualisation.nix
    # ./features/wired.nix
    ./services/maintenance.nix
    ./services/printing.nix
    ./services/ssh.nix
    ./services/syncthing.nix
  ];
}
