{
  config,
  lib,
  ...
}: let
  cfg = config.my.nixos.features.desktop;
  c = cfg.compositor;
in {
  options.my.nixos.features.desktop.compositor = lib.mkOption {
    type = lib.types.enum ["none" "compton" "picom"];
    default = "none";
    description = "Which X compositor to run. Enum is exclusive by construction.";
  };

  config = lib.mkMerge [
    (lib.mkIf (c == "compton") {services.picom.enable = true;})
    (lib.mkIf (c == "picom") {services.picom.enable = true;})
    (lib.mkIf (c != "none") {
      assertions = [
        {
          assertion = cfg.xserver.enable;
          message = "my.nixos.features.desktop.compositor = \"${c}\" requires xserver.enable = true.";
        }
      ];
    })
  ];
}
