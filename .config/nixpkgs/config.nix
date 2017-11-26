with (import <nixpkgs> {});
with import <nixpkgs/lib>;

let
  localpkgs = import ~/projects/nixpkgs/default.nix {};
  nixpkgs   = import <nixpkgs/nixos> {};

in {

  allowUnfree = true;

  # Install local packages with localpkgs.X,
  # e.g.: localpkgs.xcwd

  # Install a package collection with:
  # nix-env -iA common-packages -f "<nixpkgs>"
  # Uninstall all packages with
  # nix-env -e common-packages
  packageOverrides = pkgs: rec {

    # inherit pkgs;

    pidgin-with-plugins = pkgs.pidgin-with-plugins.override {
      plugins = [ pidginotr purple-facebook telegram-purple toxprpl pidginotr pidgin-skypeweb pidgin-opensteamworks localpkgs.purple-gnome-keyring ];
    };

    common-packages = buildEnv {

      name = "common-packages";

      paths = [

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
        keepass
        libnotify
        lsof
        nload
        pavucontrol
        pidgin-with-plugins
        p7zip
        qtox
        # firefox
        # profile-sync-daemon
        simple-scan
        spaceFM	shared_mime_info desktop_file_utils
        speedtest-cli
        traceroute
        unzip
        usbutils
        xcwd
        xorg.xev
        zathura
      ];

    };

    dev-packages = buildEnv {

      inherit (nixpkgs.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "dev-packages";

      paths = [
        cmakeCurses
        irssi irssi_otr
        swiProlog
      ];

    };

    scala-packages = buildEnv {

      inherit (nixpkgs.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "scala-packages";

      paths = [
        sbt
        scala
      ];

    };

    highres-packages = buildEnv {

      inherit (nixpkgs.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "highres-packages";

      paths = [
        common-packages
        chromium
        clementine
        cryptsetup
        evince
        jbidwatcher
        josm
        kodi
        libreoffice-fresh
        qutebrowser
        shotwell
        texmaker
        tor-browser-bundle-bin
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

    test-packages = buildEnv {

      inherit (nixpkgs.config.system.path) pathsToLink ignoreCollisions postBuild;
      name = "test-packages";

      paths = [
        # localpkgs.jbidwatcher
        # localpkgs.iri
        # localpkgs.purple-gnome-keyring
      ];

    };

    services.psd = {
      enable  = true;
      users   = [ "jelias" ];
    };

    firefox = {
      enableGoogleTalkPlugin  = false;
      enableAdobeFlash        = false;
      enableAdobeFlashDRM     = true;
      icedtea                 = true;
    };

   chromium = {
     enablePepperPDF = true;
     enableWideVine = false;
   };

  };

}
