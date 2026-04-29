# Dynamic Theme Architecture TDD Plan

This document is the overall test-driven implementation plan for system-wide dynamic light/dark theming across the NixOS flake.

It is intentionally broad. Each milestone should be refined and implemented as a dedicated follow-up task.

## Motivation

Build one declarative light/dark theme architecture for both hosts and both users:

- `andromeda` / `pallon`
- `earth` / `jelias`

Goals:

- `darkman` is the runtime source of truth.
- Stylix remains opt-in and hidden behind a repo-level style API.
- Apps live-switch where possible.
- Runtime scripts only activate, signal, or reload; they must not rewrite Nix-owned configs.
- GNOME is fully supported as fallback desktop and GTK/libadwaita support layer.
- Existing tests stay; static assumptions are replaced only with stronger dynamic-theme invariants.

## Decisions Made

- Add public module: `my.nixos.features.style`.
- Treat Stylix as an implementation detail.
- Enforce `stylix.autoEnable = false`.
- Do not use Home Manager specialisations for automatic sunrise/sunset switching.
- Generate light/dark theme artifacts declaratively, then switch small runtime links/state with a dispatcher.
- Use `darkman` per user.
- Use XDG portal Settings provider: `darkman`.
- GNOME is a supported consumer, not the source of truth.
- Neovim live-switches via `SIGUSR1`, not polling.
- Kitty uses native auto-theme file names, generated from the repo palette.
- Alacritty stays the primary terminal and uses the same runtime theme import path.
- Enfocado light/dark is the canonical palette baseline.
- Yazi uses native light/dark flavors generated from the repo palette.
- Ghostty and VSCode get disabled architectural adapter stubs first; full config comes later.
- Redshift stays separate; it only shares location/timing assumptions with darkman.

## Current Implementation Status

Status: dynamic Enfocado implementation, runtime dispatcher checks, and operations documentation are in place and evaluate successfully.

Implemented:

- Shared Enfocado palette helpers in `modules/lib/style/default.nix` and `modules/lib/style/enfocado.nix`.
- Public NixOS API `my.nixos.features.style` in `modules/nixos/features/style.nix`.
- Legacy `my.nixos.features.stylix` converted into a migration shim that enables `style` and keeps Stylix `autoEnable = false`.
- Home Manager API `my.hm.features.style` in `modules/home-manager/features/style/default.nix`.
- Per-user `darkman` with `portal = true`, manual host location, and a `my-style-switch` dispatcher.
- XDG Settings portal provider merged as `org.freedesktop.impl.portal.Settings = "darkman"` while preserving existing portal defaults.
- Generated Enfocado light/dark artifacts for Alacritty, i3, Hyprland, Waybar, Kitty, and Yazi.
- Runtime switching via state/link updates plus targeted reloads/signals, not whole Home Manager activation.
- Darkman's generic scripts receive the new mode as `$1`; the generated dispatcher forwards `"$@"` to `my-style-switch`.
- Alacritty imports `~/.config/my/theme/current/alacritty.toml`.
- i3 stays static and includes `~/.config/my/theme/current/i3.conf`; runtime only reloads i3. The parent i3 config does not consume variables from the include, because i3 expands variables before processing includes.
- Generated i3 theme files contain literal client colors and the full dynamic `bar { ... }` block, including literal workspace colors.
- i3status-rust references `~/.config/my/theme/current/i3status-rust.toml` through an absolute Home Manager config path and receives generated Enfocado light/dark/current TOML artifacts.
- Hyprland sources `~/.config/my/theme/current/hyprland.conf`.
- Waybar imports `../my/theme/current/waybar.css`.
- Kitty receives generated `light-theme.auto.conf`, `dark-theme.auto.conf`, and `no-preference-theme.auto.conf`.
- Yazi receives generated `enfocado-light` and `enfocado-dark` flavors through Home Manager `programs.yazi.flavors`, with `programs.yazi.theme.flavor` selecting by OS light/dark mode.
- Neovim uses a pinned `vim-enfocado` plugin and reads `~/.local/state/my-theme/mode` on startup and `SIGUSR1`.
- Both users enable `my.hm.features.style` and `my.hm.features.yazi`.
- Eval assertions cover style enablement, Stylix migration, darkman, portal merging, generated theme artifacts, i3 includes, i3status-rust theme files, Kitty auto files, Yazi flavors, and Neovim signal sync.
- Eval assertions run `my-style-switch` in a temporary `$HOME` and verify state/current-link switching for light, dark, and invalid modes.
- `docs/theme-architecture.md` documents operations, portal validation, the app matrix, and live-session validation commands.

