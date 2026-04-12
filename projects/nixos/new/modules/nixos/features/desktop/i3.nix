{ config, lib, pkgs, ... }:
let cfg = config.my.nixos.features.desktop.i3;
in {
  options.my.nixos.features.desktop.i3.enable = lib.mkEnableOption "i3 Window Manager";

  config = lib.mkIf cfg.enable {
    services.xserver = {
      enable = true;
      videoDrivers = [ "modesetting" ];
      dpi = 192;

      
      xkb = {
        layout = "de,de";
        variant = "neo,basic";
        options = "grp:menu_toggle";
      };

      # i3 Configuration 
      windowManager.i3 = {
        enable = true;
        extraPackages = with pkgs; [
          feh
          rofi
          i3status-rust
          i3lock
          gnome-keyring
        ];
        extraSessionCommands = ''
          xsetroot -bg black
          xsetroot -cursor_name left_ptr
          gnome-keyring-daemon --start -d --components=pkcs11,secrets,ssh
          feh --bg-scale '/home/pallon/.config/i3/background0.jpg' '/home/pallon/.config/i3/background1.jpg' &
        '';
      };
      
      desktopManager.xterm.enable = false;
    };

    # Mouse hiding
    services.unclutter-xfixes.enable = true;

    # 2. Display Manager (SDDM) 
    services.displayManager = {
      defaultSession = "none+i3";
      sddm = {
        enable = true;
        wayland.enable = true;
      };
      autoLogin = {
        enable = false;
        user = "pallon";
      };
    };

    # 3. Desktop Theming & Qt
    qt = {
      enable = true;
      platformTheme = "gnome";
      style = "adwaita"; 
    };
    
    # 4. Screen Locking
    programs.i3lock.enable = true;
  };
}
