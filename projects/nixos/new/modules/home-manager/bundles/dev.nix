{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.hm.bundles.dev;
in {
  options.my.hm.bundles.dev.enable = lib.mkEnableOption "Development Bundle";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      git
      lazygit
      neovim
      # gcc
      clang
      gnumake
      cmakeCurses
      nodejs
      docker-compose
      direnv
    ];
  };
}
