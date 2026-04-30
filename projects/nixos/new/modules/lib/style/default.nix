{lib}: let
  stripHash = color: lib.removePrefix "#" color;
in {
  palettes.enfocado = import ./enfocado.nix;

  inherit stripHash;

  toBase16 = palette: {
    base00 = stripHash palette.primary.background;
    base01 = stripHash palette.normal.black;
    base02 = stripHash palette.bright.black;
    base03 = stripHash palette.bright.black;
    base04 = stripHash palette.normal.white;
    base05 = stripHash palette.primary.foreground;
    base06 = stripHash palette.bright.white;
    base07 = stripHash palette.bright.white;
    base08 = stripHash palette.normal.red;
    base09 = stripHash palette.bright.red;
    base0A = stripHash palette.normal.yellow;
    base0B = stripHash palette.normal.green;
    base0C = stripHash palette.normal.cyan;
    base0D = stripHash palette.normal.blue;
    base0E = stripHash palette.normal.magenta;
    base0F = stripHash palette.bright.magenta;
  };

  mkAlacrittyTheme = palette: ''
    [colors.primary]
    background = "${palette.primary.background}"
    foreground = "${palette.primary.foreground}"

    [colors.normal]
    black = "${palette.normal.black}"
    red = "${palette.normal.red}"
    green = "${palette.normal.green}"
    yellow = "${palette.normal.yellow}"
    blue = "${palette.normal.blue}"
    magenta = "${palette.normal.magenta}"
    cyan = "${palette.normal.cyan}"
    white = "${palette.normal.white}"

    [colors.bright]
    black = "${palette.bright.black}"
    red = "${palette.bright.red}"
    green = "${palette.bright.green}"
    yellow = "${palette.bright.yellow}"
    blue = "${palette.bright.blue}"
    magenta = "${palette.bright.magenta}"
    cyan = "${palette.bright.cyan}"
    white = "${palette.bright.white}"
  '';

  mkKittyTheme = palette: ''
    background ${palette.primary.background}
    foreground ${palette.primary.foreground}

    color0 ${palette.normal.black}
    color1 ${palette.normal.red}
    color2 ${palette.normal.green}
    color3 ${palette.normal.yellow}
    color4 ${palette.normal.blue}
    color5 ${palette.normal.magenta}
    color6 ${palette.normal.cyan}
    color7 ${palette.normal.white}

    color8 ${palette.bright.black}
    color9 ${palette.bright.red}
    color10 ${palette.bright.green}
    color11 ${palette.bright.yellow}
    color12 ${palette.bright.blue}
    color13 ${palette.bright.magenta}
    color14 ${palette.bright.cyan}
    color15 ${palette.bright.white}
  '';

  mkRofiTheme = palette: ''
    * {
      background: ${palette.primary.background};
      foreground: ${palette.primary.foreground};
      accent: ${palette.normal.blue};
      muted: ${palette.bright.black};
      urgent: ${palette.normal.red};

      background-color: @background;
      text-color: @foreground;
      border-color: @accent;
    }

    window {
      background-color: @background;
      border: 2px;
      border-color: @accent;
      padding: 8px;
    }

    mainbox {
      background-color: @background;
    }

    inputbar {
      background-color: @background;
      text-color: @foreground;
      padding: 6px;
    }

    prompt, entry {
      text-color: @foreground;
    }

    listview {
      background-color: @background;
      lines: 8;
    }

    element {
      background-color: @background;
      text-color: @foreground;
      padding: 4px 6px;
    }

    element selected {
      background-color: @accent;
      text-color: @background;
    }

    element urgent {
      background-color: @urgent;
      text-color: @background;
    }

    mode-switcher {
      background-color: @background;
    }

    button selected {
      background-color: @accent;
      text-color: @background;
    }
  '';

  mkYaziFlavor = palette: ''
    [mgr]
    cwd = { fg = "${palette.normal.blue}" }
    hovered = { fg = "${palette.primary.background}", bg = "${palette.normal.blue}" }
    preview_hovered = { fg = "${palette.primary.background}", bg = "${palette.normal.blue}" }

    [status]
    overall = { fg = "${palette.primary.foreground}", bg = "${palette.primary.background}" }

    [mode]
    normal_main = { fg = "${palette.primary.background}", bg = "${palette.normal.blue}" }
    select_main = { fg = "${palette.primary.background}", bg = "${palette.normal.magenta}" }
    unset_main = { fg = "${palette.primary.background}", bg = "${palette.normal.red}" }

    [filetype]
    rules = [
      { mime = "image/*", fg = "${palette.normal.yellow}" },
      { mime = "{audio,video}/*", fg = "${palette.normal.magenta}" },
      { mime = "application/{zip,rar,7z*,tar,gzip,xz}", fg = "${palette.normal.red}" },
      { url = "*/", fg = "${palette.normal.blue}" },
    ]
  '';

  mkI3StatusTheme = palette: ''
    idle_bg = "${palette.primary.background}"
    idle_fg = "${palette.primary.foreground}"
    info_bg = "${palette.primary.background}"
    info_fg = "${palette.normal.blue}"
    good_bg = "${palette.primary.background}"
    good_fg = "${palette.normal.green}"
    warning_bg = "${palette.primary.background}"
    warning_fg = "${palette.normal.yellow}"
    critical_bg = "${palette.primary.background}"
    critical_fg = "${palette.normal.red}"
    separator = ""
    separator_bg = "${palette.primary.background}"
    separator_fg = "${palette.bright.black}"
    alternating_tint_bg = "#00000000"
    alternating_tint_fg = "#00000000"
  '';

  mkDunstConfig = palette: fontCfg: ''
    [global]
        monitor = 0
        follow = keyboard
        origin = top-right
        offset = 12x42
        width = 420
        height = 300
        notification_limit = 5
        corner_radius = 4
        frame_width = 2
        separator_height = 2
        padding = 10
        horizontal_padding = 12
        gap_size = 6
        font = "${fontCfg.families.sansSerif.name} ${toString fontCfg.sizes.notification.body}"
        markup = full
        format = "<b>%s</b>\n%b"
        icon_position = left
        max_icon_size = 48
        frame_color = "${palette.normal.blue}"
        separator_color = frame

    [urgency_low]
        background = "${palette.primary.background}"
        foreground = "${palette.bright.black}"
        timeout = 5

    [urgency_normal]
        background = "${palette.primary.background}"
        foreground = "${palette.primary.foreground}"
        timeout = 8

    [urgency_critical]
        background = "${palette.primary.background}"
        foreground = "${palette.normal.red}"
        frame_color = "${palette.normal.red}"
        timeout = 0
  '';

  mkI3Theme = palette: ''
    client.focused          ${palette.normal.blue}  ${palette.normal.blue}  ${palette.primary.background} ${palette.normal.magenta} ${palette.normal.blue}
    client.focused_inactive ${palette.normal.black} ${palette.normal.black} ${palette.primary.foreground} ${palette.bright.black}    ${palette.normal.black}
    client.unfocused        ${palette.normal.black} ${palette.normal.black} ${palette.bright.black}       ${palette.bright.black}    ${palette.normal.black}
    client.urgent           ${palette.normal.red}   ${palette.normal.red}   ${palette.primary.background} ${palette.normal.red}      ${palette.normal.red}
    client.placeholder      ${palette.primary.background} ${palette.normal.green} ${palette.primary.foreground} ${palette.primary.background} ${palette.primary.background}
  '';

  mkWaybarCss = palette: fontFamily: ''
    * {
      font-family: "${fontFamily}", monospace;
      font-size: 13px;
    }

    window#waybar {
      background-color: ${palette.primary.background};
      color: ${palette.primary.foreground};
    }

    #workspaces button {
      padding: 0 5px;
      color: ${palette.primary.foreground};
      border-bottom: 2px solid transparent;
    }

    #workspaces button.active {
      color: ${palette.normal.blue};
      border-bottom: 2px solid ${palette.normal.blue};
    }

    #clock, #pulseaudio, #network, #cpu, #memory, #battery, #tray {
      padding: 0 8px;
    }
  '';

  mkHyprlandTheme = palette: ''
    general {
      col.active_border = rgba(${stripHash palette.normal.blue}ee) rgba(${stripHash palette.normal.magenta}ee) 45deg
      col.inactive_border = rgba(${stripHash palette.normal.black}aa)
    }
  '';
}
