{
  config,
  lib,
  pkgs,
  osConfig,
  ...
}: let
  cfg = config.my.hm.features.style;
  style = import ../../../lib/style {inherit lib;};
  tomlFormat = pkgs.formats.toml {};
  palettes = style.palettes.${cfg.palette};
  fontCfg = osConfig.my.nixos.features.fonts;

  enabled = path: lib.attrByPath path false config;
  defaultPalette = palettes.${cfg.defaultMode};
  i3statusThemePath = "${config.xdg.configHome}/my/theme/current/i3status-rust.toml";
  rawThemeExtensionType = lib.types.submodule {
    options = {
      shared = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Fragment appended to both generated light and dark theme files.";
      };
      light = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Fragment appended only to the generated light theme file.";
      };
      dark = lib.mkOption {
        type = lib.types.lines;
        default = "";
        description = "Fragment appended only to the generated dark theme file.";
      };
    };
  };
  tomlOverrideType = lib.types.submodule {
    options = {
      shared = lib.mkOption {
        type = tomlFormat.type;
        default = {};
        description = "TOML attributes merged into both generated light and dark theme files.";
      };
      light = lib.mkOption {
        type = tomlFormat.type;
        default = {};
        description = "TOML attributes merged only into the generated light theme file.";
      };
      dark = lib.mkOption {
        type = tomlFormat.type;
        default = {};
        description = "TOML attributes merged only into the generated dark theme file.";
      };
    };
  };
  appendModeText = base: ext: mode:
    lib.concatStringsSep "\n" (lib.filter (s: s != "") [
      base
      ext.shared
      ext.${mode}
    ]);
  mergeModeAttrs = base: ext: mode:
    lib.recursiveUpdate base (lib.recursiveUpdate ext.shared ext.${mode});
  toToml = attrs: builtins.readFile (tomlFormat.generate "theme.toml" attrs);

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

      mkdir -p "$current_dir" "$state_dir" "$config_home/wofi"

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
      switch_link "$theme_dir/wofi/$mode.css" "$config_home/wofi/style.css"
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
      alacritty = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = enabled ["my" "hm" "features" "alacritty" "enable"];
        };
        overrides = lib.mkOption {
          type = tomlOverrideType;
          default = {};
          description = "TOML overrides merged into generated Alacritty theme files.";
        };
      };
      i3 = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = enabled ["my" "hm" "features" "i3" "enable"];
        };
        extra = lib.mkOption {
          type = rawThemeExtensionType;
          default = {};
          description = "Raw i3 config fragments appended to generated theme files.";
        };
      };
      i3status = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = enabled ["my" "hm" "features" "i3" "enable"];
        };
        overrides = lib.mkOption {
          type = tomlOverrideType;
          default = {};
          description = "TOML overrides merged into generated i3status-rust theme files.";
        };
      };
      hyprland = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = enabled ["my" "hm" "features" "hyprland" "enable"];
        };
        extra = lib.mkOption {
          type = rawThemeExtensionType;
          default = {};
          description = "Raw Hyprland config fragments appended to generated theme files.";
        };
      };
      dunst = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = enabled ["my" "hm" "features" "dunst" "enable"];
        };
        extra = lib.mkOption {
          type = rawThemeExtensionType;
          default = {};
          description = "Raw Dunst config fragments appended to generated theme files.";
        };
      };
      waybar = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = enabled ["my" "hm" "features" "waybar" "enable"];
        };
        extra = lib.mkOption {
          type = rawThemeExtensionType;
          default = {};
          description = "Raw Waybar CSS fragments appended to generated theme files.";
        };
      };
      nvf = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = enabled ["my" "hm" "features" "nvf" "enable"];
        };
        enfocadoStyle = lib.mkOption {
          type = lib.types.str;
          default = "nature";
          description = "Value assigned to vim.g.enfocado_style in the nvf Lua theme hook.";
        };
      };
      kitty = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = enabled ["my" "hm" "features" "kitty" "enable"];
        };
        extra = lib.mkOption {
          type = rawThemeExtensionType;
          default = {};
          description = "Raw Kitty theme fragments appended to generated auto-theme files.";
        };
      };
      rofi = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = enabled ["my" "hm" "features" "rofi" "enable"];
        };
        extra = lib.mkOption {
          type = rawThemeExtensionType;
          default = {};
          description = "Raw RASI fragments appended to generated rofi theme files.";
        };
      };
      wofi = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = enabled ["my" "hm" "bundles" "extras" "enable"];
        };
        extra = lib.mkOption {
          type = rawThemeExtensionType;
          default = {};
          description = "Raw CSS fragments appended to generated wofi style files.";
        };
      };
      yazi = {
        enable = lib.mkOption {
          type = lib.types.bool;
          default = enabled ["my" "hm" "features" "yazi" "enable"];
        };
        overrides = lib.mkOption {
          type = tomlOverrideType;
          default = {};
          description = "TOML overrides merged into generated Yazi flavor files.";
        };
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
        kitty.enable = false;
        gtk.enable = true;
        rofi.enable = false;
        i3.enable = false;
        hyprland.enable = false;
        waybar.enable = false;
        yazi.enable = false;
        dunst.enable = false;
        nvf.enable = false;
        qt.enable = false;
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

      home.activation.styleCurrentLinks = lib.hm.dag.entryAfter ["writeBoundary"] ''
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
        ${lib.optionalString cfg.adapters.wofi.enable ''
          mkdir -p "${config.xdg.configHome}/wofi"
          switch_link "$cur/wofi/$mode.css" "${config.xdg.configHome}/wofi/style.css"
        ''}
        ${lib.optionalString cfg.adapters.i3.enable ''
          switch_link "$cur/i3/$mode.conf" "$cur/current/i3.conf"
        ''}
      '';
    }

    (lib.mkIf cfg.adapters.alacritty.enable {
      xdg.configFile."my/theme/alacritty/enfocado_light.toml".text =
        toToml (mergeModeAttrs (style.mkAlacrittyThemeAttrs palettes.light) cfg.adapters.alacritty.overrides "light");
      xdg.configFile."my/theme/alacritty/enfocado_dark.toml".text =
        toToml (mergeModeAttrs (style.mkAlacrittyThemeAttrs palettes.dark) cfg.adapters.alacritty.overrides "dark");
    })

    (lib.mkIf cfg.adapters.i3status.enable {
      my.hm.features.i3.statusBar.theme = lib.mkDefault i3statusThemePath;

      xdg.configFile."my/theme/i3status-rust/enfocado_light.toml".text =
        toToml (mergeModeAttrs (style.mkI3StatusThemeAttrs palettes.light) cfg.adapters.i3status.overrides "light");
      xdg.configFile."my/theme/i3status-rust/enfocado_dark.toml".text =
        toToml (mergeModeAttrs (style.mkI3StatusThemeAttrs palettes.dark) cfg.adapters.i3status.overrides "dark");
    })

    (lib.mkIf cfg.adapters.hyprland.enable {
      xdg.configFile."my/theme/hyprland/light.conf".text =
        appendModeText (style.mkHyprlandTheme palettes.light) cfg.adapters.hyprland.extra "light";
      xdg.configFile."my/theme/hyprland/dark.conf".text =
        appendModeText (style.mkHyprlandTheme palettes.dark) cfg.adapters.hyprland.extra "dark";
    })

    (lib.mkIf cfg.adapters.waybar.enable {
      xdg.configFile."my/theme/waybar/light.css".text =
        appendModeText (style.mkWaybarCss palettes.light fontCfg.families.monospace.name) cfg.adapters.waybar.extra "light";
      xdg.configFile."my/theme/waybar/dark.css".text =
        appendModeText (style.mkWaybarCss palettes.dark fontCfg.families.monospace.name) cfg.adapters.waybar.extra "dark";
    })

    (lib.mkIf cfg.adapters.dunst.enable {
      xdg.configFile."my/theme/dunst/light.conf".text =
        appendModeText (style.mkDunstConfig palettes.light fontCfg) cfg.adapters.dunst.extra "light";
      xdg.configFile."my/theme/dunst/dark.conf".text =
        appendModeText (style.mkDunstConfig palettes.dark fontCfg) cfg.adapters.dunst.extra "dark";
    })

    (lib.mkIf cfg.adapters.kitty.enable {
      xdg.configFile."kitty/light-theme.auto.conf".text =
        appendModeText (style.mkKittyTheme palettes.light) cfg.adapters.kitty.extra "light";
      xdg.configFile."kitty/dark-theme.auto.conf".text =
        appendModeText (style.mkKittyTheme palettes.dark) cfg.adapters.kitty.extra "dark";
      xdg.configFile."kitty/no-preference-theme.auto.conf".text =
        appendModeText (style.mkKittyTheme defaultPalette) cfg.adapters.kitty.extra cfg.defaultMode;
    })

    (lib.mkIf cfg.adapters.rofi.enable {
      xdg.configFile."my/theme/rofi/light.rasi".text =
        appendModeText (style.mkRofiTheme palettes.light) cfg.adapters.rofi.extra "light";
      xdg.configFile."my/theme/rofi/dark.rasi".text =
        appendModeText (style.mkRofiTheme palettes.dark) cfg.adapters.rofi.extra "dark";
    })

    (lib.mkIf cfg.adapters.wofi.enable {
      xdg.configFile."my/theme/wofi/light.css".text =
        appendModeText (style.mkWofiCss palettes.light) cfg.adapters.wofi.extra "light";
      xdg.configFile."my/theme/wofi/dark.css".text =
        appendModeText (style.mkWofiCss palettes.dark) cfg.adapters.wofi.extra "dark";
    })

    (lib.mkIf cfg.adapters.yazi.enable {
      programs.yazi.theme.flavor = {
        dark = "enfocado-dark";
        light = "enfocado-light";
      };

      programs.yazi.flavors = {
        enfocado-light = pkgs.writeTextDir "flavor.toml" (
          toToml (mergeModeAttrs (style.mkYaziFlavorAttrs palettes.light) cfg.adapters.yazi.overrides "light")
        );
        enfocado-dark = pkgs.writeTextDir "flavor.toml" (
          toToml (mergeModeAttrs (style.mkYaziFlavorAttrs palettes.dark) cfg.adapters.yazi.overrides "dark")
        );
      };
    })
  ]);
}
