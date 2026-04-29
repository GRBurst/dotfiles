{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}: let
  cfg = config.my.hm.features.style;
  style = import ../../../lib/style {inherit lib;};
  palettes = style.palettes.${cfg.palette};
  fontCfg = osConfig.my.nixos.features.fonts.families;

  enabled = path: lib.attrByPath path false config;
  defaultPalette = palettes.${cfg.defaultMode};
  i3statusThemePath = "${config.xdg.configHome}/my/theme/current/i3status-rust.toml";

  styleSwitch = pkgs.writeShellApplication {
    name = "my-style-switch";
    runtimeInputs = with pkgs; [
      alacritty
      coreutils
      glib
      hyprland
      i3
      procps
    ];
    text = ''
      set -eu

      mode="''${1:-}"
      case "$mode" in
        light|dark) ;;
        *)
          echo "usage: my-style-switch light|dark" >&2
          exit 64
          ;;
      esac

      config_home="''${XDG_CONFIG_HOME:-$HOME/.config}"
      state_home="''${XDG_STATE_HOME:-$HOME/.local/state}"
      theme_dir="$config_home/my/theme"
      current_dir="$theme_dir/current"
      state_dir="$state_home/my-theme"

      mkdir -p "$current_dir" "$state_dir"

      switch_link() {
        target="$1"
        link="$2"
        tmp="$link.$$"
        rm -f "$tmp"
        ln -s "$target" "$tmp"
        mv -Tf "$tmp" "$link"
      }

      switch_link "$theme_dir/alacritty/enfocado_$mode.toml" "$current_dir/alacritty.toml"
      switch_link "$theme_dir/i3/$mode.conf" "$current_dir/i3.conf"
      switch_link "$theme_dir/i3status-rust/enfocado_$mode.toml" "$current_dir/i3status-rust.toml"
      switch_link "$theme_dir/hyprland/$mode.conf" "$current_dir/hyprland.conf"
      switch_link "$theme_dir/waybar/$mode.css" "$current_dir/waybar.css"

      printf '%s\n' "$mode" > "$state_dir/mode"

      alacritty msg config -w -1 "general.import=['$current_dir/alacritty.toml']" || true
      i3-msg reload || true
      hyprctl reload || true
      pkill -u "$USER" -SIGUSR2 waybar || true
      pkill -u "$USER" -USR1 nvim || true

      if [ "$mode" = dark ]; then
        gsettings set org.gnome.desktop.interface color-scheme prefer-dark || true
      else
        gsettings set org.gnome.desktop.interface color-scheme prefer-light || true
      fi
    '';
  };