Verified:

```sh
nix flake check --show-trace
```

Result: all checks pass with the dispatcher temp-home check and operations-doc check.

Pending live validation:

- `pallon@andromeda`: pending in a real graphical session using the commands in `docs/theme-architecture.md`.
- `jelias@earth`: pending until a live session is available.

Not implemented yet:

- Ghostty and VSCode adapters beyond disabled stubs.

## Divergences From Original Plan

- Home Manager specialisations were intentionally not implemented for automatic theme switching.
- Reason: specialisations are prebuilt activation packages, but switching them still activates a whole Home Manager configuration and can create/profile generations depending on activation path and Home Manager version. That is heavier than needed for frequent darkman-triggered sunrise/sunset changes.
- Replacement: the build creates both light and dark theme artifacts once; runtime switching only updates small links/state and signals/reloads consumers.
- The state path is `~/.local/state/my-theme/mode`, not `~/.local/state/nixos-theme/mode`.
- Reason: the implementation uses a shorter repo-owned runtime namespace and all adapters consistently read/write that path.
- Kitty does not use `programs.kitty.autoThemeFiles` with theme names from `kitty-themes`.
- Reason: Enfocado is not available in the pinned `kitty-themes` package. The implementation writes Kitty's native auto-theme files directly from the canonical Enfocado palette, preserving native Kitty behavior without changing palette source.
- i3status-rust does not use the earlier `slick`/`plain` built-in theme idea.
- Reason: Enfocado is the central palette, and i3status-rust has no built-in Enfocado theme. The implementation writes a custom TOML theme from `modules/lib/style/enfocado.nix`, switches `current/i3status-rust.toml`, and relies on the existing `i3-msg reload` to restart the bar.
- Neovim does not use `programs.nvf.settings.vim.theme.name = "enfocado"`.
- Reason: nvf's typed `theme.name` option only accepts its built-in theme enum. The implementation disables the built-in nvf theme and applies the pinned `vim-enfocado` plugin through Lua.
- Separate `theme-dispatch.sh` and `neovim-theme-sync.lua` files were not added.
- Reason: the dispatcher is produced with `pkgs.writeShellApplication`, and Neovim sync is injected directly via the existing `luaConfigRC.custom-functions` hook. This keeps the change smaller and avoids extra single-use files.
- Yazi flavors include only `flavor.toml`, not `tmtheme.xml`.
- Reason: this slice only needs Yazi's native UI theme keys and keeps the adapter minimal; syntax/file preview highlighting can be added later if a real use case appears.
- Live D-Bus, portal, and desktop-app behavior is not marked verified by `nix flake check`.
- Reason: the sandbox can prove the generated dispatcher updates state and links, but it cannot prove behavior in the user's graphical D-Bus session. `docs/theme-architecture.md` now records the manual validation commands; `pallon@andromeda` and `jelias@earth` remain explicit follow-ups until run in those sessions.

## First Step: Read Relevant Files

Do not edit first. The implementor must first read the relevant files.

Entry/root:

- `flake.nix`
- `flake.lock`
- `checks/eval-assertions.nix`
- `docs/i3-display-architecture-notes.md`

Hosts/users:

- `hosts/andromeda/default.nix`
- `hosts/earth/default.nix`
- `homes/pallon/default.nix`
- `homes/jelias/default.nix`

NixOS modules:

- `modules/nixos/default.nix`
- `modules/nixos/features/style.nix`
- `modules/nixos/features/stylix.nix`
- `modules/nixos/features/desktop/addons.nix`
- `modules/nixos/features/desktop/displayManager.nix`
- `modules/nixos/features/desktop/gnome.nix`
- `modules/nixos/features/desktop/hyprland.nix`
- `modules/nixos/features/desktop/i3.nix`
- `modules/nixos/features/desktop/xserver.nix`
- `modules/nixos/features/firefox.nix`

Home Manager modules:

