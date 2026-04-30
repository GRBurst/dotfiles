# Dynamic Theme Operations

This document describes the runtime path for the repo-managed light/dark theme system and the manual checks used to validate it in a graphical session.

## Source Of Truth

`darkman` is the runtime source of truth. The system does not switch Home Manager generations at sunrise, sunset, or manual mode changes. Home Manager builds both light and dark artifacts ahead of time, and `darkman` only asks the runtime dispatcher to activate one mode.

The dispatcher is `my-style-switch`. It accepts exactly one mode:

```sh
my-style-switch light
my-style-switch dark
```

Invalid modes fail without changing the runtime state.

## Runtime Flow

The live path is:

```text
darkman -> my-style-switch -> state file/current links -> reload/signals
```

Browsers and sites consume the portal-backed preference through:

```text
darkman -> xdg-desktop-portal Settings -> prefers-color-scheme -> browsers/sites
```

`darkman` passes the selected mode to `my-style-switch`. The dispatcher updates symlinks under the current theme directory, writes the shared mode state file, and then asks running applications to reload where they support it.

The state file is:

```text
~/.local/state/my-theme/mode
```

The current theme links live under:

```text
~/.config/my/theme/current/*
```

Examples:

```text
~/.config/my/theme/current/alacritty.toml
~/.config/my/theme/current/i3.conf
~/.config/my/theme/current/i3status-rust.toml
~/.config/my/theme/current/hyprland.conf
~/.config/my/theme/current/dunst.conf
~/.config/my/theme/current/rofi.rasi
~/.config/my/theme/current/waybar.css
```

Runtime scripts may update those links and the state file, then signal or reload consumers. They must not rewrite Nix-owned source configuration.

## Portal Validation

The XDG Settings portal is served by `darkman` for the appearance setting. Validate it from the same graphical user session that runs `darkman`:

```sh
gdbus call --session \
  --dest org.freedesktop.portal.Desktop \
  --object-path /org/freedesktop/portal/desktop \
  --method org.freedesktop.portal.Settings.ReadOne \
  org.freedesktop.appearance color-scheme
```

Expected values:

- dark: `1`
- light: `2`

The active portal service is owned by the NixOS layer in the Hyprland/UWSM setup. Home Manager still starts `darkman`, but its portal service/config is disabled there so the NixOS `xdg-desktop-portal` service is the source of active portal backend selection.

NixOS owns both sides of portal setup: it selects `darkman` as the Settings backend and includes `pkgs.darkman` in `xdg.portal.extraPortals` so `darkman.portal` is discoverable under:

```text
/run/current-system/sw/share/xdg-desktop-portal/portals
```

If the portal returns `0`, verify that `darkman.portal` exists under `/run/current-system/sw/share/xdg-desktop-portal/portals` and restart the user portal services or re-login.

For browser portal validation, test LibreWolf/Firefox, Chromium, and Brave from the same graphical session:

```js
window.matchMedia("(prefers-color-scheme: dark)").matches
```

Expected values:

- light mode: `false`
- dark mode: `true`

No browser-specific flags such as `--force-dark-mode` are part of the managed configuration. A forced GTK theme can be used as a legacy fallback only if live validation proves a specific application does not follow the portal.

## App Matrix

Alacritty imports `~/.config/my/theme/current/alacritty.toml`. The dispatcher updates the current link and runs `alacritty msg config` so running windows can reload the import.

i3 includes `~/.config/my/theme/current/i3.conf`. The generated theme file owns literal client colors and the dynamic `bar { ... }` block. The dispatcher updates the current link and runs `i3-msg reload`.

i3status-rust reads a generated theme TOML through the current i3status-rust link. i3 reload restarts the bar path that consumes it.

Hyprland sources `~/.config/my/theme/current/hyprland.conf`. The dispatcher updates the current link and runs `hyprctl reload`.

Dunst is started only by the i3 and Hyprland session startup paths with `dunst -config ~/.config/my/theme/current/dunst.conf`. The dispatcher updates the current dunst link and runs `dunstctl reload ~/.config/my/theme/current/dunst.conf`.

Waybar imports CSS from `../my/theme/current/waybar.css`. The dispatcher updates the current link and sends `SIGUSR2` to Waybar.

