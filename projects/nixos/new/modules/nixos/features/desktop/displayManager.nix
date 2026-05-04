{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.nixos.features.desktop;
  primary = config.my.nixos.core.user.primary;
in {
  options.my.nixos.features.desktop = {
    displayManager = lib.mkOption {
      type = lib.types.enum ["none" "sddm" "lightdm" "gdm" "greetd"];
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
      description = "Default session string (e.g. \"none+i3\", or for greetd a session command like \"Hyprland\"). Null leaves the DM's default.";
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.displayManager != "none") {
      assertions = [
        {
          assertion = !cfg.autoLogin || primary != null;
          message = "my.nixos.features.desktop.autoLogin requires a primary user.";
        }
        {
          assertion = !(cfg.displayManager == "greetd" && cfg.autoLogin && cfg.defaultSession == null);
          message = "greetd autoLogin requires my.nixos.features.desktop.defaultSession to specify the session command.";
        }
      ];
    })

    (lib.mkIf (cfg.displayManager != "none" && cfg.displayManager != "greetd") {
      services.displayManager = {
        defaultSession = lib.mkIf (cfg.defaultSession != null) cfg.defaultSession;
        autoLogin = lib.mkIf cfg.autoLogin {
          enable = true;
          user = primary;
        };
      };
    })

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
    (lib.mkIf (cfg.displayManager == "greetd") {
      services.greetd = {
        enable = true;
        settings =
          {
            terminal.vt = lib.mkForce 2;
            default_session = {
              command = lib.concatStringsSep " " (
                [
                  "${pkgs.tuigreet}/bin/tuigreet"
                  "--time"
                  "--remember"
                  "--remember-session"
                  "--sessions"
                  "${config.services.displayManager.sessionData.desktops}/share/wayland-sessions"
                  "--xsessions"
                  "${config.services.displayManager.sessionData.desktops}/share/xsessions"
                ]
                ++ lib.optional (cfg.defaultSession != null) "--cmd ${lib.escapeShellArg cfg.defaultSession}"
              );
              user = "greeter";
            };
          }
          // lib.optionalAttrs cfg.autoLogin {
            initial_session = {
              command = cfg.defaultSession;
              user = primary;
            };
          };
      };

      # Provide a valid xserverrc on NixOS so startx can locate the X binary.
      services.xserver.displayManager.startx.enable = true;

      # Append xinit to greetd's hardcoded minimal PATH so tuigreet can invoke startx.
      systemd.services.greetd.path = [pkgs.xinit];
    })
  ];
}