- `modules/home-manager/default.nix`
- `modules/home-manager/features/style/default.nix`
- `modules/home-manager/features/misc.nix`
- `modules/home-manager/features/env.nix`
- `modules/home-manager/features/alacritty.nix`
- `modules/home-manager/features/gnome.nix`
- `modules/home-manager/features/hyprland.nix`
- `modules/home-manager/features/kitty.nix`
- `modules/home-manager/features/nvf.nix`
- `modules/home-manager/features/waybar.nix`
- `modules/home-manager/features/i3/default.nix`
- `modules/home-manager/features/i3/i3status-rust.nix`
- `modules/home-manager/features/zsh.nix`
- `modules/home-manager/bundles/extras.nix`
- `modules/home-manager/bundles/media.nix`

Shared style library:

- `modules/lib/style/default.nix`
- `modules/lib/style/enfocado.nix`

## Target Module Layout

Add:

```text
modules/lib/style/default.nix
modules/lib/style/enfocado.nix
modules/nixos/features/style.nix
modules/home-manager/features/style/default.nix
```

Still planned:

```text
docs/theme-architecture.md
```

Implementation note: `theme-dispatch.sh` and `neovim-theme-sync.lua` were planned as separate files, but the current implementation keeps them inline in Nix. The dispatcher is generated by `pkgs.writeShellApplication`; the Neovim sync code is injected through nvf Lua config.

Update:

```text
modules/nixos/default.nix
modules/nixos/features/stylix.nix
modules/home-manager/default.nix
modules/home-manager/features/alacritty.nix
modules/home-manager/features/hyprland.nix
modules/home-manager/features/i3/default.nix
modules/home-manager/features/kitty.nix
modules/home-manager/features/nvf.nix
modules/home-manager/features/waybar.nix
hosts/andromeda/default.nix
hosts/earth/default.nix
homes/pallon/default.nix
homes/jelias/default.nix
checks/eval-assertions.nix
```

## Core Data Model

Mode type:

```nix
modeType = lib.types.enum [ "dark" "light" ];
```

Base16 keys:

```nix
base16Keys = [
  "base00" "base01" "base02" "base03"
  "base04" "base05" "base06" "base07"
  "base08" "base09" "base0A" "base0B"
  "base0C" "base0D" "base0E" "base0F"
];
```

Hex color type:

```nix
hex6 = lib.types.addCheck lib.types.str
  (s: builtins.match "^[0-9a-fA-F]{6}$" s != null);
```

Scheme type:

```nix
schemeType = lib.types.submodule {
  options = lib.genAttrs base16Keys (_: lib.mkOption {
    type = hex6;
  });
};
```

Public system option shape:

```nix
options.my.nixos.features.style = {
  enable = lib.mkEnableOption "repo-level styling and theme system";

  defaultMode = lib.mkOption {
    type = modeType;
    default = "dark";
  };

  schemes.dark = lib.mkOption { type = schemeType; };
  schemes.light = lib.mkOption { type = schemeType; };

  targets = {
    console.enable = lib.mkEnableOption "console styling";
    gtk.enable = lib.mkEnableOption "GTK/GNOME adapter";
    i3.enable = lib.mkEnableOption "i3 styling";
    alacritty.enable = lib.mkEnableOption "Alacritty styling";
    kitty.enable = lib.mkEnableOption "Kitty styling";
    neovim.enable = lib.mkEnableOption "Neovim live styling";
    yazi.enable = lib.mkEnableOption "Yazi styling adapter";
    ghostty.enable = lib.mkEnableOption "Ghostty styling adapter";
    vscode.enable = lib.mkEnableOption "VSCode styling adapter";
  };
};
```

Implemented system option shape:

```nix
options.my.nixos.features.style = {
  enable = lib.mkEnableOption "repo-level styling and theme system";
  palette = lib.mkOption {
    type = lib.types.enum [ "enfocado" ];
    default = "enfocado";
  };
  defaultMode = lib.mkOption {
    type = lib.types.enum [ "light" "dark" ];
    default = "light";
  };
  stylixMigration.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };
};
```

Reason for divergence: the first implementation only needs one canonical palette family, Enfocado. The public API therefore exposes `palette = "enfocado"` instead of accepting arbitrary Base16 schemes. This keeps the initial API smaller while preserving the option to add more palette families later.

Home Manager option shape:

