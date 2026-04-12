{ config, lib, pkgs, ... }:
let cfg = config.my.nixos.core.user;
in {
  options.my.nixos.core.user.enable = lib.mkEnableOption "Pallon User";

  config = lib.mkIf cfg.enable {
    users.users.pallon = {
      isNormalUser = true;
      extraGroups = [ "wheel" "video" "audio" "vboxusers" "docker" "fuse" "adbusers" "networkmanager" ];
      shell = pkgs.zsh;
      openssh.authorizedKeys.keys = [
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDeEb4AnnxoSa1OJS1Byr6GvxeTiino4nLgxhEi3nb3k jelias@mars->earth on 2024-09-03"
        "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAINeE9P89x92Ru53ts6tn0WYo+RuB/vwJl02b3++91Wqg localphone"
      ];
    };
    programs.zsh.enable = true;
    nix.settings.trusted-users = [ "pallon" ];
  };
}
