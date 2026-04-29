{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.hm.features.i3;
  types = lib.types;
  primaryOutput = cfg.display.primaryOutput;
  secondaryOutput = cfg.display.secondaryOutput;

  defaultWorkRestoreCommand = ''i3-msg 'workspace "1: mail"; exec protonmail-bridge; exec thunderbird; workspace "2: browser"; exec librewolf; workspace 7; exec ~/local/bin/kxo; workspace "9: communication"; exec signal-desktop; exec librewolf --new-window --kiosk https://priceloop.slack.com; workspace 3; exec alacritty --working-directory ~/projects/priceloop/ogopogo/nocode' '';

  defaultPrimaryWorkspaces = [
    {
      number = 1;
      name = "mail";
      key = "1";
    }
    {
      number = 2;
      name = "browser";
      key = "2";
    }
    {
      number = 3;
      key = "3";
    }
    {
      number = 4;
      key = "4";
    }
    {
      number = 5;
      key = "5";
    }
    {
      number = 6;
      key = "6";
    }
    {
      number = 7;
      key = "7";
    }
    {
      number = 8;
      key = "8";
    }
    {
      number = 9;
      name = "communication";
      key = "9";
    }
    {
      number = 0;
      key = "0";
      assignOutput = false;
    }
  ];

  defaultSecondaryWorkspaces = [
    {
      number = 11;
      name = "terminal";
      key = "F1";
    }
    {
      number = 12;
      key = "F2";
    }
    {
      number = 13;
      key = "F3";
    }
    {
      number = 14;
      key = "F4";
    }
    {
      number = 15;
      key = "F5";
    }
    {
      number = 16;
      key = "F6";
    }
    {
      number = 17;
      key = "F7";
    }
    {
      number = 18;
      key = "F8";
    }
    {
      number = 19;
      name = "communication";
      key = "F9";
    }
  ];

  defaultProgramShortcuts = [
    {
      key = "$mod+$AltGr+colon";
      command = "librewolf";
    }
    {
      key = "$mod+$AltGr+Delete";
      command = "rofi-choose-container";
    }
    {
      key = "$mod+$AltGr+KP_Separator";
      command = "dropbox";
    }
    {
      key = "$mod+$AltGr+KP_9";
      command = "spacefm";
    }
    {
      key = "$mod+$AltGr+KP_8";
      command = "pidgin";
    }
    {
      key = "$mod+$AltGr+exclamdown";
      command = "~/local/bin/kxo";
    }
    {
      key = "$mod+$AltGr+Shift+exclamdown";
      command = "~/local/bin/kd";
    }
    {
      key = "$mod+$AltGr+KP_1";
      command = "protonmail-bridge; exec thunderbird;";
    }
    {
      key = "$mod+$AltGr+KP_4";
      command = "nmcli_dmenu";
    }
    {
      key = "$mod+$AltGr+KP_5";
      command = "RuneScape";
    }
    {
      key = "$mod+$AltGr+End";
      command = "spotify-blockify";
    }
    {
      key = "$mod+$AltGr+KP_6";
      command = "steam";
    }
    {
      key = "$mod+$AltGr+BackSpace";
      command = "VirtualBox";
    }
    {
      key = "$mod+$AltGr+period";
      command = "skype";
    }
    {
      key = "$mod+$AltGr+questiondown";
      command = "signal-desktop";
    }
    {
      key = "$mod+$AltGr+Left";
      command = "idea-community";
    }
    {
      key = "$mod+$Down";
      command = "thunderbird; exec librewolf; exec pidgin";
    }
  ];

  defaultAssignments = [
    {
      criteria = ''class="(?i)thunderbird"'';
      target = ''"1: mail"'';
    }
    {
      criteria = ''instance="(?i)protonmail-bridge" class="ProtonMail Bridge"'';
      target = ''"1: mail"'';
    }
    {
      criteria = ''class="(?i)navigator"'';
      target = ''"2: browser"'';
    }
    {
      criteria = ''class="(?i)browser"'';
      target = ''"2: browser"'';
    }
    {
      criteria = ''class="(?i)keepassxc"'';
      target = "7";
    }
    {
      criteria = ''class="(?i)signal"'';
      target = ''"9: communication"'';
    }
    {
      criteria = ''class="(?i)ekiga"'';
      target = ''"9: communication"'';
    }
    {
      criteria = ''class="(?i)pidgin"'';
      target = ''"9: communication"'';
    }
  ];

  defaultModes = [
    {
      name = "Exit <<< System:(e) logout, (r) reboot, (s) suspend, (p) poweroff [+sync]. i3: (AltGr+c) reload, (AltGr+r) restart";
      enterKey = "$mod+Shift+e";
      bindings = [
        {
          key = "$mod+r";
          command = "exec unmount-container-sync && systemctl reboot";
        }
        {
          key = "$mod+s";
          command = "exec unmount-container-sync && systemctl suspend";
        }
        {
          key = "$mod+p";
          command = "exec unmount-container-sync && systemctl poweroff";
        }
        {
          key = "$mod+e";
          command = ''exec unmount-container-sync; exit'';
        }
        {
          key = "r";
          command = "exec systemctl reboot";
        }
        {
          key = "s";
          command = "exec systemctl suspend";
        }
        {
          key = "p";
          command = "exec systemctl poweroff";
        }
        {
          key = "e";
          command = "exit";
        }
        {
          key = "$AltGr+Delete";
          command = ''reload; mode "default"'';
        }
        {
          key = "$AltGr+KP_5";
          command = "restart";
        }
        {
          key = "Return";
          command = ''mode "default"'';
        }
        {
          key = "Escape";
          command = ''mode "default"'';
        }
      ];
    }
    {
      name = "Screen / DMMS <<< Screens: (k)ino, (g)ame, (h)game right, (1) screen, (a)utomatic, (r)eset, (s)tandby, (p) suspend, (l)ock, (o)ff";
      enterKey = "$mod+Shift+m";
      bindings = [
        {
          key = "s";
          command = ''exec i3lock && xset dpms force standby; mode "default"'';
        }
        {
          key = "p";
          command = ''exec i3lock && xset dpms force suspend; mode "default"'';
        }
        {
          key = "l";
          command = ''exec xinput disable "$(xinput list | grep -i ".*mouse.*slave.*pointer.*" | cut -f2 | sed "s/id=//" | head -n 1)"; exec xset dpms force off; exec i3lock --nofork && xinput enable "$(xinput list | grep -i ".*mouse.*floating.*slave.*" | cut -f2 | sed "s/id=//" | head -n 1)"; mode "default"'';
        }
        {
          key = "o";
          command = ''exec xset dpms force off; mode "default"'';
        }
        {
          key = "k";
          command = ''exec xset -dpms && xset s off && systemctl --user stop redshift && xrandr --output ${primaryOutput} --primary --auto --output ${secondaryOutput} --off; mode "default"'';
        }
        {
          key = "g";
          command = ''exec xrandr --output ${primaryOutput} --primary --mode 1920x1080 --output ${secondaryOutput} --auto --right-of ${primaryOutput}; mode "default"'';
        }
        {
          key = "h";
          command = ''exec xrandr --output ${primaryOutput} --auto --primary --output ${secondaryOutput} --mode 1920x1080 --right-of ${primaryOutput}; mode "default"'';
        }
        {
          key = "KP_1";
          command = ''exec xrandr --output ${primaryOutput} --primary --auto --output ${secondaryOutput} --off; mode "default"'';
        }
        {
          key = "a";
          command = ''exec xrandr --output ${primaryOutput} --primary --mode 1920x1080 --output ${secondaryOutput} --off; mode "default"'';
        }
        {
          key = "r";
          command = ''exec xrandr --output ${primaryOutput} --primary --auto --output ${secondaryOutput} --auto --right-of ${primaryOutput}; mode "default"'';
        }
        {
          key = "Return";
          command = ''mode "default"'';
        }
        {
          key = "Escape";
          command = ''mode "default"'';
        }
      ];
    }
    {
      name = "resize <<< Resolution:(1) 1080p, (2) 2160p, (4) 480p, (7) 720p; Position: (c) center";
      enterKey = "$mod+Shift+r";
      bindings = [
        {
          key = "i";
          command = "resize shrink width 10 px or 10 ppt";
        }
        {
          key = "e";
          command = "resize grow width 10 px or 10 ppt";
        }
        {
          key = "l";
          command = "resize grow height 10 px or 10 ppt";
        }
        {
          key = "a";
          command = "resize shrink height 10 px or 10 ppt";
        }
        {
          key = "Left";
          command = "resize shrink width 1 px or 1 ppt";
        }
        {
          key = "Down";
          command = "resize grow height 1 px or 1 ppt";
        }
        {
          key = "Up";
          command = "resize shrink height 1 px or 1 ppt";
        }
        {
          key = "Right";
          command = "resize grow width 1 px or 1 ppt";
        }
        {
          key = "1";
          command = ''resize set 1920 1080; move position center; mode "default"'';
        }
        {
          key = "2";
          command = ''resize set 3840 2160; move position center; mode "default"'';
        }
        {
          key = "4";
          command = ''resize set 768 480; move position center; mode "default"'';
        }
        {
          key = "7";
          command = ''resize set 1280 720; move position center; mode "default"'';
        }
        {
          key = "c";
          command = ''move position center; mode "default"'';
        }
        {
          key = "Return";
          command = ''mode "default"'';
        }
        {
          key = "Escape";
          command = ''mode "default"'';
        }
      ];
    }
    {
      name = "work <<< Programs: (w) restore work layout, (s/S) move/show scratchpad";
      enterKey = "$mod+Shift+w";
      bindings = [
        {
          key = "w";
          command = "__WORK_RESTORE_COMMAND__";
        }
        {
          key = "s";
          command = ''move scratchpad; mode "default"'';
        }
        {
          key = "Shift+S";
          command = ''scratchpad show; mode "default"'';
        }
        {
          key = "Return";
          command = ''mode "default"'';
        }
        {
          key = "Escape";
          command = ''mode "default"'';
        }
      ];
    }
    {
      name = "refocus";
      enterKey = "$mod+Shift+f";
      bindings = [
        {
          key = "$MLeft";
          command = "focus left";
        }
        {
          key = "$MDown";
          command = "focus down";
        }
        {
          key = "$MUp";
          command = "focus up";
        }
        {
          key = "$MRight";
          command = "focus right";
        }
        {
          key = "p";
          command = "focus parent";
        }
        {
          key = "c";
          command = "focus child";
        }
        {
          key = "Shift+$MLeft";
          command = "move left";
        }
        {
          key = "Shift+$MDown";
          command = "move down";
        }
        {
          key = "Shift+$MUp";
          command = "move up";
        }
        {
          key = "Shift+$MRight";
          command = "move right";
        }
        {
          key = "Return";
          command = ''mode "default"'';
        }
        {
          key = "Escape";
          command = ''mode "default"'';
        }
        {
          key = "q";
          command = ''mode "default"'';
        }
      ];
    }
    {
      name = "redesign";
      enterKey = "$mod+Shift+d";
      bindings = [
        {
          key = "$mod+n";
          command = "border none";
        }
        {
          key = "$mod+y";
          command = "border 1px";
        }
        {
          key = "$mod+b";
          command = "border normal";
        }
        {
          key = "Return";
          command = ''mode "default"'';
        }
        {
          key = "Escape";
          command = ''mode "default"'';
        }
        {
          key = "q";
          command = ''mode "default"'';
        }
      ];
    }
  ];

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

  renderBarColors = ''
    colors {
        background $theme_bg
        statusline $theme_fg
        separator $theme_dim

        focused_workspace  $theme_blue  $theme_blue  $theme_bg
        active_workspace   $theme_black $theme_dim   $theme_fg
        inactive_workspace $theme_black $theme_bg    $theme_dim
        urgent_workspace   $theme_red   $theme_red   $theme_bg
    }
  '';

  renderBar = ''
    bar {
        font ${cfg.barFont}
        output primary
        ${lib.optionalString cfg.enableSecondaryWorkspaces "output nonprimary"}
        status_command ${pkgs.i3status-rust}/bin/i3status-rs $HOME/.config/i3status-rust/config.toml
        strip_workspace_numbers no
        ${renderBarColors}
    }
  '';

  displayConfig = ''
    # Workspace output assignments
    ${renderWorkspaceOutputs cfg.workspaces.primary "primary"}

    ${lib.optionalString cfg.enableSecondaryWorkspaces ''
      ${renderWorkspaceOutputs cfg.workspaces.secondary "nonprimary primary"}
    ''}

    ${renderBar}
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
        type = types.listOf (types.submodule {
          options = {
            number = lib.mkOption {
              type = types.int;
              description = "Workspace number.";
            };
            name = lib.mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Optional workspace label.";
            };
            key = lib.mkOption {
              type = types.str;
              description = "Key used with $mod and $mod+Shift for this workspace.";
            };
            assignOutput = lib.mkOption {
              type = types.bool;
              default = true;
              description = "Whether the display fragment assigns this workspace to an output.";
            };
          };
        });
        default = defaultPrimaryWorkspaces;
        description = "Primary workspace bindings and output assignments.";
      };
      secondary = lib.mkOption {
        type = types.listOf (types.submodule {
          options = {
            number = lib.mkOption {
              type = types.int;
              description = "Workspace number.";
            };
            name = lib.mkOption {
              type = types.nullOr types.str;
              default = null;
              description = "Optional workspace label.";
            };
            key = lib.mkOption {
              type = types.str;
              description = "Key used with $mod and $mod+Shift for this workspace.";
            };
            assignOutput = lib.mkOption {
              type = types.bool;
              default = true;
              description = "Whether the display fragment assigns this workspace to an output.";
            };
          };
        });
        default = defaultSecondaryWorkspaces;
        description = "Secondary workspace bindings and output assignments.";
      };
    };

    programShortcuts = lib.mkOption {
      type = types.listOf (types.submodule {
        options = {
          key = lib.mkOption {
            type = types.str;
            description = "Key sequence used in the bindsym.";
          };
          command = lib.mkOption {
            type = types.str;
            description = "Command after exec.";
          };
          noStartupId = lib.mkOption {
            type = types.bool;
            default = false;
            description = "Add --no-startup-id to the exec binding.";
          };
        };
      });
      default = defaultProgramShortcuts;
      description = "Program launch keybindings.";
    };

    assignments = lib.mkOption {
      type = types.listOf (types.submodule {
        options = {
          criteria = lib.mkOption {
            type = types.str;
            description = "i3 criteria without surrounding brackets.";
          };
          target = lib.mkOption {
            type = types.str;
            description = "Workspace target expression.";
          };
        };
      });
      default = defaultAssignments;
      description = "Window assignment rules.";
    };

    modes = lib.mkOption {
      type = types.listOf (types.submodule {
        options = {
          name = lib.mkOption {
            type = types.str;
            description = "i3 mode name.";
          };
          enterKey = lib.mkOption {
            type = types.str;
            description = "Key sequence that enters the mode.";
          };
          bindings = lib.mkOption {
            type = types.listOf (types.submodule {
              options = {
                key = lib.mkOption {
                  type = types.str;
                  description = "Key sequence within the mode.";
                };
                command = lib.mkOption {
                  type = types.str;
                  description = "i3 command for this binding.";
                };
              };
            });
            default = [];
            description = "Mode-local bindings.";
          };
        };
      });
      default = defaultModes;
      description = "Named i3 modes.";
    };

    extraConfig = lib.mkOption {
      type = types.lines;
      default = "";
      description = "Additional i3 config lines.";
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.i3status-rust] ++ cfg.extraPackages;

    xdg.configFile."i3/config".text = i3Config;

    xdg.configFile."i3/scripts/i3scripts.sh" = {
      text = i3scriptsContent;
      executable = true;
    };
    xdg.configFile."i3/scripts/rename.sh" = {
      source = ./scripts/rename.sh;
      executable = true;
    };
    xdg.configFile."i3/scripts/display.sh" = {
      source = ./scripts/display.sh;
      executable = true;
    };

    xdg.configFile."i3/layouts/work_left.json".source = ./layouts/work_left.json;
    xdg.configFile."i3/layouts/work_right.json".source = ./layouts/work_right.json;
    xdg.configFile."i3/layouts/announcekit.json".source = ./layouts/announcekit.json;
  };
}