```nix
options.my.hm.features.style = {
  enable = lib.mkEnableOption "user theme runtime";

  mode = lib.mkOption {
    type = modeType;
    default = osConfig.my.nixos.features.style.defaultMode;
  };

  stateFile = lib.mkOption {
    type = lib.types.str;
    default = "\${XDG_STATE_HOME:-$HOME/.local/state}/my-theme/mode";
  };

  gnome.mirror.enable = lib.mkEnableOption "mirror darkman mode into GNOME gsettings";
  gnome.legacyGtkTheme.enable = lib.mkEnableOption "also set gtk-theme Adwaita/Adwaita-dark";
};
```

Implemented Home Manager option shape:

```nix
options.my.hm.features.style = {
  enable = lib.mkEnableOption "dynamic user style";
  palette = lib.mkOption {
    type = lib.types.enum [ "enfocado" ];
    default = "enfocado";
  };
  defaultMode = lib.mkOption {
    type = lib.types.enum [ "light" "dark" ];
    default = "light";
  };
  darkman.enable = lib.mkOption {
    type = lib.types.bool;
    default = true;
  };
  adapters = {
    alacritty.enable = ...;
    i3.enable = ...;
    hyprland.enable = ...;
    waybar.enable = ...;
    nvf.enable = ...;
    kitty.enable = ...;
    gnome.enable = ...;
  };
};
```

Reason for divergence: mode is now runtime state, not a Home Manager configuration value. `defaultMode` only chooses the initial declarative fallback artifacts.

## Milestone 0: Baseline

Purpose: prove current repo is healthy before changing behavior.

Actions:

- Read all files listed above.
- Run existing checks.
- Record current expected invariants:
- i3 config is static.
- i3 syntax passes.
- autorandr reloads i3 only.
- nvf used gruvbox before implementation; current implementation uses Enfocado through a pinned plugin.
- i3status uses a generated Enfocado theme through `my/theme/current/i3status-rust.toml`.
- Stylix `autoEnable = false`.

Type-check point:

```sh
nix flake check --show-trace
```

No code changes yet.

## Milestone 1: Public Style Module And Stylix Validation

Purpose: create the public API and hide direct custom Stylix usage.

### Tests First

Add failing eval assertions:

```nix
{
  name = "style-enabled-on-both-hosts";
  condition =
    andromeda.config.my.nixos.features.style.enable
    && earth.config.my.nixos.features.style.enable;
}

{
  name = "stylix-auto-enable-disabled";
  condition =
    andromeda.config.stylix.autoEnable == false
    && earth.config.stylix.autoEnable == false;
}

{
  name = "style-has-two-complete-palettes";
  condition =
    hasBase16 andromeda.config.my.nixos.features.style.schemes.dark
    && hasBase16 andromeda.config.my.nixos.features.style.schemes.light;
}
```

Expected result: fail because `style` module does not exist.

### Implementation

- Add `modules/nixos/features/style.nix`.
- Import it from `modules/nixos/default.nix`.
- Move public host usage from `my.nixos.features.stylix.enable = true;` to `my.nixos.features.style.enable = true;`.
- Convert `modules/nixos/features/stylix.nix` into either an internal implementation helper or deprecated compatibility shim.

Validation:

```nix
assertions = [
  {
    assertion = !cfg.enable || config.stylix.autoEnable == false;
    message = "my.nixos.features.style requires stylix.autoEnable=false; enable style targets explicitly.";
  }
];

warnings = lib.optionals config.my.nixos.features.stylix.enable [
  "my.nixos.features.stylix.enable is deprecated; use my.nixos.features.style.enable."
];
```

Type-check after implementation:

```sh
nix flake check --show-trace
```

## Milestone 2: Home Manager Runtime Foundation

Purpose: add per-user darkman, portal, mode state, and dispatcher.

### Tests First

Add failing assertions for both users:

```nix
{
  name = "darkman-enabled-for-both-users";
  condition =
    andromedaHm.services.darkman.enable
    && earthHm.services.darkman.enable;
}

{
  name = "darkman-portal-enabled";
  condition =
    andromedaHm.services.darkman.settings.portal == true
    && earthHm.services.darkman.settings.portal == true;
}

{
  name = "portal-settings-provider-is-darkman";
  condition =
    andromedaHm.xdg.portal.config.common."org.freedesktop.impl.portal.Settings" == "darkman"
    && earthHm.xdg.portal.config.common."org.freedesktop.impl.portal.Settings" == "darkman";
}
```

Expected result: fail.

