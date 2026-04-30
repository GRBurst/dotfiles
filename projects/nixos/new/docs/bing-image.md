# Bing Wallpaper

## Status

The optional Bing Image of the Day wallpaper feature is implemented for
Andromeda/pallon and supports both i3/X11 and Hyprland/Wayland-capable sessions.
Andromeda now uses Bing on the configured primary Hyprland monitor and NASA APOD
on secondary monitors, falling back across the latest seven APOD days when
today's APOD is a video. Hyprland wallpaper assignment is retry-hardened so the
user service can tolerate `hyprpaper` IPC not being ready immediately. For
Hyprland, `hyprctl hyprpaper wallpaper '[mon], [path], [fit_mode]'` is the
correct way to set a wallpaper nowadays and using `reload` is not working
anymore.

Implemented files:

- `modules/home-manager/features/bing-wallpaper.nix`
- `modules/nixos/features/desktop/bing-wallpaper.nix`
- `hosts/andromeda/default.nix`
- `checks/eval-assertions.nix`

The public Nix API remains under the same feature roots, with APOD and Hyprland
monitor options added under `bingWallpaper`:

- `my.nixos.features.desktop.bingWallpaper`
- `my.hm.features.bingWallpaper`

## Runtime Behavior

The generated `my-bing-wallpaper` package:

- fetches Bing metadata from `HPImageArchive.aspx`;
- supports market, interval, count, and `preferUhd`;
- tries derived UHD URLs before falling back to Bing's advertised URL;
- optionally fetches NASA APOD metadata from `api.nasa.gov/planetary/apod` for
  today plus the previous six days;
- selects the newest APOD image in that seven-day range by APOD metadata date;
- reuses cached APOD without failing when NASA returns only videos, lacks an
  image URL, or cannot be fetched;
- caches images under `$XDG_CACHE_HOME/bing-wallpaper` or
  `$HOME/.cache/bing-wallpaper`;
- updates `latest.jpg` to the primary Bing image;
- updates `nasa-latest.jpg` to the latest successful APOD image;
- writes `latest-paths` with the display order manifest;
- writes `state.json` with the last successful refresh date, market, display
  paths, Bing start date, and APOD date;
- passes image paths to the configured setter as positional arguments.

`my-bing-wallpaper` supports explicit modes:

- no argument or `refresh`: fetch metadata/images unconditionally, update cache
  state, and apply the selected paths;
- `refresh-if-stale`: exit without network access when `state.json` was
  refreshed today and every cached display path still exists;
- `apply-cache`: apply `latest-paths`, or `latest.jpg` when the manifest is not
  valid, without network access;
- `login`: apply cache immediately, then refresh only when the cache is stale.

Freshness is intentionally local and date-based: cache is fresh when
`state.json` has `version = 1`, `refreshedDate = date +%F`, and the cached paths
from `latest-paths` or `latest.jpg` exist. A fresh login therefore does not wait
on Bing or NASA. A stale login still shows the cached wallpaper first; if the
network refresh fails and cache was applied, the login service succeeds.

The default setter is session-aware:

1. If `hyprctl` is available and `hyprctl monitors -j` succeeds, it sets the
   first image path on the configured primary monitor, or Hyprland's first
   monitor when no configured monitor is present.
2. If a second image path is available, it sets that image on every other
   Hyprland monitor. Each Hyprland wallpaper assignment is tried up to five
   times before the setter fails.
3. Otherwise, if `DISPLAY` is set, it falls back to X11 with
   `feh --bg-fill "$@"`.
4. If neither supported session is found, it exits non-zero.

The display order manifest is positional:

1. primary Bing image;
2. NASA APOD image when available.

When NASA APOD is disabled, the second fetched Bing image remains available as
the secondary wallpaper. When NASA APOD is enabled, APOD failure no longer falls
back to the second Bing image: the script reuses `nasa-latest.jpg` when present,
otherwise it passes only the primary Bing image and leaves the existing
secondary wallpaper unchanged.

If a refresh fails, the script now reuses cache before failing the systemd
service:

1. Valid non-empty `latest-paths` manifest.
2. Valid `latest.jpg`.
3. Exit non-zero with `No Bing wallpapers downloaded and no cache available`.

The Andromeda default remains:

- `market = "de-DE"`
- `interval = "6h"`
- `count = 2`
- `preferUhd = true`
- `hyprlandPrimaryMonitor = "eDP-1"`
- `nasaApod.enable = true`
- setter: session-aware Hyprland/hyprpaper first, X11/feh fallback

The user timer installs into `timers.target` and runs `bing-wallpaper.service`
every six hours after successful activation. That service runs
`my-bing-wallpaper refresh-if-stale`.

Wallpaper application at session start is owned by
`bing-wallpaper-login.service`, installed into `graphical-session.target`. It
runs `my-bing-wallpaper login`, which applies the cached wallpaper immediately
instead of waiting for the timer.

The state file has this shape:

```json
{
  "version": 1,
  "refreshedDate": "2026-04-30",
  "market": "de-DE",
  "displayPaths": ["/home/pallon/.cache/bing-wallpaper/20260430_0.jpg"],
  "bingStartdate": "20260430",
  "nasaDate": "2026-04-29"
}
```

## Verification

Targeted checks passed:

```sh
nix build .#checks.x86_64-linux.andromeda-bing-wallpaper-package
nix build .#checks.x86_64-linux.andromeda-bing-wallpaper-primary-monitor
nix build .#checks.x86_64-linux.andromeda-bing-wallpaper-nasa-apod
nix build .#checks.x86_64-linux.andromeda-bing-wallpaper-session-aware-setter
nix build .#checks.x86_64-linux.andromeda-bing-wallpaper-script-structure
nix build .#checks.x86_64-linux.bing-wallpaper-nasa-image-second-path
nix build .#checks.x86_64-linux.bing-wallpaper-nasa-video-range-selects-newest-image
nix build .#checks.x86_64-linux.bing-wallpaper-nasa-range-no-image-reuses-cache
nix build .#checks.x86_64-linux.bing-wallpaper-nasa-range-no-image-keeps-secondary
nix build .#checks.x86_64-linux.bing-wallpaper-hyprland-primary-secondary
nix build .#checks.x86_64-linux.bing-wallpaper-hyprland-missing-primary-falls-back
nix build .#checks.x86_64-linux.bing-wallpaper-hyprland-single-monitor-one-call
nix build .#checks.x86_64-linux.bing-wallpaper-hyprland-one-path-keeps-secondary
nix build .#checks.x86_64-linux.bing-wallpaper-hyprland-wallpaper-retries
nix build .#checks.x86_64-linux.bing-wallpaper-reuses-latest-paths
nix build .#checks.x86_64-linux.bing-wallpaper-reuses-latest-jpg
nix build .#checks.x86_64-linux.bing-wallpaper-fails-without-cache
nix build .#nixosConfigurations.andromeda.config.system.build.toplevel
```

The cache checks force failed network access and verify the generated package
invokes a fake setter with cached paths.

Full validation passed:

```sh
nix flake check
```

The previous deferred NASA APOD and monitor-aware assignment items are now
included because the requested mapping is Bing primary plus NASA secondary. The
latest APOD change diverges from the earlier today-only APOD behavior: the
Andromeda failure was caused by APOD video days, so the implementation now uses
NASA's range response and selects the newest image in the seven-day window. The
Hyprland retry behavior intentionally remains an internal setter detail: there
are no new public retry count, retry delay, fit mode, or APOD range options.
