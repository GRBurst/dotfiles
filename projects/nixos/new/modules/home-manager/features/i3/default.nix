{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.hm.features.i3;

  startupExecs =
    lib.concatMapStringsSep "\n"
    (cmd: "exec --no-startup-id ${cmd}")
    (cfg.commonStartupCommands ++ cfg.localStartupCommands);

  mkDisplayConfig = {
    primary,
    secondary ? null,
  }: let
    secondaryOutput =
      if secondary != null
      then secondary
      else primary;
  in ''
    # Workspace output assignments
    workspace "1: mail" output ${primary}
    workspace "2: browser" output ${primary}
    workspace 3 output ${primary}
    workspace 4 output ${primary}
    workspace 5 output ${primary}
    workspace 6 output ${primary}
    workspace 7 output ${primary}
    workspace 8 output ${primary}
    workspace "9: communication" output ${primary}

    ${lib.optionalString cfg.enableSecondaryWorkspaces ''
      workspace "11: terminal" output ${secondaryOutput}
      workspace 12 output ${secondaryOutput}
      workspace 13 output ${secondaryOutput}
      workspace 14 output ${secondaryOutput}
      workspace 15 output ${secondaryOutput}
      workspace 16 output ${secondaryOutput}
      workspace 17 output ${secondaryOutput}
      workspace 18 output ${secondaryOutput}
      workspace "19: communication" output ${secondaryOutput}
    ''}

    bar {
        font ${cfg.barFont}
        output ${primary}
        ${lib.optionalString cfg.enableSecondaryWorkspaces "output ${secondaryOutput}"}
        status_command ${pkgs.i3status-rust}/bin/i3status-rs $HOME/.config/i3status-rust/config.toml
        strip_workspace_numbers no
        colors {
            background #000000
            statusline #ffffff
            separator #666666

            focused_workspace  $lblue   #285577 #ffffff
            active_workspace   #333333  #5f676a #ffffff
            inactive_workspace #333333  #222222 #888888
            urgent_workspace   #2f343a  #900000 #ffffff
        }
    }
  '';

  secondaryWsConfig = lib.optionalString cfg.enableSecondaryWorkspaces ''

    # switch to workspace (secondary)
    bindsym $mod+F1 workspace number 11: terminal; [con_mark="awot"] move workspace current;
    bindsym $mod+F2 workspace number 12; [con_mark="awot"] move workspace current;
    bindsym $mod+F3 workspace number 13; [con_mark="awot"] move workspace current;
    bindsym $mod+F4 workspace number 14; [con_mark="awot"] move workspace current;
    bindsym $mod+F5 workspace number 15; [con_mark="awot"] move workspace current;
    bindsym $mod+F6 workspace number 16; [con_mark="awot"] move workspace current;
    bindsym $mod+F7 workspace number 17; [con_mark="awot"] move workspace current;
    bindsym $mod+F8 workspace number 18; [con_mark="awot"] move workspace current;
    bindsym $mod+F9 workspace number 19: communication; [con_mark="awot"] move workspace current;

    # move focused container to workspace (secondary)
    bindsym $mod+Shift+F1 move container to workspace number 11: terminal
    bindsym $mod+Shift+F2 move container to workspace number 12
    bindsym $mod+Shift+F3 move container to workspace number 13
    bindsym $mod+Shift+F4 move container to workspace number 14
    bindsym $mod+Shift+F5 move container to workspace number 15
    bindsym $mod+Shift+F6 move container to workspace number 16
    bindsym $mod+Shift+F7 move container to workspace number 17
    bindsym $mod+Shift+F8 move container to workspace number 18
    bindsym $mod+Shift+F9 move container to workspace number 19: communication
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
    bindsym $mod+$AltGr+Return exec alacritty --working-directory ~/projects/pallon/webapp/frontend

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

    # Colors
    set $lblue "#37baff"
    set $ddgray "#101010"
    # Color => for 1px border only backgr. visible
    # class                 border  backgr. text    indicator
    client.focused          #4c7899 #00ccff #ffffff #ff99ff
    client.focused_inactive #333333 #cccccc #ffffff #484e50
    client.unfocused        #333333 #333333 #888888 #292d2e
    client.urgent           #2f343a #ff0000 #ffffff #900000
    client.placeholder      #000000 #33cc33 #ffffff #000000

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
    bindsym $mod+$AltGr+colon exec librewolf
    bindsym $mod+$AltGr+Delete exec rofi-choose-container
    bindsym $mod+$AltGr+KP_Separator exec dropbox
    bindsym $mod+$AltGr+KP_9 exec spacefm
    bindsym $mod+$AltGr+KP_8 exec pidgin
    bindsym $mod+$AltGr+exclamdown exec ~/local/bin/kxo
    bindsym $mod+$AltGr+Shift+exclamdown exec ~/local/bin/kd
    bindsym $mod+$AltGr+KP_1 exec protonmail-bridge; exec thunderbird;
    bindsym $mod+$AltGr+KP_4 exec nmcli_dmenu
    bindsym $mod+$AltGr+KP_5 exec RuneScape
    bindsym $mod+$AltGr+End exec spotify-blockify
    bindsym $mod+$AltGr+KP_6 exec steam
    bindsym $mod+$AltGr+BackSpace exec VirtualBox
    bindsym $mod+$AltGr+period exec skype
    bindsym $mod+$AltGr+questiondown exec signal-desktop

    bindsym $mod+$AltGr+Left exec idea-community
    bindsym $mod+$Down exec thunderbird; exec librewolf; exec pidgin

    bindsym $mod+ISO_Next_Group exec setxkbmap de neo
    bindsym $mod+Shift+ISO_Next_Group exec setxkbmap de

    assign [class="(?i)thunderbird"] "1: mail"
    assign [instance="(?i)protonmail-bridge" class="ProtonMail Bridge"] "1: mail"
    assign [class="(?i)navigator"] "2: browser"
    assign [class="(?i)browser"] "2: browser"
    assign [class="(?i)keepassxc"] 7
    assign [class="(?i)signal"] "9: communication"
    assign [class="(?i)ekiga"] "9: communication"
    assign [class="(?i)pidgin"] "9: communication"

    # switch to workspace
    bindsym $mod+1 workspace number 1: mail; [con_mark="awot"] move workspace current;
    bindsym $mod+2 workspace number 2: browser; [con_mark="awot"] move workspace current;
    bindsym $mod+3 workspace number 3; [con_mark="awot"] move workspace current;
    bindsym $mod+4 workspace number 4; [con_mark="awot"] move workspace current;
    bindsym $mod+5 workspace number 5; [con_mark="awot"] move workspace current;
    bindsym $mod+6 workspace number 6; [con_mark="awot"] move workspace current;
    bindsym $mod+7 workspace number 7; [con_mark="awot"] move workspace current;
    bindsym $mod+8 workspace number 8; [con_mark="awot"] move workspace current;
    bindsym $mod+9 workspace number 9: communication; [con_mark="awot"] move workspace current;
    bindsym $mod+0 workspace number 0; [con_mark="awot"] move workspace current;

    # move focused container to workspace
    bindsym $mod+Shift+1 move container to workspace number 1: mail
    bindsym $mod+Shift+2 move container to workspace number 2: browser
    bindsym $mod+Shift+3 move container to workspace number 3
    bindsym $mod+Shift+4 move container to workspace number 4
    bindsym $mod+Shift+5 move container to workspace number 5
    bindsym $mod+Shift+6 move container to workspace number 6
    bindsym $mod+Shift+7 move container to workspace number 7
    bindsym $mod+Shift+8 move container to workspace number 8
    bindsym $mod+Shift+9 move container to workspace number 9: communication
    bindsym $mod+Shift+0 move container to workspace number 0

    # Define different modes
    mode "Exit <<< System:(e) logout, (r) reboot, (s) suspend, (p) poweroff [+sync]. i3: (AltGr+c) reload, (AltGr+r) restart" {
            bindsym $mod+r exec unmount-container-sync && systemctl reboot
            bindsym $mod+s exec unmount-container-sync && systemctl suspend
            bindsym $mod+p exec unmount-container-sync && systemctl poweroff
            bindsym $mod+e exec unmount-container-sync; exit

            bindsym r exec systemctl reboot
            bindsym s exec systemctl suspend
            bindsym p exec systemctl poweroff
            bindsym e exit
            bindsym $AltGr+Delete reload; mode "default"
            bindsym $AltGr+KP_5 restart

            bindsym Return mode "default"
            bindsym Escape mode "default"
    }
    bindsym $mod+Shift+e mode "Exit <<< System:(e) logout, (r) reboot, (s) suspend, (p) poweroff [+sync]. i3: (AltGr+c) reload, (AltGr+r) restart"

    mode "Screen / DMMS <<< Screens: (k)ino, (g)ame, (h)game right, (1) screen, (a)utomatic, (r)eset, (s)tandby, (p) suspend, (l)ock, (o)ff" {
            bindsym s exec i3lock && xset dpms force standby; mode "default"
            bindsym p exec i3lock && xset dpms force suspend; mode "default"
            bindsym l exec xinput disable "$(xinput list | grep -i ".*mouse.*slave.*pointer.*" | cut -f2 | sed "s/id=//" | head -n 1)"; exec xset dpms force off; exec i3lock --nofork && xinput enable "$(xinput list | grep -i ".*mouse.*floating.*slave.*" | cut -f2 | sed "s/id=//" | head -n 1)"; mode "default"
            bindsym o exec xset dpms force off; mode "default"

            bindsym k exec xset -dpms && xset s off && systemctl --user stop redshift && xrandr --output DP-0 --primary --auto --output HDMI-1 --off; mode "default"
            bindsym g exec xrandr --output DP-0 --primary --mode 1920x1080 --output HDMI-1 --auto --right-of DP-0; mode "default"
            bindsym h exec xrandr --output DP-0 --auto --primary --output HDMI-1 --mode 1920x1080 --right-of DP-0; mode "default"
            bindsym KP_1 exec xrandr --output DP-0 --primary --auto --output HDMI-1 --off; mode "default"
            bindsym a exec xrandr --output DP-0 --primary --mode 1920x1080 --output HDMI-1 --off; mode "default"

            bindsym r exec xrandr --output DP-0 --primary --auto --output HDMI-1 --auto --right-of DP-0; mode "default"
            bindsym Return mode "default"
            bindsym Escape mode "default"
    }
    bindsym $mod+Shift+m mode "Screen / DMMS <<< Screens: (k)ino, (g)ame, (h)game right, (1) screen, (a)utomatic, (r)eset, (s)tandby, (p) suspend, (l)ock, (o)ff"

    mode "resize <<< Resolution:(1) 1080p, (2) 2160p, (4) 480p, (7) 720p; Position: (c) center" {
            bindsym i resize shrink width 10 px or 10 ppt
            bindsym e resize grow width 10 px or 10 ppt
            bindsym l resize grow height 10 px or 10 ppt
            bindsym a resize shrink height 10 px or 10 ppt

            bindsym Left resize shrink width 1 px or 1 ppt
            bindsym Down resize grow height 1 px or 1 ppt
            bindsym Up resize shrink height 1 px or 1 ppt
            bindsym Right resize grow width 1 px or 1 ppt

            bindsym 1 resize set 1920 1080; move position center; mode "default"
            bindsym 2 resize set 3840 2160; move position center; mode "default"
            bindsym 4 resize set 768 480; move position center; mode "default"
            bindsym 7 resize set 1280 720; move position center; mode "default"

            bindsym c move position center; mode "default"

            bindsym Return mode "default"
            bindsym Escape mode "default"
    }
    bindsym $mod+Shift+r mode "resize <<< Resolution:(1) 1080p, (2) 2160p, (4) 480p, (7) 720p; Position: (c) center"

    mode "work <<< Programs: (w) restore work layout, (s/S) move/show scratchpad" {

            bindsym w exec --no-startup-id i3-msg 'workspace "1: mail"; exec protonmail-bridge; exec thunderbird; workspace "2: browser"; exec librewolf; workspace 7; exec ~/local/bin/kxo; workspace "9: communication"; exec signal-desktop; exec librewolf --new-window --kiosk https://priceloop.slack.com; workspace 3; exec alacritty --working-directory ~/projects/priceloop/ogopogo/nocode'; mode "default"

            bindsym s move scratchpad; mode "default"
            bindsym Shift+S scratchpad show; mode "default"

            bindsym Return mode "default"
            bindsym Escape mode "default"
    }
    bindsym $mod+Shift+w mode "work <<< Programs: (w) restore work layout, (s/S) move/show scratchpad"

    mode "refocus" {
            bindsym $MLeft focus left
            bindsym $MDown focus down
            bindsym $MUp focus up
            bindsym $MRight focus right

            bindsym p focus parent
            bindsym c focus child

            bindsym Shift+$MLeft move left
            bindsym Shift+$MDown move down
            bindsym Shift+$MUp move up
            bindsym Shift+$MRight move right

            bindsym Return mode "default"
            bindsym Escape mode "default"
            bindsym q mode "default"
    }
    bindsym $mod+Shift+f mode "refocus"

    mode "redesign" {

        bindsym $mod+n border none
        bindsym $mod+y border 1px
        bindsym $mod+b border normal

        bindsym Return mode "default"
        bindsym Escape mode "default"
        bindsym q mode "default"
    }
    bindsym $mod+Shift+d mode "redesign"
  '';

  i3Config = ''
    ${startupExecs}

    ${commonConfig}
    ${secondaryWsConfig}
    include ~/.config/i3/display-config
    ${cfg.extraConfig}
  '';
in {
  imports = [./i3status-rust.nix];

  options.my.hm.features.i3 = {
    enable = lib.mkEnableOption "i3 window manager configuration";

    defaultOutputs = {
      primary = lib.mkOption {
        type = lib.types.str;
        default = "eDP-1";
        description = "Default primary output for $OUT variable.";
      };
      secondary = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Default secondary output for $OUT2. null defaults to primary.";
      };
    };

    commonStartupCommands = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Shared startup commands (exec --no-startup-id).";
    };

    localStartupCommands = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Host-specific startup commands.";
    };

    terminal = lib.mkOption {
      type = lib.types.str;
      default = "alacritty";
      description = "Terminal emulator for i3scripts.sh.";
    };

    enableSecondaryWorkspaces = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Generate F-key bindings for workspaces 11-19 on secondary output.";
    };

    barFont = lib.mkOption {
      type = lib.types.str;
      default = "pango:Droid Sans Mono, Font Awesome 7 Free, 12";
      description = "Font declaration for the i3 bar.";
    };

    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Additional i3 config lines.";
    };

  };

  config = lib.mkIf cfg.enable {
    home.packages = [pkgs.i3status-rust];

    xdg.configFile."i3/config".text = i3Config;

    xdg.configFile."i3/scripts/i3scripts.sh" = {
      text = i3scriptsContent;
      executable = true;
    };
    xdg.configFile."i3/scripts/write-display-config.sh" = let
      displayTemplate = mkDisplayConfig {
        primary = "__PRIMARY__";
        secondary = "__SECONDARY__";
      };
    in {
      text = ''
        #!/usr/bin/env bash
        set -eu

        primary="$1"
        secondary="''${2:-$1}"
        target="$HOME/.config/i3/display-config"
        mkdir -p "$(dirname "$target")"
        tmp="$(mktemp)"
        cat > "$tmp" <<'EOF'
        ${displayTemplate}
        EOF
        sed \
          -e "s/__PRIMARY__/$primary/g" \
          -e "s/__SECONDARY__/$secondary/g" \
          "$tmp" > "$target"
        rm -f "$tmp"
      '';
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

    home.activation.createI3DisplayConfig = lib.hm.dag.entryAfter ["writeBoundary"] (let
      secondary =
        if cfg.defaultOutputs.secondary != null
        then cfg.defaultOutputs.secondary
        else cfg.defaultOutputs.primary;
      defaultDisplayConfig = mkDisplayConfig {
        primary = cfg.defaultOutputs.primary;
        secondary = secondary;
      };
    in ''
      displayConfig="$HOME/.config/i3/display-config"
      if [ ! -f "$displayConfig" ]; then
        mkdir -p "$(dirname "$displayConfig")"
        printf '%s\n' ${lib.escapeShellArg defaultDisplayConfig} > "$displayConfig"
      fi
    '');
  };
}