### Implementation

Add `modules/home-manager/features/style/default.nix`.

Runtime config shape:

```nix
services.darkman = {
  enable = true;
  settings = {
    lat = osConfig.location.latitude;
    lng = osConfig.location.longitude;
    usegeoclue = false;
    portal = true;
  };

  scripts."theme-dispatch" = builtins.readFile ./theme-dispatch.sh;
};
```

Portal:

```nix
xdg.portal = {
  enable = true;
  config.common = {
    default = lib.mkDefault "*";
    "org.freedesktop.impl.portal.Settings" = "darkman";
  };
};
```

Darkman dispatcher algorithm:

```sh
mode="$1"

case "$mode" in
  dark|light) ;;
  *) exit 64 ;;
esac

state_dir="${XDG_STATE_HOME:-$HOME/.local/state}/my-theme"
state_file="$state_dir/mode"

mkdir -p "$state_dir"
printf '%s\n' "$mode" > "$state_file"

# GNOME mirror.
if command -v gsettings >/dev/null 2>&1; then
  case "$mode" in
    dark)  gsettings set org.gnome.desktop.interface color-scheme prefer-dark ;;
    light) gsettings set org.gnome.desktop.interface color-scheme prefer-light ;;
  esac
fi

# Switch generated theme links/state only.
# Do not activate a Home Manager specialisation here.

# Reload or signal consumers.
pkill -USR1 -u "$USER" nvim || true
i3-msg reload >/dev/null 2>&1 || true
hyprctl reload >/dev/null 2>&1 || true
```

Implemented dispatcher detail:

- writes `~/.local/state/my-theme/mode`
- switches links under `~/.config/my/theme/current/`
- calls `alacritty msg config -w -1 ...`
- reloads i3 and Hyprland
- signals Waybar and Neovim
- mirrors GNOME `color-scheme`
- does not run Home Manager activation

Type-check:

```sh
nix flake check --show-trace
```

Manual validation later:

```sh
darkman set dark
darkman set light
gdbus call --session --dest org.freedesktop.portal.Desktop \
  --object-path /org/freedesktop/portal/desktop \
  --method org.freedesktop.portal.Settings.ReadOne \
  org.freedesktop.appearance color-scheme
```

## Milestone 3: GNOME Fallback And Session Support

Purpose: GNOME is not primary, but must fully follow the global mode.

### Tests First

Add assertions:

```nix
{
  name = "gnome-mirror-enabled";
  condition =
    andromedaHm.my.hm.features.style.gnome.mirror.enable
    && earthHm.my.hm.features.style.gnome.mirror.enable;
}

{
  name = "gnome-services-still-enabled";
  condition =
    earth.config.services.desktopManager.gnome.enable
    || earth.config.services.gnome.gnome-settings-daemon.enable;
}
```

### Implementation

- Keep GNOME as consumer.
- Do not make GNOME Settings authoritative.
- Dispatcher mirrors darkman mode into GSettings.
- Optional legacy GTK theme toggle remains opt-in.

Legacy GTK theme toggle:

```sh
if [ "${STYLE_SET_LEGACY_GTK_THEME:-0}" = "1" ]; then
  case "$mode" in
    dark)  gsettings set org.gnome.desktop.interface gtk-theme Adwaita-dark ;;
    light) gsettings set org.gnome.desktop.interface gtk-theme Adwaita ;;
  esac
fi
```

Type-check:

```sh
nix flake check --show-trace
```

## Milestone 4: Neovim Live Switching Via SIGUSR1

Purpose: all running Neovim instances switch without polling.

### Tests First

Update nvf checks.

Old invariant:

```nix
theme.name == "gruvbox"
theme.style == "dark"
```

New invariant:

```nix
{
  name = "nvf-live-theme-sync";
  condition =
    contains "Signal" nvfConfig
    && contains "SIGUSR1" nvfConfig
    && contains "my-theme/mode" nvfConfig
    && contains "vim.o.background" nvfConfig
    && contains "colorscheme" nvfConfig
    && contains "enfocado" nvfConfig;
}
```

Implementation note: the original gruvbox fallback was replaced with Enfocado to match the chosen terminal palette baseline.

### Implementation

Add generated Lua:

