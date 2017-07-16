with (import <nixpkgs> {});

let
  localpkgs = import ~/projects/nixpkgs/default.nix {};
  nixpkgs   = import <nixpkgs/nixos> {};

in {

  allowUnfree = true;

  packageOverrides = pkgs: with pkgs; {

    common-packages = buildEnv {

      inherit (nixpkgs.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "common-packages";

      paths = [
        localpkgs.xcwd

        # clamav
        gnome3.file-roller
        libnotify
        pidgin
        purple-facebook telegram-purple toxprpl
        pidginotr pidgin-skypeweb pidgin-opensteamworks
        # firefox
          # profile-sync-daemon
        simple-scan
        spaceFM	shared_mime_info desktop_file_utils
        xorg.xev
        zathura
      ];

    };

    dev-packages = buildEnv {

      inherit (nixpkgs.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "dev-packages";

      paths = [
        irssi irssi_otr
      ];

    };

    highres-packages = buildEnv {

      inherit (nixpkgs.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "highres-packages";

      paths = [
        common-packages
        dev-packages
        evince
        thunderbird
      ];

  };

    lowres-packages = buildEnv {

      inherit (nixpkgs.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "lowres-packages";

      paths = [
        common-packages
        claws-mail
        mutt
        llpp
        ranger
      ];

  };

}
