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
  fontCfg = osConfig.my.nixos.features.fonts;

  enabled = path: lib.attrByPath path false config;
  defaultPalette = palettes.${cfg.defaultMode};
  i3statusThemePath = "${config.xdg.configHome}/my/theme/current/i3status-rust.toml";

  styleSwitch = pkgs.writeShellApplication {
    name = "my-style-switch";
    runtimeInputs = with pkgs; [
      alacritty
      coreutils
      dunst
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
      switch_link "$theme_dir/dunst/$mode.conf" "$current_dir/dunst.conf"
      switch_link "$theme_dir/rofi/$mode.rasi" "$current_dir/rofi.rasi"
      switch_link "$theme_dir/waybar/$mode.css" "$current_dir/waybar.css"

      printf '%s\n' "$mode" > "$state_dir/mode"

      alacritty msg config -w -1 "general.import=['$current_dir/alacritty.toml']" || true
      i3-msg reload || true
      pkill -u "$USER" -SIGUSR2 i3status-rs || true
      hyprctl reload || true
      dunstctl reload "$current_dir/dunst.conf" || true
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
      dunst.enable = lib.mkOption {
        type = lib.types.bool;
        default = enabled ["my" "hm" "features" "dunst" "enable"];
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
      rofi.enable = lib.mkOption {
        type = lib.types.bool;
        default = enabled ["my" "hm" "features" "rofi" "enable"];
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

      gtk = {
        enable = true;
        gtk2.force = true;
      };

      # Disable Stylix for tools whose themes are managed by our own template functions.
      stylix.targets = {
        alacritty.enable = false;
        kitty.enable     = false;
        gtk.enable       = true;
        rofi.enable      = false;
        i3.enable        = false;
        hyprland.enable  = false;
        waybar.enable    = false;
        yazi.enable      = false;
        dunst.enable     = false;
        nvf.enable       = false;
        qt.enable        = false;
      };

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

      xdg.configFile."gtk-3.0/settings.ini".force = true;

      home.activation.styleCurrentLinks =
        lib.hm.dag.entryAfter ["writeBoundary"] ''
          PATH="${pkgs.coreutils}/bin:$PATH"
          state_file="${config.xdg.stateHome}/my-theme/mode"
          mode="$(cat "$state_file" 2>/dev/null || echo ${lib.escapeShellArg cfg.defaultMode})"
          case "$mode" in light|dark) ;; *) mode=${lib.escapeShellArg cfg.defaultMode} ;; esac

          cur="${config.xdg.configHome}/my/theme"
          mkdir -p "$cur/current"

          switch_link() {
            local target="$1" link="$2" tmp="$2.$$"
            ln -sfT "$target" "$tmp"
            mv -Tf "$tmp" "$link"
          }

          ${lib.optionalString cfg.adapters.alacritty.enable ''
            switch_link "$cur/alacritty/enfocado_$mode.toml" "$cur/current/alacritty.toml"
          ''}
          ${lib.optionalString cfg.adapters.i3status.enable ''
            switch_link "$cur/i3status-rust/enfocado_$mode.toml" "$cur/current/i3status-rust.toml"
          ''}
          ${lib.optionalString cfg.adapters.hyprland.enable ''
            switch_link "$cur/hyprland/$mode.conf" "$cur/current/hyprland.conf"
          ''}
          ${lib.optionalString cfg.adapters.waybar.enable ''
            switch_link "$cur/waybar/$mode.css" "$cur/current/waybar.css"
          ''}
          ${lib.optionalString cfg.adapters.dunst.enable ''
            switch_link "$cur/dunst/$mode.conf" "$cur/current/dunst.conf"
          ''}
          ${lib.optionalString cfg.adapters.rofi.enable ''
            switch_link "$cur/rofi/$mode.rasi" "$cur/current/rofi.rasi"
          ''}
          ${lib.optionalString cfg.adapters.i3.enable ''
            switch_link "$cur/i3/$mode.conf" "$cur/current/i3.conf"
          ''}
        '';
    }

    (lib.mkIf cfg.adapters.alacritty.enable {
      xdg.configFile."my/theme/alacritty/enfocado_light.toml".text = style.mkAlacrittyTheme palettes.light;
      xdg.configFile."my/theme/alacritty/enfocado_dark.toml".text = style.mkAlacrittyTheme palettes.dark;
    })

    (lib.mkIf cfg.adapters.i3status.enable {
      my.hm.features.i3.statusBar.theme = lib.mkDefault i3statusThemePath;

      xdg.configFile."my/theme/i3status-rust/enfocado_light.toml".text = style.mkI3StatusTheme palettes.light;
      xdg.configFile."my/theme/i3status-rust/enfocado_dark.toml".text = style.mkI3StatusTheme palettes.dark;
    })

    (lib.mkIf cfg.adapters.hyprland.enable {
      xdg.configFile."my/theme/hyprland/light.conf".text = style.mkHyprlandTheme palettes.light;
      xdg.configFile."my/theme/hyprland/dark.conf".text = style.mkHyprlandTheme palettes.dark;
    })

    (lib.mkIf cfg.adapters.waybar.enable {
      xdg.configFile."my/theme/waybar/light.css".text = style.mkWaybarCss palettes.light fontCfg.families.monospace.name;
      xdg.configFile."my/theme/waybar/dark.css".text = style.mkWaybarCss palettes.dark fontCfg.families.monospace.name;
    })

    (lib.mkIf cfg.adapters.dunst.enable {
      xdg.configFile."my/theme/dunst/light.conf".text = style.mkDunstConfig palettes.light fontCfg;
      xdg.configFile."my/theme/dunst/dark.conf".text = style.mkDunstConfig palettes.dark fontCfg;
    })

    (lib.mkIf cfg.adapters.kitty.enable {
      xdg.configFile."kitty/light-theme.auto.conf".text = style.mkKittyTheme palettes.light;
      xdg.configFile."kitty/dark-theme.auto.conf".text = style.mkKittyTheme palettes.dark;
      xdg.configFile."kitty/no-preference-theme.auto.conf".text = style.mkKittyTheme defaultPalette;
    })

    (lib.mkIf cfg.adapters.rofi.enable {
      xdg.configFile."my/theme/rofi/light.rasi".text = style.mkRofiTheme palettes.light;
      xdg.configFile."my/theme/rofi/dark.rasi".text = style.mkRofiTheme palettes.dark;
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