```lua
local M = {}

local function state_file()
  local xdg = os.getenv("XDG_STATE_HOME")
  local home = os.getenv("HOME")
  if xdg and xdg ~= "" then
    return xdg .. "/my-theme/mode"
  end
  return home .. "/.local/state/my-theme/mode"
end

local themes = {
  dark = {
    background = "dark",
    colorscheme = "enfocado",
  },
  light = {
    background = "light",
    colorscheme = "enfocado",
  },
}

local function read_mode()
  local f = io.open(state_file(), "r")
  if not f then return "dark" end
  local mode = f:read("*l")
  f:close()
  if mode == "dark" or mode == "light" then
    return mode
  end
  return "dark"
end

local function apply_mode(mode)
  local spec = themes[mode] or themes.dark
  vim.o.background = spec.background
  pcall(vim.cmd.colorscheme, spec.colorscheme)
  vim.schedule(function()
    vim.cmd("redraw!")
  end)
end

function M.setup()
  local group = vim.api.nvim_create_augroup("NixosThemeSync", { clear = true })

  vim.api.nvim_create_autocmd("Signal", {
    group = group,
    pattern = "SIGUSR1",
    nested = true,
    callback = function()
      apply_mode(read_mode())
    end,
  })

  apply_mode(read_mode())
end

return M
```

Wire through nvf using the appropriate nvf Lua injection option.

Implemented note: nvf does not allow `theme.name = "enfocado"` because that option is an enum of built-in themes. The implemented adapter disables the built-in nvf theme, packages `vim-enfocado` with `pkgs.vimUtils.buildVimPlugin`, and applies Enfocado from Lua.

Type-check:

```sh
nix flake check --show-trace
```

Manual validation later:

```sh
nvim
darkman set light
darkman set dark
```

Expected result: running Neovim changes background/colorscheme.

## Milestone 5: Native App Adapters

Purpose: prefer native dual-theme support and small generated theme files before heavier activation mechanisms.

### Kitty Now

Tests first:

```nix
{
  name = "kitty-auto-theme-files";
  condition =
    contains "background #181818" andromedaFiles."kitty/dark-theme.auto.conf".text
    && contains "background #ffffff" andromedaFiles."kitty/light-theme.auto.conf".text
    && contains "background #181818" earthFiles."kitty/dark-theme.auto.conf".text
    && contains "background #ffffff" earthFiles."kitty/light-theme.auto.conf".text;
}
```

Implementation:

```nix
xdg.configFile."kitty/light-theme.auto.conf".text = style.mkKittyTheme palettes.light;
xdg.configFile."kitty/dark-theme.auto.conf".text = style.mkKittyTheme palettes.dark;
xdg.configFile."kitty/no-preference-theme.auto.conf".text = style.mkKittyTheme defaultPalette;
```

Reason: Home Manager's `programs.kitty.autoThemeFiles` expects theme names from `kitty-themes`, and the pinned package does not include Enfocado. Writing Kitty's native auto-theme files directly keeps Enfocado as source of truth.

### Yazi Native Flavor

Implementation:

```nix
programs.yazi.theme.flavor = {
  dark = "enfocado-dark";
  light = "enfocado-light";
};

programs.yazi.flavors = {
  enfocado-light = pkgs.writeTextDir "flavor.toml" (style.mkYaziFlavor palettes.light);
  enfocado-dark = pkgs.writeTextDir "flavor.toml" (style.mkYaziFlavor palettes.dark);
};
```

Reason: Yazi supports light/dark flavor selection natively through `theme.toml`, so it does not need to participate in `my-style-switch`. The generated flavor packages intentionally contain only `flavor.toml` for now; `tmtheme.xml` is left out to keep this adapter scoped to Yazi's own UI colors.

### Future Stubs

Add typed target options only:

```nix
adapters.ghostty.enable = false;
adapters.vscode.enable = false;
```

Document future mappings:

```nix
# Ghostty
programs.ghostty.settings.theme = "dark:...,light:...";

# VSCode
programs.vscode.userSettings = {
  "window.autoDetectColorScheme" = true;
  "workbench.preferredDarkColorTheme" = "...";
  "workbench.preferredLightColorTheme" = "...";
};
```

Type-check:

```sh
nix flake check --show-trace
```

## Milestone 6: Runtime Theme Artifacts

Purpose: generate both modes declaratively and switch only tiny runtime pointers/state.

This replaces the original Home Manager specialisation milestone.

### Tests First

