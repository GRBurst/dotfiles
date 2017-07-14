with (import <nixpkgs> {});

let

  nixpkgs = import <nixpkgs/nixos> {};
  localpkgs = import ~/projects/nixpkgs/default.nix {};

in {

  allowUnfree = true;

  packageOverrides = pkgs: with pkgs; {

    user-packages = buildEnv {

      inherit (nixpkgs.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "user-packages";

      paths = [
        clamav
        profile-sync-daemon
        thunderbird
        # firefox
        localpkgs.xcwd
        xorg.xev
      ];

    };

    dev-packages = buildEnv {

      inherit (nixpkgs.config.system.path) pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "dev-packages";

      paths = [
        irssi
      ];

    };

  };

  firefox = {
    enableGoogleTalkPlugin  = false;
    enableAdobeFlash        = false;
    enableAdobeFlashDRM     = true;
    jre                     = false;
    icedtea                 = true;
  };

}
