# Shared types, defaults, and pure render helpers for i3 and sway modules.
{ lib }:
let
  types = lib.types;

  modeBindingSubmodule = types.submodule {
    options = {
      key = lib.mkOption {
        type = types.str;
        description = "Key sequence within the mode.";
      };
      command = lib.mkOption {
        type = types.str;
        description = "WM command for this binding.";
      };
    };
  };
in
rec {
  # --------------------------------------------------------------------------
  # Types
  # --------------------------------------------------------------------------

  workspaceSubmodule = types.submodule {
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
        description = "Key used with \$mod and \$mod+Shift for this workspace.";
      };
      assignOutput = lib.mkOption {
        type = types.bool;
        default = true;
        description = "Whether to assign this workspace to a named output.";
      };
    };
  };

  modeSubmodule = types.submodule {
    options = {
      name = lib.mkOption {
        type = types.str;
        description = "Mode name.";
      };
      enterKey = lib.mkOption {
        type = types.str;
        description = "Key sequence that enters the mode.";
      };
      bindings = lib.mkOption {
        type = types.listOf modeBindingSubmodule;
        default = [];
        description = "Mode-local bindings.";
      };
    };
  };

  programShortcutSubmodule = types.submodule {
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
  };

  assignmentSubmodule = types.submodule {
    options = {
      criteria = lib.mkOption {
        type = types.str;
        description = "Window criteria without surrounding brackets.";
      };
      target = lib.mkOption {
        type = types.str;
        description = "Workspace target expression.";
      };
    };
  };

  # --------------------------------------------------------------------------
  # Shared defaults
  # --------------------------------------------------------------------------

  defaultPrimaryWorkspaces = [
    { number = 1; name = "mail"; key = "1"; }
    { number = 2; name = "browser"; key = "2"; }
    { number = 3; key = "3"; }
    { number = 4; key = "4"; }
    { number = 5; key = "5"; }
    { number = 6; key = "6"; }
    { number = 7; key = "7"; }
    { number = 8; key = "8"; }
    { number = 9; name = "communication"; key = "9"; }
    { number = 0; key = "0"; assignOutput = false; }
  ];

  defaultSecondaryWorkspaces = [
    { number = 11; name = "terminal"; key = "F1"; }
    { number = 12; key = "F2"; }
    { number = 13; key = "F3"; }
    { number = 14; key = "F4"; }
    { number = 15; key = "F5"; }
    { number = 16; key = "F6"; }
    { number = 17; key = "F7"; }
    { number = 18; key = "F8"; }
    { number = 19; name = "communication"; key = "F9"; }
  ];

  defaultProgramShortcuts = [
    { key = "$mod+$AltGr+colon"; command = "librewolf"; }
    { key = "$mod+$AltGr+Delete"; command = "rofi-choose-container"; }
    { key = "$mod+$AltGr+KP_Separator"; command = "dropbox"; }
    { key = "$mod+$AltGr+KP_9"; command = "spacefm"; }
    { key = "$mod+$AltGr+KP_8"; command = "pidgin"; }
    { key = "$mod+$AltGr+exclamdown"; command = "~/local/bin/kxo"; }
    { key = "$mod+$AltGr+Shift+exclamdown"; command = "~/local/bin/kd"; }
    { key = "$mod+$AltGr+KP_1"; command = "protonmail-bridge; exec thunderbird;"; }
    { key = "$mod+$AltGr+KP_4"; command = "nmcli_dmenu"; }
    { key = "$mod+$AltGr+KP_5"; command = "RuneScape"; }
    { key = "$mod+$AltGr+End"; command = "spotify-blockify"; }
    { key = "$mod+$AltGr+KP_6"; command = "steam"; }
    { key = "$mod+$AltGr+BackSpace"; command = "VirtualBox"; }
    { key = "$mod+$AltGr+period"; command = "skype"; }
    { key = "$mod+$AltGr+questiondown"; command = "signal-desktop"; }
    { key = "$mod+$AltGr+Left"; command = "idea-community"; }
    { key = "$mod+Down"; command = "thunderbird; exec librewolf; exec pidgin"; }
  ];

  defaultAssignments = [
    { criteria = ''class="(?i)thunderbird"''; target = ''"1: mail"''; }
    { criteria = ''instance="(?i)protonmail-bridge" class="ProtonMail Bridge"''; target = ''"1: mail"''; }
    { criteria = ''class="(?i)navigator"''; target = ''"2: browser"''; }
    { criteria = ''class="(?i)browser"''; target = ''"2: browser"''; }
    { criteria = ''class="(?i)keepassxc"''; target = "7"; }
    { criteria = ''class="(?i)signal"''; target = ''"9: communication"''; }
    { criteria = ''class="(?i)ekiga"''; target = ''"9: communication"''; }
    { criteria = ''class="(?i)pidgin"''; target = ''"9: communication"''; }
  ];

  # Screen mode for sway (replaces xrandr/xset/i3lock with Wayland equivalents).
  swayScreenMode = {
    name = "Screen / DPMS <<< (s)tandby, (p) suspend, (l)ock, (o)ff display, (r)eset";
    enterKey = "$mod+Shift+m";
    bindings = [
      { key = "s"; command = ''exec swaylock -f && swaymsg output '*' power off; mode "default"''; }
      { key = "p"; command = ''exec swaylock -f && systemctl suspend; mode "default"''; }
      { key = "l"; command = ''exec swaylock -f; mode "default"''; }
      { key = "o"; command = ''exec swaymsg output '*' power off; mode "default"''; }
      { key = "r"; command = ''exec swaymsg output '*' power on; mode "default"''; }
      { key = "Return"; command = ''mode "default"''; }
      { key = "Escape"; command = ''mode "default"''; }
    ];
  };

  # Default i3 modes factory. Accepts display output names to interpolate into
  # xrandr commands in the Screen mode.
  mkDefaultI3Modes = { primaryOutput ? "DP-0", secondaryOutput ? "HDMI-1" }: [
    {
      name = "Exit <<< System:(e) logout, (r) reboot, (s) suspend, (p) poweroff [+sync]. i3: (AltGr+c) reload, (AltGr+r) restart";
      enterKey = "$mod+Shift+e";
      bindings = [
        { key = "$mod+r"; command = "exec unmount-container-sync && systemctl reboot"; }
        { key = "$mod+s"; command = "exec unmount-container-sync && systemctl suspend"; }
        { key = "$mod+p"; command = "exec unmount-container-sync && systemctl poweroff"; }
        { key = "$mod+e"; command = ''exec unmount-container-sync; exit''; }
        { key = "r"; command = "exec systemctl reboot"; }
        { key = "s"; command = "exec systemctl suspend"; }
        { key = "p"; command = "exec systemctl poweroff"; }
        { key = "e"; command = "exit"; }
        { key = "$AltGr+Delete"; command = ''reload; mode "default"''; }
        { key = "$AltGr+KP_5"; command = "restart"; }
        { key = "Return"; command = ''mode "default"''; }
        { key = "Escape"; command = ''mode "default"''; }
      ];
    }
    {
      name = "Screen / DMMS <<< Screens: (k)ino, (g)ame, (h)game right, (1) screen, (a)utomatic, (r)eset, (s)tandby, (p) suspend, (l)ock, (o)ff";
      enterKey = "$mod+Shift+m";
      bindings = [
        { key = "s"; command = ''exec i3lock && xset dpms force standby; mode "default"''; }
        { key = "p"; command = ''exec i3lock && xset dpms force suspend; mode "default"''; }
        { key = "l"; command = ''exec xinput disable "$(xinput list | grep -i ".*mouse.*slave.*pointer.*" | cut -f2 | sed "s/id=//" | head -n 1)"; exec xset dpms force off; exec i3lock --nofork && xinput enable "$(xinput list | grep -i ".*mouse.*floating.*slave.*" | cut -f2 | sed "s/id=//" | head -n 1)"; mode "default"''; }
        { key = "o"; command = ''exec xset dpms force off; mode "default"''; }
        { key = "k"; command = ''exec xset -dpms && xset s off && systemctl --user stop redshift && xrandr --output ${primaryOutput} --primary --auto --output ${secondaryOutput} --off; mode "default"''; }
        { key = "g"; command = ''exec xrandr --output ${primaryOutput} --primary --mode 1920x1080 --output ${secondaryOutput} --auto --right-of ${primaryOutput}; mode "default"''; }
        { key = "h"; command = ''exec xrandr --output ${primaryOutput} --auto --primary --output ${secondaryOutput} --mode 1920x1080 --right-of ${primaryOutput}; mode "default"''; }
        { key = "KP_1"; command = ''exec xrandr --output ${primaryOutput} --primary --auto --output ${secondaryOutput} --off; mode "default"''; }
        { key = "a"; command = ''exec xrandr --output ${primaryOutput} --primary --mode 1920x1080 --output ${secondaryOutput} --off; mode "default"''; }
        { key = "r"; command = ''exec xrandr --output ${primaryOutput} --primary --auto --output ${secondaryOutput} --auto --right-of ${primaryOutput}; mode "default"''; }
        { key = "Return"; command = ''mode "default"''; }
        { key = "Escape"; command = ''mode "default"''; }
      ];
    }
    {
      name = "resize <<< Resolution:(1) 1080p, (2) 2160p, (4) 480p, (7) 720p; Position: (c) center";
      enterKey = "$mod+Shift+r";
      bindings = [
        { key = "i"; command = "resize shrink width 10 px or 10 ppt"; }
        { key = "e"; command = "resize grow width 10 px or 10 ppt"; }
        { key = "l"; command = "resize grow height 10 px or 10 ppt"; }
        { key = "a"; command = "resize shrink height 10 px or 10 ppt"; }
        { key = "Left"; command = "resize shrink width 1 px or 1 ppt"; }
        { key = "Down"; command = "resize grow height 1 px or 1 ppt"; }
        { key = "Up"; command = "resize shrink height 1 px or 1 ppt"; }
        { key = "Right"; command = "resize grow width 1 px or 1 ppt"; }
        { key = "1"; command = ''resize set 1920 1080; move position center; mode "default"''; }
        { key = "2"; command = ''resize set 3840 2160; move position center; mode "default"''; }
        { key = "4"; command = ''resize set 768 480; move position center; mode "default"''; }
        { key = "7"; command = ''resize set 1280 720; move position center; mode "default"''; }
        { key = "c"; command = ''move position center; mode "default"''; }
        { key = "Return"; command = ''mode "default"''; }
        { key = "Escape"; command = ''mode "default"''; }
      ];
    }
    {
      name = "work <<< Programs: (w) restore work layout, (s/S) move/show scratchpad";
      enterKey = "$mod+Shift+w";
      bindings = [
        { key = "w"; command = "__WORK_RESTORE_COMMAND__"; }
        { key = "s"; command = ''move scratchpad; mode "default"''; }
        { key = "Shift+S"; command = ''scratchpad show; mode "default"''; }
        { key = "Return"; command = ''mode "default"''; }
        { key = "Escape"; command = ''mode "default"''; }
      ];
    }
    {
      name = "refocus";
      enterKey = "$mod+Shift+f";
      bindings = [
        { key = "$MLeft"; command = "focus left"; }
        { key = "$MDown"; command = "focus down"; }
        { key = "$MUp"; command = "focus up"; }
        { key = "$MRight"; command = "focus right"; }
        { key = "p"; command = "focus parent"; }
        { key = "c"; command = "focus child"; }
        { key = "Shift+$MLeft"; command = "move left"; }
        { key = "Shift+$MDown"; command = "move down"; }
        { key = "Shift+$MUp"; command = "move up"; }
        { key = "Shift+$MRight"; command = "move right"; }
        { key = "Return"; command = ''mode "default"''; }
        { key = "Escape"; command = ''mode "default"''; }
        { key = "q"; command = ''mode "default"''; }
      ];
    }
    {
      name = "redesign";
      enterKey = "$mod+Shift+d";
      bindings = [
        { key = "$mod+n"; command = "border none"; }
        { key = "$mod+y"; command = "border 1px"; }
        { key = "$mod+b"; command = "border normal"; }
        { key = "Return"; command = ''mode "default"''; }
        { key = "Escape"; command = ''mode "default"''; }
        { key = "q"; command = ''mode "default"''; }
      ];
    }
  ];

  # --------------------------------------------------------------------------
  # Pure render helpers (no WM-specific tokens; usable from both i3 and sway)
  # --------------------------------------------------------------------------

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

  renderProgramShortcut = shortcut:
    "bindsym ${shortcut.key} exec ${lib.optionalString shortcut.noStartupId "--no-startup-id "}${shortcut.command}";
}
