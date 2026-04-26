{
  config,
  lib,
  ...
}: let
  cfg = config.my.nixos.features.desktop;
  primary = config.my.nixos.core.user.primary;
in {
  options.my.nixos.features.desktop = {
    displayManager = lib.mkOption {
      type = lib.types.enum ["none" "sddm" "lightdm" "gdm"];
      default = "none";
      description = "Which display manager to enable. Enum is exclusive by construction.";
    };
    autoLogin = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Auto-login the primary user at the display manager.";
    };
    defaultSession = lib.mkOption {
      type = with lib.types; nullOr str;
      default = null;
      description = "Default session string (e.g. \"none+i3\"). Null leaves the DM's default.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.displayManager == "sddm") {
      services.displayManager.sddm = {
        enable = true;
        wayland.enable = true;
      };
    })
    (lib.mkIf (cfg.displayManager == "lightdm") {
      services.xserver.displayManager.lightdm.enable = true;
    })
    (lib.mkIf (cfg.displayManager == "gdm") {
      services.displayManager.gdm.enable = true;
    })
    (lib.mkIf (cfg.displayManager != "none") {
      assertions = [
        {
          assertion = !cfg.autoLogin || primary != null;
          message = "my.nixos.features.desktop.autoLogin requires a primary user.";
        }
      ];
      services.displayManager = {
        defaultSession = lib.mkIf (cfg.defaultSession != null) cfg.defaultSession;
        autoLogin = lib.mkIf cfg.autoLogin {
          enable = true;
          user = primary;
        };
      };
    })
  ];
}
