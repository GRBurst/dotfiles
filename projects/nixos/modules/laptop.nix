{ config, pkgs, username, hostname, ... }:

{
  imports = [ # Include the results of the hardware scan.
    ./base.nix
    ../pkgs/laptop.nix
  ];
}
