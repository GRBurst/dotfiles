{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.hm.features.gnome;
in {
  options.my.hm.features.gnome = {
    enable = lib.mkEnableOption "GNOME keybinding alignment with i3";
  };

  config = lib.mkIf cfg.enable {
    dconf.settings = {
      # --- Workspace behavior (static, matching i3) ---
      "org/gnome/mutter" = {
        dynamic-workspaces = false;
        workspaces-only-on-primary = false;
      };

      "org/gnome/desktop/wm/preferences" = {
        num-workspaces = 9;
      };

      # --- Window manager keybindings (align with i3) ---
      "org/gnome/desktop/wm/keybindings" = {
        close = ["<Super><Shift>q"];
        toggle-fullscreen = ["<Super>f"];
        toggle-maximized = ["<Super><Shift>f"];
        minimize = ["disabled"];

        # Workspace switching: Super+1..9
        switch-to-workspace-1 = ["<Super>1"];
        switch-to-workspace-2 = ["<Super>2"];
        switch-to-workspace-3 = ["<Super>3"];
        switch-to-workspace-4 = ["<Super>4"];
        switch-to-workspace-5 = ["<Super>5"];
        switch-to-workspace-6 = ["<Super>6"];
        switch-to-workspace-7 = ["<Super>7"];
        switch-to-workspace-8 = ["<Super>8"];
        switch-to-workspace-9 = ["<Super>9"];

        # Move window to workspace: Super+Shift+1..9
        move-to-workspace-1 = ["<Super><Shift>1"];
        move-to-workspace-2 = ["<Super><Shift>2"];
        move-to-workspace-3 = ["<Super><Shift>3"];
        move-to-workspace-4 = ["<Super><Shift>4"];
        move-to-workspace-5 = ["<Super><Shift>5"];
        move-to-workspace-6 = ["<Super><Shift>6"];
        move-to-workspace-7 = ["<Super><Shift>7"];
        move-to-workspace-8 = ["<Super><Shift>8"];
        move-to-workspace-9 = ["<Super><Shift>9"];

        # Disable conflicting GNOME defaults
        switch-applications = ["disabled"];
        switch-applications-backward = ["disabled"];
        switch-group = ["disabled"];
        switch-group-backward = ["disabled"];
      };

      # --- Shell keybindings: free Super+N from GNOME defaults ---
      "org/gnome/shell/keybindings" = {
        toggle-message-tray = ["disabled"];
        focus-active-notification = ["disabled"];
        switch-to-application-1 = ["disabled"];
        switch-to-application-2 = ["disabled"];
        switch-to-application-3 = ["disabled"];
        switch-to-application-4 = ["disabled"];
        switch-to-application-5 = ["disabled"];
        switch-to-application-6 = ["disabled"];
        switch-to-application-7 = ["disabled"];
        switch-to-application-8 = ["disabled"];
        switch-to-application-9 = ["disabled"];
      };

      # --- Custom keybindings (program launch, matching i3) ---
      "org/gnome/settings-daemon/plugins/media-keys" = {
        custom-keybindings = [
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2/"
          "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3/"
        ];
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
        name = "Terminal";
        command = "alacritty";
        binding = "<Super>Return";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom1" = {
        name = "Browser";
        command = "librewolf";
        binding = "<Super>colon";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom2" = {
        name = "Launcher";
        command = "rofi -show drun -show-icons";
        binding = "<Super>o";
      };

      "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom3" = {
        name = "Launcher Combi";
        command = "rofi -show combi";
        binding = "<Super><Shift>o";
      };
    };
  };
}
