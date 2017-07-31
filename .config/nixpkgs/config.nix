with (import <nixpkgs> {});
with import <nixpkgs/lib>;

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

        btrfs-progs
        # clamav
        exfat
        file
        filezilla
        gnome3.gedit
        gnome3.file-roller
        gptfdisk
        imagemagick7
        jmtpfs
        libnotify
        pidgin
        p7zip
        purple-facebook telegram-purple toxprpl
        pidginotr pidgin-skypeweb pidgin-opensteamworks
        # firefox
          # profile-sync-daemon
        simple-scan
        spaceFM	shared_mime_info desktop_file_utils
        speedtest-cli
        unzip
        usbutils
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
        swiProlog
      ];

    };

    highres-packages = buildEnv {

      inherit (nixpkgs.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "highres-packages";

      paths = [
        common-packages
        dev-packages
        clementine
        evince
        localpkgs.jbidwatcher
        shotwell
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
