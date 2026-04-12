{ config, lib, pkgs, ... }:
let cfg = config.my.hm.features.misc;
in {
  options.my.hm.features.misc.enable = lib.mkEnableOption "Misc User Configs";

  config = lib.mkIf cfg.enable {
    xresources.properties = {
      "Xft.dpi" = 192;
    };

    xdg = {
      enable = true;
      mime.enable = true;
      portal = {
        enable = true;
        config.common.default = "*";
        extraPortals = with pkgs; [
          xdg-desktop-portal-gtk
        ];
      };
    };

    programs.bash.bashrcExtra = ''
      export PATH="$PATH:$HOME/bin:$HOME/.local/bin:$HOME/local/bin"
    '';
  };
}