Rofi reads `~/.config/my/theme/current/rofi.rasi` on each invocation. The dispatcher switches the current rofi theme link; no signal is needed.

Kitty uses native auto-theme files:

```text
~/.config/kitty/light-theme.auto.conf
~/.config/kitty/dark-theme.auto.conf
~/.config/kitty/no-preference-theme.auto.conf
```

Kitty follows the OS light/dark preference through its native mechanism rather than the current-link dispatcher path.

Neovim reads `~/.local/state/my-theme/mode` at startup and when it receives `SIGUSR1`. The dispatcher sends `SIGUSR1` to running `nvim` processes.

Yazi uses native light/dark flavors:

```text
enfocado-light
enfocado-dark
```

New or refreshed Yazi instances follow the OS light/dark mode through Home Manager's Yazi theme mapping.

GNOME is a consumer and fallback desktop layer. The dispatcher mirrors the selected mode to `org.gnome.desktop.interface color-scheme`.

GNOME must not start dunst. Dunst is intentionally not enabled through Home Manager's `services.dunst` option or D-Bus activation, so notification ownership stays scoped to i3 and Hyprland sessions.

Redshift is independent. It shares location and timing assumptions with `darkman`, but it is not part of the theme switching path.

Ghostty and VSCode are disabled adapter stubs. They are intentionally future work and should not be treated as active consumers.

## Manual Runtime Validation

First validate `pallon@andromeda` from the real graphical session:

```sh
darkman set light
darkman get
cat ~/.local/state/my-theme/mode
readlink ~/.config/my/theme/current/alacritty.toml
readlink ~/.config/my/theme/current/dunst.conf
readlink ~/.config/my/theme/current/rofi.rasi

gdbus call --session \
  --dest org.freedesktop.portal.Desktop \
  --object-path /org/freedesktop/portal/desktop \
  --method org.freedesktop.portal.Settings.ReadOne \
  org.freedesktop.appearance color-scheme

darkman set dark
darkman get
cat ~/.local/state/my-theme/mode
readlink ~/.config/my/theme/current/alacritty.toml
readlink ~/.config/my/theme/current/dunst.conf
readlink ~/.config/my/theme/current/rofi.rasi

gdbus call --session \
  --dest org.freedesktop.portal.Desktop \
  --object-path /org/freedesktop/portal/desktop \
  --method org.freedesktop.portal.Settings.ReadOne \
  org.freedesktop.appearance color-scheme
```

Expected results:

- `darkman get` returns `light` after `darkman set light`.
- `~/.local/state/my-theme/mode` contains `light`.
- The portal `org.freedesktop.appearance color-scheme` value is `2`.
- The Alacritty current link points at `enfocado_light.toml`.
- The Dunst current link points at `light.conf`.
- The Rofi current link points at `light.rasi`.
- `darkman get` returns `dark` after `darkman set dark`.
- `~/.local/state/my-theme/mode` contains `dark`.
- The portal `org.freedesktop.appearance color-scheme` value is `1`.
- The Alacritty current link points at `enfocado_dark.toml`.
- The Dunst current link points at `dark.conf`.
- The Rofi current link points at `dark.rasi`.

Also check the visible consumers in the same session:

- Alacritty changes or reloads config after the mode switch.
- LibreWolf/Firefox, Chromium, and Brave update `matchMedia("(prefers-color-scheme: dark)")` from `false` in light mode to `true` in dark mode, preferably without browser restart.
- i3 reloads and i3bar colors update.
- Hyprland reloads without error.
- Dunst starts in i3 and Hyprland, `notify-send "dunst" "theme test"` displays a notification, and `dunstctl reload ~/.config/my/theme/current/dunst.conf` succeeds.
- Waybar updates after `SIGUSR2`, or any limitation is recorded in the plan.
- Kitty follows OS light/dark mode.
- A running Neovim instance switches after `SIGUSR1`.
- GNOME `color-scheme` follows the selected mode.
- GNOME does not autostart dunst; before sending a notification, `pgrep -u "$USER" dunst` is empty in a GNOME session.
- Yazi uses the light or dark flavor in a new or refreshed instance.
- Rofi opens in light mode after `darkman set light` and in dark mode after `darkman set dark`.

`jelias@earth` should be validated with the same checks when a live session is available.
