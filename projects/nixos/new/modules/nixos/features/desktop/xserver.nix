{
  config,
  lib,
  ...
}: let
  cfg = config.my.nixos.features.desktop.xserver;
in {
  options.my.nixos.features.desktop.xserver = {
    enable = lib.mkEnableOption "X server";
    dpi = lib.mkOption {
      type = lib.types.int;
      default = 96;
    };
    videoDrivers = lib.mkOption {
      type = with lib.types; listOf str;
      default = ["modesetting"];
    };
    xkb = {
      layout = lib.mkOption {
        type = lib.types.str;
        default = "us";
      };
      variant = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
      options = lib.mkOption {
        type = lib.types.str;
        default = "";
      };
    };
    xrandrHeads = lib.mkOption {
      type = with lib.types;
        listOf (submodule {
          options = {
            output = lib.mkOption {type = str;};
            primary = lib.mkOption {
              type = bool;
              default = false;
            };
          };
        });
      default = [];
    };
  };

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      dpi = cfg.dpi;
      videoDrivers = cfg.videoDrivers;
      xkb = {
        layout = cfg.xkb.layout;
        variant = cfg.xkb.variant;
        options = cfg.xkb.options;
      };
      xrandrHeads = cfg.xrandrHeads;
      desktopManager.xterm.enable = false;
    };
  };
}
