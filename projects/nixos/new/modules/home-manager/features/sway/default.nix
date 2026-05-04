{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.hm.features.sway;
  i3cfg = config.my.hm.features.i3;
  types = lib.types;
  shared = import ../i3/_shared.nix {inherit lib;};

  defaultWorkRestoreCommand = ''swaymsg 'workspace "1: mail"; exec protonmail-bridge; exec thunderbird; workspace "2: browser"; exec librewolf; workspace 7; exec ~/local/bin/kxo; workspace "9: communication"; exec signal-desktop; workspace 3; exec alacritty' '';

  # Replace the X11 Screen mode with a Wayland-native equivalent.
  swayModes =
    map (m:
      if lib.hasPrefix "Screen" m.name
      then shared.swayScreenMode
      else m)
    i3cfg.modes;

  # --------------------------------------------------------------------------
  # Config rendering
  # --------------------------------------------------------------------------

  renderModeBinding = binding: let
    command =
      if binding.command == "__WORK_RESTORE_COMMAND__"
      then ''exec ${cfg.workRestoreCommand}; mode "default"''
      else binding.command;
  in "    bindsym ${binding.key} ${command}";

  renderMode = mode: ''
    mode "${mode.name}" {
    ${lib.concatMapStringsSep "\n" renderModeBinding mode.bindings}
    }
    bindsym ${mode.enterKey} mode "${mode.name}"
  '';

  renderModes = lib.concatMapStringsSep "\n" renderMode cfg.modes;

  # i3 criteria strings are already in [key="value"] form (without brackets).
  # For sway: emit the criteria as-is (works for class/instance), plus an
  # app_id variant derived from the class value for native Wayland apps.
  renderAssignments =
    lib.concatMapStringsSep "\n"
    (a: ''assign [${a.criteria}] ${a.target}'')
    cfg.assignments;

  renderProgramShortcuts = lib.concatMapStringsSep "\n" shared.renderProgramShortcut cfg.programShortcuts;

  renderWorkspaceOutputs = workspaces: outputExpr:
    lib.concatMapStringsSep "\n"
    (ws: ''workspace "${shared.mkWorkspaceNumberArg ws}" output ${outputExpr}'')
    (lib.filter (ws: ws.assignOutput) workspaces);

  renderOutputs =
    lib.concatMapStringsSep "\n" (o: ''
      output ${o.name} {
        ${lib.optionalString (o.resolution != "") "resolution ${o.resolution}"}
        ${lib.optionalString (o.position != "") "position ${o.position}"}
        ${lib.optionalString (o.scale != 1.0) "scale ${toString o.scale}"}
      }
    '')
    cfg.outputs;

  renderSwayFX = lib.optionalString cfg.swayFx.enable ''
    corner_radius ${toString cfg.swayFx.cornerRadius}
    ${lib.optionalString cfg.swayFx.blur.enable "blur enable\nblur_passes ${toString cfg.swayFx.blur.passes}"}
    ${lib.optionalString cfg.swayFx.shadows.enable "shadows enable\nshadow_blur_radius ${toString cfg.swayFx.shadows.blurRadius}"}
  '';

  startupExecs =
    lib.concatMapStringsSep "\n"
    (cmd: "exec ${cmd}")
    (cfg.commonStartupCommands
      ++ cfg.localStartupCommands
      ++ lib.optional cfg.startWaybar
      "waybar -c ${config.xdg.configHome}/waybar/config-sway");

  secondaryWsConfig = lib.optionalString cfg.enableSecondaryWorkspaces ''
    # switch to workspace (secondary)
    ${shared.renderWorkspaceSwitchBindings cfg.workspaces.secondary}

    # move focused container to workspace (secondary)
    ${shared.renderWorkspaceMoveBindings cfg.workspaces.secondary}
  '';

  displayConfig = ''
    # Workspace output assignments
    ${renderWorkspaceOutputs cfg.workspaces.primary "primary"}

    ${lib.optionalString cfg.enableSecondaryWorkspaces ''
      ${renderWorkspaceOutputs cfg.workspaces.secondary "nonprimary primary"}
    ''}
  '';

  swayConfig = ''
    # sway config — managed by NixOS/home-manager

    # Modifier: Super key
    set $mod Mod4
    set $Alt Mod1
    set $AltGr Mod3
    set $Strg Control

    # Neo arrows (Mod3 = AltGr on Neo layout)
    set $MLeft  Mod3+Left
    set $MDown  Mod3+Down
    set $MRight Mod3+Right
    set $MUp    Mod3+Up

    font ${cfg.barFont}

    # Use Mouse+$mod to drag floating windows
    floating_modifier $mod normal

    # Input configuration
    input type:keyboard {
      xkb_layout ${cfg.input.xkbLayout}
      xkb_variant ${cfg.input.xkbVariant}
      xkb_options ${cfg.input.xkbOptions}
    }

    ${lib.optionalString cfg.input.touchpad.enable ''
      input type:touchpad {
        natural_scroll ${
          if cfg.input.touchpad.naturalScroll
          then "enabled"
          else "disabled"
        }
        dwt ${
          if cfg.input.touchpad.dwt
          then "enabled"
          else "disabled"
        }
      }
    ''}

    # Output configuration
    ${renderOutputs}

    ${startupExecs}

    # Focus follows mouse: off
    focus_follows_mouse no

    # Terminal
    bindsym $mod+Return exec ${cfg.terminal}
    bindsym $mod+Shift+Return exec ${cfg.terminal}
    bindsym $mod+$AltGr+Return exec ${cfg.altTerminalCommand}

    # Kill focused window
    bindsym $mod+Shift+q kill

    # Launcher
    bindsym $mod+o exec --no-startup-id rofi -show run
    bindsym $mod+Shift+o exec --no-startup-id rofi -show combi
    bindsym $mod+s exec --no-startup-id rofi -show ssh
    bindsym $mod+Shift+v exec --no-startup-id ~/local/bin/rofi-vpn/rofi-vpn.sh

    # Move focused window
    bindsym $mod+i move left 100 px
    bindsym $mod+a move down 100 px
    bindsym $mod+e move right 100 px
    bindsym $mod+l move up 100 px

    # Change focus (NEO: n=left r=down g=up t=right)
    bindsym $mod+n focus left
    bindsym $mod+r focus down
    bindsym $mod+g focus up
    bindsym $mod+t focus right

    # Split
    bindsym $mod+h split h
    bindsym $mod+v split v

    # Fullscreen
    bindsym $mod+f fullscreen toggle

    # Layout modes
    bindsym $mod+Shift+s layout stacking
    bindsym $mod+Shift+t layout tabbed
    bindsym $mod+Shift+h layout toggle split

    # Tiling / floating toggle
    bindsym $mod+Shift+space floating toggle
    bindsym $mod+space focus mode_toggle

    # Focus parent / child
    bindsym $mod+p focus parent
    bindsym $mod+c focus child

    # Default borders
    default_border pixel 1
    default_floating_border pixel 1

    # Scratchpad
    bindsym $mod+Shift+u move scratchpad
    bindsym $mod+u scratchpad show

    # Workspace auto back-and-forth
    workspace_auto_back_and_forth yes

    # Volume (pipewire/wireplumber)
    bindsym XF86AudioLowerVolume exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-
    bindsym XF86AudioRaiseVolume exec wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ 5%+
    bindsym XF86AudioMute exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
    bindsym $mod+m exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle

    # Brightness
    bindsym XF86MonBrightnessUp exec brightnessctl set +1%
    bindsym XF86MonBrightnessDown exec brightnessctl set 1%-

    # Screenshot (Wayland)
    bindsym --release Print exec grimblast copysave area

    # Program shortcuts
    ${renderProgramShortcuts}

    # Window assignments
    ${renderAssignments}

    # switch to workspace
    ${shared.renderWorkspaceSwitchBindings cfg.workspaces.primary}

    # move focused container to workspace
    ${shared.renderWorkspaceMoveBindings cfg.workspaces.primary}

    # Modes
    ${renderModes}

    ${secondaryWsConfig}
    ${displayConfig}

    # SwayFX extras
    ${renderSwayFX}

    ${cfg.extraConfig}
  '';
in {
  options.my.hm.features.sway = {
    enable = lib.mkEnableOption "Sway/SwayFX window manager configuration";

    # -- Shared options (default = i3 configured values) --------------------

    workspaces = {
      primary = lib.mkOption {
        type = types.listOf shared.workspaceSubmodule;
        default = i3cfg.workspaces.primary;
        description = "Primary workspace bindings and output assignments.";
      };
      secondary = lib.mkOption {
        type = types.listOf shared.workspaceSubmodule;
        default = i3cfg.workspaces.secondary;
        description = "Secondary workspace bindings and output assignments.";
      };
    };

    enableSecondaryWorkspaces = lib.mkOption {
      type = types.bool;
      default = i3cfg.enableSecondaryWorkspaces;
      description = "Generate F-key bindings for workspaces 11-19 on secondary output.";
    };

    programShortcuts = lib.mkOption {
      type = types.listOf shared.programShortcutSubmodule;
      default = i3cfg.programShortcuts;
      description = "Program launch keybindings.";
    };

    assignments = lib.mkOption {
      type = types.listOf shared.assignmentSubmodule;
      default = i3cfg.assignments;
      description = "Window assignment rules.";
    };

    modes = lib.mkOption {
      type = types.listOf shared.modeSubmodule;
      default = swayModes;
      description = "Named sway modes (Screen mode auto-replaced with Wayland variant).";
    };

    terminal = lib.mkOption {
      type = types.str;
      default = i3cfg.terminal;
      description = "Terminal emulator command.";
    };

    altTerminalCommand = lib.mkOption {
      type = types.str;
      default = i3cfg.altTerminalCommand;
      description = "Command launched by $mod+$AltGr+Return.";
    };

    workRestoreCommand = lib.mkOption {
      type = types.str;
      default = defaultWorkRestoreCommand;
      description = "Command launched by the work restore mode binding.";
    };

    barFont = lib.mkOption {
      type = types.str;
      default = i3cfg.barFont;
      description = "Font declaration used in sway config.";
    };

    extraPackages = lib.mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional packages installed with the sway HM feature.";
    };

    extraConfig = lib.mkOption {
      type = types.lines;
      default = "";
      description = "Additional sway config lines appended verbatim.";
    };

    # -- Startup commands ---------------------------------------------------

    startWaybar = lib.mkOption {
      type = types.bool;
      default =
        config.my.hm.features.waybar.enable
        && builtins.elem "sway" config.my.hm.features.waybar.windowManagers;
      description = "Launch waybar with sway-specific config on startup.";
    };

    commonStartupCommands = lib.mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Shared startup commands (exec).";
    };

    localStartupCommands = lib.mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Host-specific startup commands.";
    };

    # -- Sway-specific options ----------------------------------------------

    outputs = lib.mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = lib.mkOption {
            type = types.str;
            description = "Output name (e.g. eDP-1, DP-2).";
          };
          resolution = lib.mkOption {
            type = types.str;
            default = "";
            description = "Resolution string (e.g. 1920x1080). Empty = use preferred.";
          };
          position = lib.mkOption {
            type = types.str;
            default = "";
            description = "Position string (e.g. 0 0). Empty = auto.";
          };
          scale = lib.mkOption {
            type = types.float;
            default = 1.0;
            description = "Output scale factor.";
          };
        };
      });
      default = [];
      description = "Sway output (monitor) configurations.";
    };

    input = {
      xkbLayout = lib.mkOption {
        type = types.str;
        default = "de,de";
        description = "XKB layout string.";
      };
      xkbVariant = lib.mkOption {
        type = types.str;
        default = "neo,basic";
        description = "XKB variant string.";
      };
      xkbOptions = lib.mkOption {
        type = types.str;
        default = "grp:menu_toggle";
        description = "XKB options string.";
      };
      touchpad = {
        enable = lib.mkOption {
          type = types.bool;
          default = false;
          description = "Configure touchpad input block.";
        };
        naturalScroll = lib.mkOption {
          type = types.bool;
          default = false;
          description = "Enable natural scroll on touchpad.";
        };
        dwt = lib.mkOption {
          type = types.bool;
          default = true;
          description = "Disable while typing.";
        };
      };
    };

    # -- SwayFX visual extras ----------------------------------------------

    swayFx = {
      enable = lib.mkOption {
        type = types.bool;
        default = true;
        description = "Enable SwayFX-specific config directives. Disable when using vanilla sway.";
      };
      cornerRadius = lib.mkOption {
        type = types.int;
        default = 8;
        description = "Window corner radius in pixels.";
      };
      blur = {
        enable = lib.mkOption {
          type = types.bool;
          default = true;
          description = "Enable background blur.";
        };
        passes = lib.mkOption {
          type = types.int;
          default = 2;
          description = "Number of blur passes.";
        };
      };
      shadows = {
        enable = lib.mkOption {
          type = types.bool;
          default = true;
          description = "Enable window drop shadows.";
        };
        blurRadius = lib.mkOption {
          type = types.int;
          default = 20;
          description = "Shadow blur radius.";
        };
      };
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      swaylock
      swayidle
      wl-clipboard
      grim
      slurp
      grimblast
    ] ++ cfg.extraPackages;

    xdg.configFile."sway/config".text = swayConfig;
  };
}