```nix
{
  name = "runtime-theme-artifacts-exist";
  condition =
    pallonFiles."my/theme/alacritty/enfocado_light.toml" ? text
    && pallonFiles."my/theme/alacritty/enfocado_dark.toml" ? text
    && pallonFiles."my/theme/i3/light.conf" ? text
    && pallonFiles."my/theme/i3/dark.conf" ? text
    && pallonFiles."my/theme/current/alacritty.toml" ? text
    && pallonFiles."my/theme/current/i3.conf" ? text;
}
```

### Implementation

In the HM style module:

```nix
xdg.configFile."my/theme/alacritty/enfocado_light.toml".text =
  style.mkAlacrittyTheme palettes.light;
xdg.configFile."my/theme/alacritty/enfocado_dark.toml".text =
  style.mkAlacrittyTheme palettes.dark;

xdg.configFile."my/theme/i3/light.conf".text = style.mkI3Theme palettes.light;
xdg.configFile."my/theme/i3/dark.conf".text = style.mkI3Theme palettes.dark;
xdg.configFile."my/theme/current/i3.conf".text = style.mkI3Theme defaultPalette;
xdg.configFile."my/theme/waybar/light.css".text = style.mkWaybarCss palettes.light fontFamily;
xdg.configFile."my/theme/hyprland/dark.conf".text = style.mkHyprlandTheme palettes.dark;
```

Then app modules reference stable paths:

```nix
programs.alacritty.settings.general.import = [
  "~/.config/my/theme/current/alacritty.toml"
];
```

Runtime switching updates `~/.config/my/theme/current/*` and `~/.local/state/my-theme/mode`; it does not evaluate or activate Home Manager.

Type-check:

```sh
nix flake check --show-trace
```

## Milestone 7: i3, i3status, And Alacritty Declarative Fallback

Purpose: keep immutable generated configs, then reload consumers.

### i3 Tests First

Preserve existing i3 display tests.

Add:

```nix
{
  name = "i3-colors-derived-from-style";
  condition =
    contains "include ~/.config/my/theme/current/i3.conf" i3Config
    && contains "bar {" pallonFiles."my/theme/current/i3.conf".text
    && contains "#0064e4" pallonFiles."my/theme/current/i3.conf".text;
}

{
  name = "i3-runtime-does-not-generate-config";
  condition = oldNoRuntimeMutationInvariantStillTrue;
}
```

Implementation shape:

```nix
mkI3Theme = palette: ''
client.focused ${palette.normal.blue} ${palette.normal.blue} ${palette.primary.background} ${palette.normal.magenta} ${palette.normal.blue}
client.unfocused ${palette.normal.black} ${palette.normal.black} ${palette.bright.black} ${palette.bright.black} ${palette.normal.black}
client.urgent ${palette.normal.red} ${palette.normal.red} ${palette.primary.background} ${palette.normal.red} ${palette.normal.red}
'';
```

Implemented shape: the i3 parent config includes the current theme file, and the generated theme file contains literal client colors plus the full bar block. This avoids i3 include variable ordering problems.

```text
include ~/.config/my/theme/current/i3.conf
bar.colors.background #ffffff
client.focused #0064e4 #0064e4 #ffffff #dd0f9d #0064e4
```

### i3status

Implemented shape: generate custom Enfocado i3status-rust TOML from the shared palette and point the status config at the current theme path.

```text
theme = "/home/<user>/.config/my/theme/current/i3status-rust.toml"
my/theme/i3status-rust/enfocado_light.toml
my/theme/i3status-rust/enfocado_dark.toml
my/theme/current/i3status-rust.toml
```

Runtime behavior: `my-style-switch` updates `current/i3status-rust.toml`, then the existing `i3-msg reload` restarts the bar.

### Alacritty Tests First

```nix
{
  name = "alacritty-theme-style-managed";
  condition =
    alacrittyConfig.general.import == [ "~/.config/my/theme/current/alacritty.toml" ]
    && contains "[colors.primary]" pallonFiles."my/theme/alacritty/enfocado_light.toml".text
    && contains "background = \"#181818\"" pallonFiles."my/theme/alacritty/enfocado_dark.toml".text;
}
```

Implementation shape:

```nix
mkAlacrittyTheme = c: ''
[colors.primary]
background = "${c.primary.background}"
foreground = "${c.primary.foreground}"

[colors.normal]
black = "${c.normal.black}"
red = "${c.normal.red}"
green = "${c.normal.green}"
yellow = "${c.normal.yellow}"
blue = "${c.normal.blue}"
magenta = "${c.normal.magenta}"
cyan = "${c.normal.cyan}"
white = "${c.normal.white}"
'';
```

### Hyprland And Waybar

Implemented adapters:

```nix
wayland.windowManager.hyprland.extraConfig = lib.mkBefore ''
  source = ~/.config/my/theme/current/hyprland.conf
'';

programs.waybar.style = ''
  @import url("../my/theme/current/waybar.css");
'';
```

Runtime behavior:

- `my-style-switch` updates current theme files.
- Hyprland is reloaded with `hyprctl reload`.
- Waybar is signalled; live-session validation is still pending.

Type-check:

```sh
nix flake check --show-trace
```

## Milestone 8: Redshift Coordination

Purpose: avoid split timing/location logic.

Tests first:

```nix
{
  name = "darkman-and-redshift-share-manual-location";
  condition =
    darkman.settings.usegeoclue == false
    && darkman.settings.lat == osConfig.location.latitude
    && darkman.settings.lng == osConfig.location.longitude;
}
```

Implementation:

- Keep Redshift enabled where currently enabled.
- Do not let darkman control Redshift.
- Use the same host location values.
- Document that darkman is semantic UI mode.
- Document that redshift is display temperature/brightness.

Follow-up: evaluate Wayland-native alternatives if Redshift is unreliable under Hyprland.

## Milestone 9: Documentation And Operations

Add `docs/theme-architecture.md`.

Must document:

- source of truth
- mode flow
- runtime state/link switching
- portal validation
- GNOME mirror
- Neovim signal behavior
- app support matrix
- manual commands

Example support matrix:

```text
darkman   source of truth
portal    darkman-backed
GNOME     mirrored consumer
i3        static include + reload
Hyprland  generated source + reload
Neovim    SIGUSR1 live switch
Kitty     generated native auto-theme files
Alacritty current import + runtime msg reload
Yazi      generated native light/dark flavors
Ghostty   future native dual theme
VSCode    future autoDetectColorScheme
Redshift  independent, shared location
```

Final verification:

```sh
nix flake check --show-trace
nix build .#nixosConfigurations.andromeda.config.system.build.toplevel
nix build .#nixosConfigurations.earth.config.system.build.toplevel
```

## Type-Checking Strategy

Run Nix evaluation/type checks:

- Before changes.
- After adding failing tests.
- After adding each new module option.
- After migrating each host.
- After each app adapter.
- Before replacing old assertions.
- At final integration.

Primary command:

```sh
nix flake check --show-trace
```

Focused evals for debugging:

```sh
nix eval .#nixosConfigurations.andromeda.config.my.nixos.features.style.enable
nix eval .#nixosConfigurations.earth.config.home-manager.users.jelias.services.darkman.enable
```

## Testing Strategy

Automated tests:

- Nix module eval assertions.
- Existing i3 syntax tests.
- Existing autorandr/i3 invariants.
- New darkman/portal assertions.
- New runtime artifact and dispatcher assertions.
- New Neovim SIGUSR1 config assertions.
- New Kitty auto-theme assertions.
- Stylix opt-in invariant.
- Display manager non-dynamic invariant.

Manual acceptance for both users:

```sh
darkman set light
darkman get
darkman set dark
darkman get
```

Verify:

- portal reports `2` for light and `1` for dark
- Kitty changes automatically
- Neovim live-switches
- i3 reloads
- Hyprland reloads
- Waybar updates after signal/restart behavior is confirmed
- GNOME fallback session follows mode
- Alacritty follows through `alacritty msg config -w -1 ...`
- Redshift still works independently

## Follow-Up Tasks

- Full Ghostty module if Ghostty is added.
- Full VSCode module if VSCode is added.
- Live-session validation for `pallon@andromeda` using `docs/theme-architecture.md`.
- Live-session validation for `jelias@earth` when that session is available.
- Optional Yazi `tmtheme.xml` generation if preview/syntax highlighting needs repo-owned colors.
- VM/integration tests for darkman portal behavior.
- Evaluate Redshift replacement for Wayland/Hyprland.
- Accessibility pass: contrast and light palette readability.
- Optional screenshot regression checks for major apps.
