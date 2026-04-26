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
  };

  config = lib.mkIf cfg.enable {
    wayland.windowManager.hyprland = {
      enable = true;
      systemd.enable = true;
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
          "col.active_border" = "rgba(00ccffee) rgba(ff99ffee) 45deg";
          "col.inactive_border" = "rgba(333333aa)";
        };

        dwindle = {
          pseudotile = true;
          preserve_split = true;
        };

        misc = {
          force_default_wallpaper = 0;
        };

        decoration = {
          rounding = 4;
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
            "WLR_NO_HARDWARE_CURSORS,1"
            "NVD_BACKEND,direct"
          ];

        # --- Autostart ---
        exec-once = [
          "waybar"
          "hyprpaper"
          "nm-applet --indicator"
          "${pkgs.polkit_gnome}/libexec/polkit-gnome-authentication-agent-1"
          "gnome-keyring-daemon --start --components=pkcs11,secrets,ssh"
          "hypridle"
        ];

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
          "$mod, H, layoutmsg, preselect l"
          "$mod, V, layoutmsg, preselect d"
          "$mod, P, pseudo,"

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

          # Keyboard layout toggle
          "$mod, X, exec, hyprctl switchxkblayout all next"

          # Lock screen
          "$mod SHIFT, L, exec, hyprlock"

          # Browser (colon key position)
          "$mod, code:51, exec, librewolf"

          # Exit / logout menu
          "$mod SHIFT, E, exec, wlogout"

          # Enter resize submap
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
        windowrulev2 = [
          "workspace 1, class:^(thunderbird)$"
          "workspace 2, class:^(librewolf|firefox|Navigator)$"
          "workspace 7, class:^(KeePassXC)$"
          "workspace 9, class:^(Signal|signal)$"
        ];

        # Workspace → monitor binding (multi-monitor)
        workspace = lib.optionals (lib.length cfg.monitors > 1) (let
          m1 = (lib.head cfg.monitors).name;
          m2 = (lib.elemAt cfg.monitors 1).name;
        in
          (lib.genList (i: "${toString (i + 1)}, monitor:${m1}${lib.optionalString (i == 0) ", default:true"}") 10)
          ++ (lib.genList (i: "${toString (i + 11)}, monitor:${m2}${lib.optionalString (i == 0) ", default:true"}") 9));
      };

      # Submaps (resize mode — equivalent of i3 resize mode)
      extraConfig =
        ''
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
