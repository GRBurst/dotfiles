{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.hm.features.hyprland;

  monitorSubmodule = lib.types.submodule {
    options = {
      name = lib.mkOption {type = lib.types.str;};
      resolution = lib.mkOption {
        type = lib.types.str;
        default = "preferred";
      };
      position = lib.mkOption {
        type = lib.types.str;
        default = "auto";
      };
      scale = lib.mkOption {
        type = lib.types.float;
        default = 1.0;
      };
    };
  };
in {
  options.my.hm.features.hyprland = {
    enable = lib.mkEnableOption "Hyprland user configuration";
    nvidia = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable NVIDIA-specific Wayland env vars";
    };
    monitors = lib.mkOption {
      type = lib.types.listOf monitorSubmodule;
      default = [];
      description = "Monitor configuration (name, resolution, position, scale)";
    };
    extraConfig = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Extra lines appended to hyprland.conf";
    };
    extraExecOnce = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      default = [];
      description = "Additional commands appended to Hyprland exec-once.";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."uwsm/env".source = "${config.home.sessionVariablesPackage}/etc/profile.d/hm-session-vars.sh";

    # NixOS owns Hyprland and xdg-desktop-portal-hyprland packages.
    xdg.portal.enable = lib.mkForce false;

    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = false;
      package = null;
      portalPackage = null;
      xwayland.enable = true;

      settings = {
        # --- Monitors ---
        monitor =
          (map (m: "${m.name}, ${m.resolution}, ${m.position}, ${toString m.scale}")
            cfg.monitors)
          ++ lib.optional (cfg.monitors == []) ", preferred, auto, 1";

        # --- Input (NEO keyboard layout) ---
        input = {
          kb_layout = "de,de";
          kb_variant = "neo,basic";
          kb_options = "grp:menu_toggle";
          follow_mouse = 0;
          touchpad = {
            natural_scroll = false;
            disable_while_typing = true;
          };
        };

        # --- General ---
        general = {
          gaps_in = 2;
          gaps_out = 4;
          border_size = 2;
          layout = "dwindle";
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        misc = {
          force_default_wallpaper = 0;
        };

        binds = {
          workspace_back_and_forth = true;
        };

        decoration = {
          rounding = 4;
        };

        cursor = lib.optionalAttrs cfg.nvidia {
          no_hardware_cursors = true;
        };

        # --- Environment variables ---
        env =
          [
            "XCURSOR_SIZE,64"
            "QT_QPA_PLATFORM,wayland;xcb"
            "QT_WAYLAND_DISABLE_WINDOWDECORATION,1"
            "QT_AUTO_SCREEN_SCALE_FACTOR,1"
            "GDK_BACKEND,wayland,x11"
            "MOZ_ENABLE_WAYLAND,1"
            "NIXOS_OZONE_WL,1"
          ]
          ++ lib.optionals cfg.nvidia [
            "LIBVA_DRIVER_NAME,nvidia"
            "XDG_SESSION_TYPE,wayland"
            "GBM_BACKEND,nvidia-drm"
            "__GLX_VENDOR_LIBRARY_NAME,nvidia"
            "NVD_BACKEND,direct"
          ];

        # --- Autostart ---
        exec-once =
          [
            "waybar"
            "hyprpaper"
            "nm-applet --indicator"
            "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
            "gnome-keyring-daemon --start --components=pkcs11,secrets,ssh"
            "hypridle"
          ]
          ++ cfg.extraExecOnce;

        # --- Keybindings (NEO layout: n/r/g/t = focus, i/a/e/l = move) ---
        "$mod" = "SUPER";

        bind = [
          # Terminal
          "$mod, Return, exec, alacritty"
          "$mod SHIFT, Return, exec, kitty"
          "$mod SHIFT, Q, killactive,"

          # Launcher
          "$mod, O, exec, rofi -show drun -show-icons"
          "$mod SHIFT, O, exec, rofi -show combi"
          "$mod, S, exec, rofi -show ssh"
          "$mod SHIFT, V, exec, ~/local/bin/rofi-vpn/rofi-vpn.sh"

          # Focus (NEO: n=left, r=down, g=up, t=right)
          "$mod, N, movefocus, l"
          "$mod, R, movefocus, d"
          "$mod, G, movefocus, u"
          "$mod, T, movefocus, r"

          # Move window (NEO: i=left, a=down, e=right, l=up)
          "$mod, I, movewindow, l"
          "$mod, A, movewindow, d"
          "$mod, E, movewindow, r"
          "$mod, L, movewindow, u"

          # Layout
          "$mod, F, fullscreen, 0"
          "$mod SHIFT, Space, togglefloating,"
          "$mod, Space, cyclenext, floating"
          "$mod, H, layoutmsg, preselect l"
          "$mod, V, layoutmsg, preselect d"
          "$mod SHIFT, P, pseudo,"
          "$mod SHIFT, T, togglegroup,"
          "$mod SHIFT, H, togglesplit,"

          # Scratchpad (special workspace)
          "$mod, U, togglespecialworkspace, scratchpad"
          "$mod SHIFT, U, movetoworkspacesilent, special:scratchpad"

          # Screenshot
          ", Print, exec, grimblast --notify copy area"

          # Volume (wpctl for pipewire)
          ", XF86AudioLowerVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-"
          ", XF86AudioRaiseVolume, exec, wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+"
          ", XF86AudioMute, exec, wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle"
          "$mod, M, exec, wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle"

          # Brightness
          ", XF86MonBrightnessUp, exec, brightnessctl set +5%"
          ", XF86MonBrightnessDown, exec, brightnessctl set 5%-"

          # Keyboard layout switching (explicit, matching i3)
          "$mod, X, exec, hyprctl switchxkblayout all 0"
          "$mod SHIFT, X, exec, hyprctl switchxkblayout all 1"

          # Lock screen
          "$mod SHIFT, L, exec, hyprlock"

          # Program shortcuts (MOD3 = AltGr in NEO layout, matching i3)
          "$mod MOD3, colon, exec, librewolf"
          "$mod MOD3, Delete, exec, rofi-choose-container"
          "$mod MOD3, KP_Separator, exec, dropbox"
          "$mod MOD3, KP_9, exec, spacefm"
          "$mod MOD3, KP_8, exec, pidgin"
          "$mod MOD3, KP_1, exec, thunderbird"
          "$mod MOD3, KP_4, exec, nmcli_dmenu"
          "$mod MOD3, KP_6, exec, steam"
          "$mod MOD3, BackSpace, exec, VirtualBox"
          "$mod MOD3, questiondown, exec, signal-desktop"
          "$mod MOD3, exclamdown, exec, ~/local/bin/kxo"
          "$mod MOD3 SHIFT, exclamdown, exec, ~/local/bin/kd"
          "$mod MOD3, End, exec, spotify-blockify"
          "$mod MOD3, period, exec, skype"
          "$mod MOD3, KP_5, exec, ~/local/bin/RuneScape"
          "$mod MOD3, Left, exec, idea-community"

          # Submaps (modes, matching i3)
          "$mod SHIFT, E, submap, exit"
          "$mod SHIFT, M, submap, screen"
          "$mod SHIFT, W, submap, work"
          "$mod SHIFT, F, submap, refocus"
          "$mod SHIFT, D, submap, redesign"
          "$mod SHIFT, R, submap, resize"

          # Workspaces 1-10
          "$mod, 1, workspace, 1"
          "$mod, 2, workspace, 2"
          "$mod, 3, workspace, 3"
          "$mod, 4, workspace, 4"
          "$mod, 5, workspace, 5"
          "$mod, 6, workspace, 6"
          "$mod, 7, workspace, 7"
          "$mod, 8, workspace, 8"
          "$mod, 9, workspace, 9"
          "$mod, 0, workspace, 10"

          # Move to workspace 1-10
          "$mod SHIFT, 1, movetoworkspace, 1"
          "$mod SHIFT, 2, movetoworkspace, 2"
          "$mod SHIFT, 3, movetoworkspace, 3"
          "$mod SHIFT, 4, movetoworkspace, 4"
          "$mod SHIFT, 5, movetoworkspace, 5"
          "$mod SHIFT, 6, movetoworkspace, 6"
          "$mod SHIFT, 7, movetoworkspace, 7"
          "$mod SHIFT, 8, movetoworkspace, 8"
          "$mod SHIFT, 9, movetoworkspace, 9"
          "$mod SHIFT, 0, movetoworkspace, 10"

          # Second monitor workspaces (F1-F9 → 11-19)
          "$mod, F1, workspace, 11"
          "$mod, F2, workspace, 12"
          "$mod, F3, workspace, 13"
          "$mod, F4, workspace, 14"
          "$mod, F5, workspace, 15"
          "$mod, F6, workspace, 16"
          "$mod, F7, workspace, 17"
          "$mod, F8, workspace, 18"
          "$mod, F9, workspace, 19"
          "$mod SHIFT, F1, movetoworkspace, 11"
          "$mod SHIFT, F2, movetoworkspace, 12"
          "$mod SHIFT, F3, movetoworkspace, 13"
          "$mod SHIFT, F4, movetoworkspace, 14"
          "$mod SHIFT, F5, movetoworkspace, 15"
          "$mod SHIFT, F6, movetoworkspace, 16"
          "$mod SHIFT, F7, movetoworkspace, 17"
          "$mod SHIFT, F8, movetoworkspace, 18"
          "$mod SHIFT, F9, movetoworkspace, 19"
        ];

        # Mouse bindings
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];

        # Window rules (from i3 assigns)
        windowrule = [
          "match:class ^(thunderbird)$, workspace 1"
          "match:class ^(librewolf|firefox|Navigator)$, workspace 2"
          "match:class ^(KeePassXC)$, workspace 7"
          "match:class ^(Signal|signal)$, workspace 9"
        ];

        # Workspace → monitor binding (multi-monitor)
        workspace = lib.optionals (lib.length cfg.monitors > 1) (let
          m1 = (lib.head cfg.monitors).name;
          m2 = (lib.elemAt cfg.monitors 1).name;
        in
          (lib.genList (i: "${toString (i + 1)}, monitor:${m1}${lib.optionalString (i == 0) ", default:true"}") 10)
          ++ (lib.genList (i: "${toString (i + 11)}, monitor:${m2}${lib.optionalString (i == 0) ", default:true"}") 9));
      };

      # Submaps (matching i3 modes)
      extraConfig =
        ''
          source = ~/.config/my/theme/current/hyprland.conf

          # --- Exit submap (i3: $mod+Shift+E) ---
          submap = exit
          bind = SUPER, R, exec, systemctl reboot
          bind = SUPER, S, exec, systemctl suspend
          bind = SUPER, P, exec, systemctl poweroff
          bind = SUPER, E, exec, hyprctl dispatch exit
          bind = , R, exec, systemctl reboot
          bind = , S, exec, systemctl suspend
          bind = , P, exec, systemctl poweroff
          bind = , E, exec, hyprctl dispatch exit
          bind = , Return, submap, reset
          bind = , Escape, submap, reset
          submap = reset

          # --- Screen/DPMS submap (i3: $mod+Shift+M) ---
          submap = screen
          bind = , S, exec, hyprlock & sleep 1 && hyprctl dispatch dpms off
          bind = , P, exec, hyprlock & sleep 1 && systemctl suspend
          bind = , L, exec, hyprlock & sleep 1 && hyprctl dispatch dpms off
          bind = , O, exec, hyprctl dispatch dpms off
          bind = , K, exec, hyprctl dispatch dpms on
          bind = , R, exec, hyprctl dispatch dpms on
          bind = , Return, submap, reset
          bind = , Escape, submap, reset
          submap = reset

          # --- Work submap (i3: $mod+Shift+W) ---
          submap = work
          bind = , W, exec, hyprctl dispatch workspace 1 && thunderbird & librewolf & signal-desktop & sleep 0.5 && hyprctl dispatch workspace 3 && alacritty &
          bind = , S, movetoworkspacesilent, special:scratchpad
          bind = SHIFT, S, togglespecialworkspace, scratchpad
          bind = , Return, submap, reset
          bind = , Escape, submap, reset
          submap = reset

          # --- Refocus submap (i3: $mod+Shift+F) ---
          submap = refocus
          bind = MOD3, Left, movefocus, l
          bind = MOD3, Down, movefocus, d
          bind = MOD3, Up, movefocus, u
          bind = MOD3, Right, movefocus, r
          bind = SHIFT MOD3, Left, movewindow, l
          bind = SHIFT MOD3, Down, movewindow, d
          bind = SHIFT MOD3, Up, movewindow, u
          bind = SHIFT MOD3, Right, movewindow, r
          bind = , Return, submap, reset
          bind = , Escape, submap, reset
          bind = , Q, submap, reset
          submap = reset

          # --- Redesign submap (i3: $mod+Shift+D) ---
          submap = redesign
          bind = SUPER, N, exec, hyprctl keyword general:border_size 0
          bind = SUPER, Y, exec, hyprctl keyword general:border_size 1
          bind = SUPER, B, exec, hyprctl keyword general:border_size 3
          bind = , Return, submap, reset
          bind = , Escape, submap, reset
          bind = , Q, submap, reset
          submap = reset

          # --- Resize submap (i3: $mod+Shift+R) ---
          submap = resize
          binde = , N, resizeactive, -20 0
          binde = , T, resizeactive, 20 0
          binde = , G, resizeactive, 0 -20
          binde = , R, resizeactive, 0 20
          binde = , Left, resizeactive, -5 0
          binde = , Right, resizeactive, 5 0
          binde = , Up, resizeactive, 0 -5
          binde = , Down, resizeactive, 0 5
          bind = , Return, submap, reset
          bind = , Escape, submap, reset
          submap = reset
        ''
        + cfg.extraConfig;
    };
  };
}
