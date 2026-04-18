{ config, lib, ... }:
let cfg = config.my.hm.features.zsh;
in {
  options.my.hm.features.zsh.enable = lib.mkEnableOption "ZSH & Aliases";

  config = lib.mkIf cfg.enable {
    programs.bash.enable = true; # Bash enabled for safety
    programs.zsh = {
      enable = true;
      enableCompletion = true;
      dotDir = "${config.xdg.configHome}/zsh";
      shellAliases = {
        l = "ls -l";
        k = "kubectl";
        vn = "vim /etc/nixos/configuration.nix";
        urldecode = "python3 -c 'import sys, urllib.parse as ul; print(ul.unquote_plus(sys.stdin.read()))'";
      };
    };
  };
}
