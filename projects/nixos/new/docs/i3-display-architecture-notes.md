# i3 Display Architecture Notes

## Context

The i3 migration separates most i3 behavior into
`modules/home-manager/features/i3/default.nix`. Physical display knowledge now
lives in the shared Home Manager option
`my.hm.features.displayProfiles`, with Andromeda's profiles declared from
`hosts/andromeda/default.nix`.

The old reference setup used autorandr `postswitch` scripts to mutate the main
i3 config by deleting and reinserting lines like:

```sh
set $OUT DP-4
set $OUT2 DP-3
```

Those variables were then used by workspace and bar output config in
`ref/i3/local/config`.

That approach is fragile because it edits the main i3 config at runtime and
depends on i3 variable/include behavior. i3 includes do not solve this cleanly:
variables from included files cannot be used by the parent config because i3
expands variables before processing includes.

An intermediate implementation avoided editing the main config directly, but
still generated `~/.config/i3/display-config` at activation time and rewrote it
from autorandr hooks through `write-display-config.sh`. That was safer than the
reference setup, but it still kept a runtime shell writer responsible for
workspace output rules and the bar block.

Relevant upstream docs:

- i3 include directive and variable behavior:
  https://i3wm.org/docs/4.20/userguide.html#include
- i3 workspace output assignment:
  https://i3wm.org/docs/4.20/userguide.html#workspace_screen
- i3bar output selection, including `primary` and `nonprimary`:
  https://i3wm.org/docs/4.20/userguide.html#_displaying_i3bar_on_multiple_outputs
- autorandr hooks, including `postswitch`, are intended for notifying window
  managers after a display change:
  https://github.com/phillipberndt/autorandr

## Current Implementation

The current implementation has no runtime i3 config generation.

`my.hm.features.displayProfiles` is the source of truth for physical display
profiles and output roles. The module generates:

- autorandr profiles for X11/i3;
- the `my-display-profile` Wayland apply/watch helper for Sway and Hyprland;
- profile role data used by Sway workspace output fallbacks;
- Hyprland dynamic workspace moves through the helper.

Each Andromeda display profile enables one or two outputs and marks exactly one
enabled output as primary. The generated autorandr postswitch hook reloads i3
and reapplies the cached wallpaper:

```sh
i3-msg reload
my-bing-wallpaper apply-cache || true
```

The Home Manager i3 module renders static logical workspace output rules
directly into `~/.config/i3/config`:

```i3
workspace "1: mail" output primary
workspace "2: browser" output primary

workspace "11: terminal" output nonprimary primary
workspace "12" output nonprimary primary
```

The parent config includes the managed theme file:

```i3
include ~/.config/my/theme/current/i3.conf
```

That include owns all dynamic i3 style, including literal client colors and the
full bar block:

```i3
bar {
    output primary
    output nonprimary
    status_command /nix/store/.../bin/i3status-rs $HOME/.config/i3status-rust/config.toml
    colors {
        focused_workspace #0064e4 #0064e4 #ffffff
    }
}
```

Primary workspaces target i3's `primary` alias. Secondary workspaces target
`nonprimary primary`, so a two-output profile places them on the non-primary
display and a single-output profile falls back to the primary display. The bar
uses `output primary` and `output nonprimary`, matching the same logical model.

Sway does not use i3's `primary` or `nonprimary` aliases. Its generated
workspace rules use fallback output lists derived from display profile roles,
for example primary workspace outputs from all profile primaries and secondary
workspace outputs from all profile secondaries followed by primary fallbacks.
Hyprland starts `my-display-profile watch hyprland`; the helper applies the
matching profile and dispatches workspaces 1-10 to the active primary output and
11-19 to the active secondary output, falling back to primary on single-monitor
profiles.

The parent config must not reference variables defined by the included theme
file. i3 expands variables before processing includes, so included-file
variables cannot be consumed by the parent. Generated dynamic theme files use
literal hex colors instead.

There is no `include ~/.config/i3/display-config`, no
`write-display-config.sh`, and no Home Manager activation step that writes an i3
display fragment.

## Invariants

Andromeda display profiles are intentionally constrained:

- every profile has at least one enabled output;
- every profile has at most two enabled outputs;
- every profile has exactly one enabled primary output;
- every generated autorandr profile output has a fingerprint;
- every autorandr `postswitch` hook reloads i3 and reapplies cached wallpaper;
- no autorandr hook calls `write-display-config.sh`.

These constraints keep the static i3 rules meaningful. `primary` always maps to
one physical output, and `nonprimary` is either the single secondary output or
absent.

## Testing

The flake checks cover the architecture directly:

- `i3-config` asserts the rendered i3 config contains static primary and
  secondary workspace rules, includes the managed style theme, does not
  reference included-file theme variables, does not include `display-config`,
  does not deploy `write-display-config.sh`, and contains no stale `$OUT` /
  `$OUT2` text. It also asserts the generated dynamic theme owns the bar block
  and uses literal visible workspace colors.
- `display-profiles-*` asserts the shared profile model, autorandr generation,
  and generated postswitch wallpaper cache reapply.
- `sway-*` asserts Sway uses physical output names derived from display profile
  roles and contains no i3-only `primary` or `nonprimary` tokens.
- `hyprland-workspace-outputs-derived-from-display-profiles` and
  `wayland-display-profile-helper-*` assert the helper is present and applies
  fake Sway/Hyprland layouts.
- `i3-autorandr` asserts the autorandr profile invariants and verifies hooks
  still reload i3.
- `i3-syntax` runs `i3 -C` against the generated Andromeda i3 config.
- `i3-statusbar-path` keeps `i3status-rust` available in the user environment.

Useful targeted validation:

```sh
nix build .#checks.x86_64-linux.i3-config
nix build .#checks.x86_64-linux.i3-autorandr
nix build .#checks.x86_64-linux.display-profiles-generates-autorandr
nix build .#checks.x86_64-linux.sway-workspace-outputs-derived-from-display-profiles
nix build .#checks.x86_64-linux.hyprland-workspace-outputs-derived-from-display-profiles
nix build .#checks.x86_64-linux.i3-statusbar-path
nix build .#checks.x86_64-linux.i3-syntax
```

Run `nix flake check` for full validation after targeted checks pass.
