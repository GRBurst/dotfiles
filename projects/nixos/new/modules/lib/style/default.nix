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

  mkI3Theme = palette: ''
    set $theme_bg ${palette.primary.background}
    set $theme_fg ${palette.primary.foreground}
    set $theme_black ${palette.normal.black}
    set $theme_dim ${palette.bright.black}
    set $theme_blue ${palette.normal.blue}
    set $theme_red ${palette.normal.red}
    set $theme_green ${palette.normal.green}
    set $theme_magenta ${palette.normal.magenta}

    client.focused          $theme_blue  $theme_blue  $theme_bg $theme_magenta $theme_blue
    client.focused_inactive $theme_black $theme_black $theme_fg $theme_dim     $theme_black
    client.unfocused        $theme_black $theme_black $theme_dim $theme_dim     $theme_black
    client.urgent           $theme_red   $theme_red   $theme_bg $theme_red     $theme_red
    client.placeholder      $theme_bg    $theme_green $theme_fg $theme_bg      $theme_bg
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
