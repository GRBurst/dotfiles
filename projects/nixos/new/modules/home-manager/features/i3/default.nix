{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.hm.features.i3;
  types = lib.types;
  shared = import ./_shared.nix {inherit lib;};
  primaryOutput = cfg.display.primaryOutput;
  secondaryOutput = cfg.display.secondaryOutput;
  style = import ../../../lib/style {inherit lib;};
  styleCfg = config.my.hm.features.style;
  palettes = style.palettes.${styleCfg.palette};
  dynamicStyleEnabled = styleCfg.enable && styleCfg.adapters.i3.enable;
  defaultPalette = palettes.${styleCfg.defaultMode};

  defaultWorkRestoreCommand = ''i3-msg 'workspace "1: mail"; exec protonmail-bridge; exec thunderbird; workspace "2: browser"; exec librewolf; workspace 7; exec ~/local/bin/kxo; workspace "9: communication"; exec signal-desktop; exec librewolf --new-window --kiosk https://priceloop.slack.com; workspace 3; exec alacritty --working-directory ~/projects/priceloop/ogopogo/nocode' '';

  defaultPrimaryWorkspaces = shared.defaultPrimaryWorkspaces;
  defaultSecondaryWorkspaces = shared.defaultSecondaryWorkspaces;
  defaultProgramShortcuts = shared.defaultProgramShortcuts;
  defaultAssignments = shared.defaultAssignments;
  defaultModes = shared.mkDefaultI3Modes {inherit primaryOutput secondaryOutput;};

  startupExecs =
    lib.concatMapStringsSep "\n"
    (cmd: "exec --no-startup-id ${cmd}")
    (cfg.commonStartupCommands ++ cfg.localStartupCommands);

  mkWorkspaceName = ws:
    if ws.name == null
    then toString ws.number
    else ''"${toString ws.number}: ${ws.name}"'';

  mkWorkspaceNumberArg = ws:
    if ws.name == null
    then toString ws.number
    else "${toString ws.number}: ${ws.name}";

  renderWorkspaceOutputs = workspaces: outputExpr:
    lib.concatMapStringsSep "\n"
    (ws: ''workspace ${mkWorkspaceName ws} output ${outputExpr}'')
    (lib.filter (ws: ws.assignOutput) workspaces);

  renderWorkspaceSwitchBindings = workspaces:
    lib.concatMapStringsSep "\n"
    (ws: ''bindsym $mod+${ws.key} workspace number ${mkWorkspaceNumberArg ws}; [con_mark="awot"] move workspace current;'')
    workspaces;

  renderWorkspaceMoveBindings = workspaces:
    lib.concatMapStringsSep "\n"
    (ws: ''bindsym $mod+Shift+${ws.key} move container to workspace number ${mkWorkspaceNumberArg ws}'')
    workspaces;

  renderProgramShortcut = shortcut: "bindsym ${shortcut.key} exec ${lib.optionalString shortcut.noStartupId "--no-startup-id "}${shortcut.command}";

  renderProgramShortcuts = lib.concatMapStringsSep "\n" renderProgramShortcut cfg.programShortcuts;

  renderAssignments =
    lib.concatMapStringsSep "\n"
    (assignment: ''assign [${assignment.criteria}] ${assignment.target}'')
    cfg.assignments;

  renderModeBinding = binding: let
    command =
      if binding.command == "__WORK_RESTORE_COMMAND__"
      then ''exec --no-startup-id ${cfg.workRestoreCommand}; mode "default"''
      else binding.command;
  in "        bindsym ${binding.key} ${command}";

  renderMode = mode: ''
    mode "${mode.name}" {
    ${lib.concatMapStringsSep "\n" renderModeBinding mode.bindings}
    }
    bindsym ${mode.enterKey} mode "${mode.name}"
  '';

  renderModes = lib.concatMapStringsSep "\n" renderMode cfg.modes;

  renderBarColors = palette: ''
    colors {
        background ${palette.primary.background}
        statusline ${palette.primary.foreground}
        separator ${palette.bright.black}

        focused_workspace  ${palette.normal.blue}  ${palette.normal.blue}  ${palette.primary.background}
        active_workspace   ${palette.bright.black} ${palette.bright.black} ${palette.primary.background}
        inactive_workspace ${palette.primary.background} ${palette.primary.background} ${palette.primary.foreground}
        urgent_workspace   ${palette.normal.red}   ${palette.normal.red}   ${palette.primary.background}
    }
  '';

  renderBar = palette: ''
    bar {
        font ${cfg.barFont}
        output primary
        ${lib.optionalString cfg.enableSecondaryWorkspaces "output nonprimary"}
        status_command ${pkgs.i3status-rust}/bin/i3status-rs $HOME/.config/i3status-rust/config.toml
        strip_workspace_numbers no
        ${renderBarColors palette}
    }
  '';

  displayConfig = ''
    # Workspace output assignments
    ${renderWorkspaceOutputs cfg.workspaces.primary "primary"}

    ${lib.optionalString cfg.enableSecondaryWorkspaces ''
      ${renderWorkspaceOutputs cfg.workspaces.secondary "nonprimary primary"}
    ''}

    ${lib.optionalString (!dynamicStyleEnabled) (renderBar defaultPalette)}
  '';

  secondaryWsConfig = lib.optionalString cfg.enableSecondaryWorkspaces ''

    # switch to workspace (secondary)
    ${renderWorkspaceSwitchBindings cfg.workspaces.secondary}

    # move focused container to workspace (secondary)
    ${renderWorkspaceMoveBindings cfg.workspaces.secondary}
  '';

  i3scriptsContent = ''
    #!/usr/bin/env bash
    declare -r FILE="/tmp/i3scripts.conf"
    init()
    {
        [[ -f "$FILE" ]] && source "$FILE"
        activeWorkspace="$(i3-msg -t get_workspaces | grep -P '"name"[^}]*?("focused"):true' -o | sed 's/"name":"\(.*\)","visible":true,"focused":true/\1/g')"
        ws_number=$(echo $activeWorkspace | cut -d ":" -f1)
    }

    export ()
    {
        if grep -q -s "ws_split\[$ws_number\]" "$FILE"; then
            sed -E -i "s/ws_split\[$ws_number\]=(.*)/ws_split\[$ws_number\]=''${ws_split[$ws_number]}/" "$FILE"
        else
            echo "ws_split[$ws_number]=''${ws_split[$ws_number]}" >> "$FILE"
        fi
    }

    ws_set_split()
    {
        local -r action="$1"
        if [[ "$action" == "h" ]]; then
            ws_split[$ws_number]=h
        elif [[ "$action" == "v" ]]; then
            ws_split[$ws_number]=v
        fi
    }

    ws_split()
    {
        local -r action="$1"
        local folder="$(xcwd)"
        local term="${cfg.terminal} --working-directory \"''${folder:-~/}\""

        if [[ "$action" == "manual" ]]; then
            if [[ -z "''${ws_split[$ws_number]}" ]]; then
                i3-msg "exec $term;"
                ws_split[$ws_number]=h
            else
                i3-msg "split ''${ws_split[$ws_number]}; exec $term;"
            fi
        elif [[ "$action" == "auto" ]]; then
            if [[ -z "''${ws_split[$ws_number]}" ]]; then
                i3-msg "exec $term;"
                ws_split[$ws_number]=h
            elif [[ ''${ws_split[$ws_number]} == "h" ]]; then
                i3-msg "split h; exec $term;"
                ws_split[$ws_number]=v
            elif [[ ''${ws_split[$ws_number]} == "v" ]]; then
                i3-msg "split v; exec $term;"
                ws_split[$ws_number]=h
            else
                i3-msg "exec $term;"
            fi
        fi
    }

    main()
    {
        init

        local -r function="$1"
        local -r action="$2"

        case "$function" in
        "ws_split")
            ws_split "$action"
        ;;
        "ws_set_split")
            ws_set_split "$action"
        esac

        export
    }

    main "$@"
  '';

  renameScriptContent = builtins.readFile ./scripts/rename.sh;

  commonConfig = ''
    # i3 config file (v4)

    include ~/.config/my/theme/current/i3.conf

    set $sp ~/.config/i3/scripts

    # neo modifier, Mod4 is the windows key
    set $mod Mod4
    set $Alt Mod1
    set $AltGr Mod3
    set $Strg Control

    # Neo arrows
    set $MLeft  Mod3+Left
    set $MDown  Mod3+Down
    set $MRight Mod3+Right
    set $MUp    Mod3+Up

    font pango:Droid Sans Mono, 11

    # Use Mouse+$mod to drag floating windows to their wanted position
    floating_modifier $mod

    # start a terminal
    bindsym $mod+Return exec --no-startup-id $sp/i3scripts.sh ws_split auto
    bindsym $mod+Shift+Return exec --no-startup-id $sp/i3scripts.sh ws_split manual
    bindsym $mod+$AltGr+Return exec ${cfg.altTerminalCommand}

    # kill focused window
    bindsym $mod+Shift+q kill

    # start dmenu (a program launcher)
    bindsym $mod+o exec --no-startup-id rofi -show run
    bindsym $mod+Shift+o exec --no-startup-id rofi -show combi
    bindsym $mod+s exec --no-startup-id rofi -show ssh
    bindsym $mod+Shift+v exec --no-startup-id ~/local/bin/rofi-vpn/rofi-vpn.sh


    # Focus should not follow mouse movements
    focus_follows_mouse no

    # move focused window
    bindsym $mod+i move left 100 px
    bindsym $mod+a move down 100 px
    bindsym $mod+e move right 100 px
    bindsym $mod+l move up 100 px

    # change focus
    bindsym $mod+n focus left
    bindsym $mod+r focus down
    bindsym $mod+g focus up
    bindsym $mod+t focus right

    # split in horizontal orientation
    bindsym $mod+h split h; exec --no-startup-id $sp/i3scripts.sh ws_set_split h

    # split in vertical orientation
    bindsym $mod+v split v; exec --no-startup-id $sp/i3scripts.sh ws_set_split v

    # enter fullscreen mode for the focused container
    bindsym $mod+f fullscreen

    # change container layout (stacked, tabbed, toggle split)
    bindsym $mod+Shift+s layout stacking
    bindsym $mod+Shift+t layout tabbed
    bindsym $mod+Shift+h layout toggle split

    # toggle tiling / floating
    bindsym $mod+Shift+space floating toggle

    # change focus between tiling / floating windows
    bindsym $mod+space focus mode_toggle

    # focus the parent container
    bindsym $mod+p focus parent

    # focus the child container
    bindsym $mod+c focus child

    new_window 1pixel
    new_float 1pixel

    # Make the currently focused window a scratchpad
    bindsym $mod+Shift+u move scratchpad

    # Show the first scratchpad window
    bindsym $mod+u scratchpad show

    # Change keybindings
    bindsym $mod+x exec setxkbmap de neo
    bindsym $mod+Shift+x exec setxkbmap de

    # Toggle to previous window
    workspace_auto_back_and_forth yes

    # Change volume
    bindsym XF86AudioLowerVolume exec ponymix decrease 5
    bindsym XF86AudioRaiseVolume exec ponymix increase 5
    bindsym XF86AudioMute exec ponymix toggle
    bindsym $mod+m exec ponymix --source toggle
    bindsym XF86MonBrightnessUp exec brightnessctl set +1%
    bindsym XF86MonBrightnessDown exec brightnessctl set 1%-


    # Helper scripts
    bindsym $mod+b exec --no-startup-id $sp/rename.sh 0
    bindsym $mod+Shift+b exec --no-startup-id $sp/rename.sh
    bindsym --release Print exec --no-startup-id flameshot gui

    # Program shortcuts
    ${renderProgramShortcuts}

    bindsym $mod+ISO_Next_Group exec setxkbmap de neo
    bindsym $mod+Shift+ISO_Next_Group exec setxkbmap de

    ${renderAssignments}

    # switch to workspace
    ${renderWorkspaceSwitchBindings cfg.workspaces.primary}

    # move focused container to workspace
    ${renderWorkspaceMoveBindings cfg.workspaces.primary}

    # Define different modes
    ${renderModes}
  '';

  i3Config = ''
    ${startupExecs}

    ${commonConfig}
    ${secondaryWsConfig}
    ${displayConfig}
    ${cfg.extraConfig}
  '';