in {
  options.my.hm.features.style = {
    enable = lib.mkEnableOption "dynamic user style";

    palette = lib.mkOption {
      type = lib.types.enum ["enfocado"];
      default = "enfocado";
      description = "Canonical palette family.";
    };

    defaultMode = lib.mkOption {
      type = lib.types.enum ["light" "dark"];
      default = "light";
      description = "Initial mode used for declarative fallback artifacts.";
    };

    darkman.enable = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Enable darkman as the light/dark mode source.";
    };

    dispatcher.package = lib.mkOption {
      type = lib.types.package;
      readOnly = true;
      default = styleSwitch;
      description = "Runtime style switching command used by darkman.";
    };

    adapters = {
      alacritty.enable = lib.mkOption {
        type = lib.types.bool;
        default = enabled ["my" "hm" "features" "alacritty" "enable"];
      };
      i3.enable = lib.mkOption {
        type = lib.types.bool;
        default = enabled ["my" "hm" "features" "i3" "enable"];
      };
      i3status.enable = lib.mkOption {
        type = lib.types.bool;
        default = enabled ["my" "hm" "features" "i3" "enable"];
      };
      hyprland.enable = lib.mkOption {
        type = lib.types.bool;
        default = enabled ["my" "hm" "features" "hyprland" "enable"];
      };
      waybar.enable = lib.mkOption {
        type = lib.types.bool;
        default = enabled ["my" "hm" "features" "waybar" "enable"];
      };
      nvf.enable = lib.mkOption {
        type = lib.types.bool;
        default = enabled ["my" "hm" "features" "nvf" "enable"];
      };
      kitty.enable = lib.mkOption {
        type = lib.types.bool;
        default = enabled ["my" "hm" "features" "kitty" "enable"];
      };
      yazi.enable = lib.mkOption {
        type = lib.types.bool;
        default = enabled ["my" "hm" "features" "yazi" "enable"];
      };
      ghostty.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      vscode.enable = lib.mkOption {
        type = lib.types.bool;
        default = false;
      };
      gnome.enable = lib.mkOption {
        type = lib.types.bool;
        default = enabled ["my" "hm" "features" "gnome" "enable"];
      };
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [styleSwitch];

      services.darkman = lib.mkIf cfg.darkman.enable {
        enable = true;
        settings = {
          portal = true;
          dbusserver = true;
          usegeoclue = false;
          lat = osConfig.location.latitude;
          lng = osConfig.location.longitude;
        };
        scripts."theme-dispatch" = ''
          exec ${styleSwitch}/bin/my-style-switch "$@"
        '';
      };

      xdg.portal = {
        enable = true;
        config.common."org.freedesktop.impl.portal.Settings" = "darkman";
      };
    }

    (lib.mkIf cfg.adapters.alacritty.enable {
      xdg.configFile."my/theme/alacritty/enfocado_light.toml".text = style.mkAlacrittyTheme palettes.light;
      xdg.configFile."my/theme/alacritty/enfocado_dark.toml".text = style.mkAlacrittyTheme palettes.dark;
      xdg.configFile."my/theme/current/alacritty.toml".text = style.mkAlacrittyTheme defaultPalette;
    })

    (lib.mkIf cfg.adapters.i3status.enable {
      my.hm.features.i3.statusBar.theme = lib.mkDefault i3statusThemePath;

      xdg.configFile."my/theme/i3status-rust/enfocado_light.toml".text = style.mkI3StatusTheme palettes.light;
      xdg.configFile."my/theme/i3status-rust/enfocado_dark.toml".text = style.mkI3StatusTheme palettes.dark;
      xdg.configFile."my/theme/current/i3status-rust.toml".text = style.mkI3StatusTheme defaultPalette;
    })

    (lib.mkIf cfg.adapters.hyprland.enable {
      xdg.configFile."my/theme/hyprland/light.conf".text = style.mkHyprlandTheme palettes.light;
      xdg.configFile."my/theme/hyprland/dark.conf".text = style.mkHyprlandTheme palettes.dark;
      xdg.configFile."my/theme/current/hyprland.conf".text = style.mkHyprlandTheme defaultPalette;
    })

    (lib.mkIf cfg.adapters.waybar.enable {
      xdg.configFile."my/theme/waybar/light.css".text = style.mkWaybarCss palettes.light fontCfg.monospace.name;
      xdg.configFile."my/theme/waybar/dark.css".text = style.mkWaybarCss palettes.dark fontCfg.monospace.name;
      xdg.configFile."my/theme/current/waybar.css".text = style.mkWaybarCss defaultPalette fontCfg.monospace.name;
    })

    (lib.mkIf cfg.adapters.kitty.enable {
      xdg.configFile."kitty/light-theme.auto.conf".text = style.mkKittyTheme palettes.light;
      xdg.configFile."kitty/dark-theme.auto.conf".text = style.mkKittyTheme palettes.dark;
      xdg.configFile."kitty/no-preference-theme.auto.conf".text = style.mkKittyTheme defaultPalette;
    })

    (lib.mkIf cfg.adapters.yazi.enable {
      programs.yazi.theme.flavor = {
        dark = "enfocado-dark";
        light = "enfocado-light";
      };

      programs.yazi.flavors = {
        enfocado-light = pkgs.writeTextDir "flavor.toml" (style.mkYaziFlavor palettes.light);
        enfocado-dark = pkgs.writeTextDir "flavor.toml" (style.mkYaziFlavor palettes.dark);
      };
    })
  ]);
}
