{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.hm.bundles.media;
in {
  options.my.hm.bundles.media.enable = lib.mkEnableOption "Media & Office Bundle";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      vlc
      mpv
      spotify
      libreoffice-still
      zathura
      gimp
      inkscape
      # librewolf + chromium currently uncached on nixpkgs-unstable; overrides additionally
      # produce a unique drv hash. Keep disabled until a personal cache warms them.
      # (librewolf.override {wmClass = "browser";})
      # (chromium.override {enableWideVine = false;})
      # librewolf-bin
      chromium
      brave
      signal-desktop
      discord
      telegram-desktop
      thunderbird-bin

      audacity
      brasero
      clementine
      evince
      simple-scan
      xournalpp
      peek
      shotwell
      zoom-us
      teams-for-linux

      # AI Tools
      aider-chat
      yek
      lutris
      umu-launcher
    ];
  };
}