in {
  imports = [./i3status-rust.nix];

  options.my.hm.features.i3 = {
    enable = lib.mkEnableOption "i3 window manager configuration";

    commonStartupCommands = lib.mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Shared startup commands (exec --no-startup-id).";
    };

    localStartupCommands = lib.mkOption {
      type = types.listOf types.str;
      default = [];
      description = "Host-specific startup commands.";
    };

    terminal = lib.mkOption {
      type = types.str;
      default = "alacritty";
      description = "Terminal emulator for i3scripts.sh.";
    };

    altTerminalCommand = lib.mkOption {
      type = types.str;
      default = "alacritty";
      description = "Command launched by the $mod+$AltGr+Return binding.";
    };

    workRestoreCommand = lib.mkOption {
      type = types.str;
      default = defaultWorkRestoreCommand;
      description = "Command launched by the work restore mode binding.";
    };

    display = {
      primaryOutput = lib.mkOption {
        type = types.str;
        default = "DP-0";
        description = "Primary output name used in xrandr screen mode commands.";
      };
      secondaryOutput = lib.mkOption {
        type = types.str;
        default = "HDMI-1";
        description = "Secondary output name used in xrandr screen mode commands.";
      };
    };

    extraPackages = lib.mkOption {
      type = types.listOf types.package;
      default = [];
      description = "Additional packages installed with the i3 Home Manager feature.";
    };

    enableSecondaryWorkspaces = lib.mkOption {
      type = types.bool;
      default = true;
      description = "Generate F-key bindings for workspaces 11-19 on secondary output.";
    };

    barFont = lib.mkOption {
      type = types.str;
      default = "pango:Droid Sans Mono, Font Awesome 7 Free, 12";
      description = "Font declaration for the i3 bar.";
    };

    workspaces = {
      primary = lib.mkOption {
        type = types.listOf shared.workspaceSubmodule;
        default = defaultPrimaryWorkspaces;
        description = "Primary workspace bindings and output assignments.";
      };
      secondary = lib.mkOption {
        type = types.listOf shared.workspaceSubmodule;
        default = defaultSecondaryWorkspaces;
        description = "Secondary workspace bindings and output assignments.";
      };
    };

    programShortcuts = lib.mkOption {
      type = types.listOf shared.programShortcutSubmodule;
      default = defaultProgramShortcuts;
      description = "Program launch keybindings.";
    };

    assignments = lib.mkOption {
      type = types.listOf shared.assignmentSubmodule;
      default = defaultAssignments;
      description = "Window assignment rules.";
    };

    modes = lib.mkOption {
      type = types.listOf shared.modeSubmodule;
      default = defaultModes;
      description = "Named i3 modes.";
    };

    extraConfig = lib.mkOption {
      type = types.lines;
      default = "";
      description = "Additional i3 config lines.";
    };
  };

  config = lib.mkIf cfg.enable (lib.mkMerge [
    {
      home.packages = [pkgs.i3status-rust] ++ cfg.extraPackages;

      xdg.configFile."i3/config".text = i3Config;

      xdg.configFile."i3/scripts/i3scripts.sh" = {
        text = i3scriptsContent;
        executable = true;
      };
      xdg.configFile."i3/scripts/rename.sh" = {
        source = ./scripts/rename.sh;
        executable = true;
        force = true;
      };
      xdg.configFile."i3/scripts/display.sh" = {
        source = ./scripts/display.sh;
        executable = true;
        force = true;
      };

      xdg.configFile."i3/layouts/work_left.json" = {
        source = ./layouts/work_left.json;
        force = true;
      };
      xdg.configFile."i3/layouts/work_right.json" = {
        source = ./layouts/work_right.json;
        force = true;
      };
      xdg.configFile."i3/layouts/announcekit.json" = {
        source = ./layouts/announcekit.json;
        force = true;
      };
    }

    (lib.mkIf dynamicStyleEnabled {
      xdg.configFile."my/theme/i3/light.conf".text =
        style.mkI3Theme palettes.light + "\n" + renderBar palettes.light;

      xdg.configFile."my/theme/i3/dark.conf".text =
        style.mkI3Theme palettes.dark + "\n" + renderBar palettes.dark;
    })
  ]);
}
