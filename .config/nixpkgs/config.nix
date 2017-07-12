# {
#   allowUnfree = true;

#   packageOverrides = pkgs: rec {
#     home-manager = import ./home-manager { inherit pkgs; };
#   };
#   # packageOverrides = pkgs: {
#   #   irsii = pkgs.irsii.override { x = y};
#   # };
# }
# htop
with (import <nixpkgs> {});
{
  allowUnfree = true;
  packageOverrides = pkgs: with pkgs; {
    userPackages = buildEnv {
      inherit ((import <nixpkgs/nixos> {}).config.system.path)
        pathsToLink ignoreCollisions postBuild;
      extraOutputsToInstall = [ "man" ];
      name = "user-packages";
      paths = [
        irssi
      ];
    };
  };
}
