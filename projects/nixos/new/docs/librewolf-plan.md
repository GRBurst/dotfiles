# LibreWolf to NixOS Migration: Conceptual Implementation Plan

This document outlines the architectural strategy for migrating an existing,
customized LibreWolf setup into a fully declarative NixOS / Home Manager
environment. Following the **Separation of Concerns (SoC)** and **Correctness by
Construction** principles, this migration avoids "big bang" deployments.
Instead, it builds the configuration in isolated, verifiable phases.

## Implementation Status

| Phase | Title                        | Status     |
|-------|------------------------------|------------|
| P₁    | Base Module Activation       | ✅ Done    |
| P₂    | Core Preferences Migration   | ✅ Done    |
| P₃    | Extension Installation       | ✅ Done    |
| P₄    | Plugin Configuration         | ✅ Done    |
| P₅    | Volatile Data (Bookmarks)    | ⏳ Pending |

### Divergence from plan (P₁)

1. **Feature-module wrapper.** `programs.librewolf` is wrapped in
   `my.hm.features.librewolf.{enable, package, profileName}` to match the
   repo convention (`git.nix`, `dunst.nix`, `kitty.nix`).
2. **`id = 0` required.** The upstream HM profile submodule declares `id : int`
   with no default; eval fails without it. Plan skeleton omits it.
3. **Profile name `"nix-managed"`.** Keeps the pre-existing on-disk default
   profile intact during migration; reversible and side-by-side comparable.
4. **Package = `pkgs.librewolf-bin`.** Matches the system-wide install, avoids
   long source builds. Override exposed via `cfg.package`.
5. **Insecure allowance migrated to `allowInsecurePredicate`.** The two
   version-pinned strings (`librewolf-bin-149.0.2-2`,
   `librewolf-bin-unwrapped-149.0.2-2`) are replaced by
   `nixpkgs.config.allowInsecurePredicate`, which matches any version of
   `librewolf-bin` and `librewolf-bin-unwrapped`. `openssl-1.1.1w` stays in
   `permittedInsecurePackages`. (`permittedInsecurePackagePredicates` does not
   exist in nixpkgs; `allowInsecurePredicate` is the correct key.)
6. **Both users opted in.** `jelias` and `pallon` both enable the feature;
   `ref/firefox.prefs` originated from `pallon` and both will converge.
7. **NixOS-side install retained.** `modules/nixos/features/firefox.nix`
   (system-wide `librewolf-bin`) is intentionally untouched as a safety net.
   Removal will be considered after P₂ stabilises.
8. **Eval-only assertions added.** 16 new checks in `checks/eval-assertions.nix`
   covering module isolation, per-user feature enablement, profile shape, and
   the insecure-package predicate migration.

## Phase 1: Base Module Activation (The Foundation)

**Goal:** Establish a working LibreWolf binary using the correct file paths
without any complex configurations. **Architecture Principle:** _Make Illegal
States Irrepresentable_ (Using the dedicated module prevents `~/.mozilla` path
mismatches).

- **Action:** Enable the dedicated LibreWolf module in Home Manager.
- **Implementation Skeleton:**
  ```nix
  programs.librewolf = {
    enable = true;
    # Profiles map to the isolated ~/.librewolf/ directories.
    profiles."default" = {
      isDefault = true;
    };
  };
  ```
- **Verification:** Deploy this configuration, launch LibreWolf, and confirm it
  creates the `~/.librewolf` directory structure natively.

### Divergence from plan (P₂)

1. **Profile attribute path.** Plan skeleton uses `profiles."default"`; the real module uses
   `profiles.${cfg.profileName}` (default `"nix-managed"`). Settings are placed there.
2. **Settings live in the feature module, not per-user.** Both `jelias` and `pallon` share the
   same settings by enabling the feature. Per-user overrides deferred to later phases.
3. **`privacy.fingerprintingProtection` used instead of `resistFingerprinting`.** The plan
   skeleton names `resistFingerprinting` as an example. The source profile (`ref/firefox.prefs`)
   has `privacy.fingerprintingProtection` (LibreWolf's own layered hardening). Tor-grade
   `resistFingerprinting` (letterboxing, en-US clock) was not enabled in the captured profile
   and would be intrusive; it was omitted intentionally. Eval assertions use
   `privacy.fingerprintingProtection` as the representative check.
4. **`browser.theme.toolbar-theme` omitted.** Themeing is owned by the Stylix/style feature;
   pinning a toolbar value here would couple the concerns. Dropped.
5. **`widget.use-xdg-desktop-portal.settings` omitted.** LibreWolf already enables XDG portals
   on Linux by default; pinning the migration-counter value adds no hardening. Dropped per YAGNI.
6. **Ephemeral entries filtered out.** The following categories were dropped from
   `ref/firefox.prefs` as ephemeral / state / per-machine and not suitable for immutable config:
   build IDs, timestamps (`last*`), migration markers (`hasMigrated*`, `migrationNeeded`),
   pending sanitize queue (JSON), session-store backup ID, onboarding counters, sandbox temp
   suffix (per-install GUID), Widevine install metadata, GMP storage version, SQLite vacuum
   timestamps, sync `lastPing`/`lastSync`, and all print settings.
7. **Sync engine prefs (`services.sync.engine.*`) included.** Aligns with P4's intent to disable
   preference/addon sync and avoid conflicts with Nix. Doing this in P2 means P5 only needs to
   configure bookmark sync.
8. **P1 `id` drift fixed.** The module had `nix-managed.id = 1` / `manual.id = 0`, but the
   existing eval assertions demanded `nix-managed.id == 0`. Corrected to `nix-managed.id = 0`
   / `manual.id = 1` to match assertions. `isDefault` (not `id`) controls LibreWolf's launch
   profile, so this has no user-visible effect.
9. **5 new eval assertions** under `lw-settings-shared`: verify `privacy.fingerprintingProtection`
   propagates to the isolation fixture and to both real users; verify a representative set of
   bool and string prefs round-trip; verify sync engine prefs are disabled.

### Divergence from plan (P₃)

1. **`extensions.packages` not bare `extensions`.** HM's Firefox module was refactored into
   a submodule; the plan skeleton's list form (`extensions = [ … ]`) is no longer valid.
   The correct path is `profiles.<name>.extensions.packages`.
2. **Direct `firefox-addons` flake input, not `pkgs.nur.repos.rycee`.** Adding
   `gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons` as a first-class flake input
   avoids pulling in all of NUR and follows current HM recommendations.
3. **13 of 24 enabled extensions covered declaratively; 11 manual-install only.**
   Not packaged in rycee: Chameleon, German Dictionary, Add custom search engine, Clear
   private data now!, Containers Helper, Containers theme, Page Assist (Local AI),
   Sourcegraph, Switch Container Plus, Tamper Data for FF Quantum, Awesome Screenshot.
4. **`"extensions.autoDisableScopes" = 0` added to settings.** Without it LibreWolf
   disables declaratively installed extensions on first launch, requiring manual re-enabling.
5. **Isolation fixture in `checks/eval-assertions.nix` gains `extraSpecialArgs = {inherit inputs;}`.** The
   module now depends on `inputs.firefox-addons`; the `homeManagerConfiguration` fixture
   must supply it.
6. **Attribute names differ from display names.** `canvasblocker` ≠ `canvas-blocker`;
   `multi-account-containers` ≠ `firefox-multi-account-containers`.
7. **`Disable WebRTC` extension omitted.** Covered by `media.peerconnection.enabled = false`
   from P₂; the extension is redundant.
8. **5 new eval assertions** under `lw-extensions`: verify `extensions.packages` non-empty,
   `ublock-origin` present in isolation fixture and both real users, ≥10 extensions installed.

### Divergence from plan (P₄)

1. **ExtensionSettings reduced from 11 to 3.** Eight of the originally-manual extensions were
   found in `generated-firefox-addons.nix` and moved to `extensions.packages`. The NUR package
   builder is `buildMozillaXpiAddon` (renamed from `buildFirefoxXpiAddon`). Only Containers
   Helper, Switch Container Plus, and Tamper Data remain in `policies.ExtensionSettings`.
2. **`pkgs.stdenv.hostPlatform.system` replaces `pkgs.system`.** Applied per rycee README
   recommendation for multi-platform flake correctness.
3. **`policies."3rdparty"` added with two entries.** uBlock Origin
   (`uBlock0@raymondhill.net`) is configured with ten privacy-focused filter lists via
   `toOverwrite`. Temporary Containers Plus (`{1ea2fa75-677e-4702-b06a-50fc7d06fe7e}`) is
   configured with automatic isolation mode, `reuse` container numbering, and `always`-isolate
   cross-site navigation. `toOverwrite` is used for both since the `nix-managed` profile is
   fresh with no prior managed-storage state.
4. **Decentraleyes and KeePassXC-Browser explicitly reviewed and excluded** from `3rdparty`
   configuration. Both have managed storage APIs but their factory defaults are appropriate.
   KeePassXC-Browser connects to the system KeePassXC socket without additional config.
5. **`lwHasExt` fixed to use `lib.getName`.** `buildMozillaXpiAddon` does not expose `pname`
   as a derivation attribute (only `name = pname-version`). The old `p.pname or ""` check
   always returned `""`, silently failing all extension-presence assertions. Fixed to
   `lib.getName p` which strips the version suffix from `name`.
6. **Two new assertion blocks added.** `lw-3rdparty` (5 conditions): verifies the `3rdparty`
   policy key, uBlock Origin and Temporary Containers Plus entries, filter lists non-empty, and
   propagation to `pallon@andromeda`. `lw-mozpermissions` (2 conditions): verifies
   `ublock-origin.meta.mozPermissions` exists and contains `webRequest` — a change-detection
   guard per the rycee README guidance that NUR-managed installs skip the browser permission
   prompt.

## Phase 2: Core Preferences Migration (The Hardening)

**Goal:** Translate specific privacy, security, and UI tweaks from
`about:support` into immutable Nix state (`ref/firefox.prefs`).

**Architecture Principle:** _Parse, Don't Validate_ (Translate raw browser state
into strongly typed Nix attributes).

- **Action:** Map the filtered `about:support` payload into the `settings`
  attribute.
- **Process:**
  1. Review the `about:support` "Important Modified Preferences" dump.
  2. Filter out ephemeral state (e.g., window coordinates, print caches).
  3. Convert the remaining JavaScript-style preferences to Nix syntax.
- **Implementation Skeleton:**
  ```nix
  programs.librewolf.profiles."default" = {
    settings = {
      "privacy.resistFingerprinting" = true;
      "webgl.disabled" = true;
      # ... mapped from about:support ...
    };
  };
  ```

## Phase 3: Extension Installation (Immutable Addons)

**Goal:** Install browser extensions declaratively using the Nix User Repository
(NUR), ensuring they update alongside the OS. **Architecture Principle:**
_Single Responsibility Principle_ (Nix manages the binary presence of the
extension; the browser simply loads it).

- **Action:** Integrate the `rycee` NUR flake to fetch packaged
  Firefox/LibreWolf addons.
- **Implementation Skeleton:**
  ```nix
  programs.librewolf.profiles."default" = {
    extensions = with pkgs.nur.repos.rycee.firefox-addons; [
      ublock-origin
      bitwarden
      clearurls
    ];
  };
  ```

## Phase 4: Plugin Configuration (The Hybrid Approach)

**Goal:** Configure the extensions without relying on the unpredictable Firefox
Sync engine.

**Architecture Principle:** _YAGNI (You Ain't Gonna Need It)_ (Do not
over-engineer dynamic database injection for extensions that don't support
declarative policies).

- **Action:** Apply a hybrid configuration model based on extension
  capabilities.
- **Strategy A: Declarative Policies (For supported plugins)**
  - Inject JSON configuration via the `policies.3rdparty` block (e.g., uBlock
    Origin rulesets).
- **Strategy B: Manual Backup/Restore (For unsupported plugins)**
  - For extensions lacking Managed Storage API support, export the configuration
    locally (e.g., `.json` backup) and import it via the browser GUI. Store
    these backups in your dotfiles repository for version control.

## Phase 5: Volatile Data (Bookmarks & History)

**Goal:** Restore daily browsing data without polluting the static system
configuration.

**Architecture Principle:** _High Cohesion, Low Coupling_ (Keep volatile user
state separate from immutable system configuration).

- **Action:** * Declare only "infrastructure" bookmarks (e.g., localhost
  services, router admin panel) via Home Manager's `bookmarks` attribute.
  - Use Firefox Sync _strictly_ for synchronizing history, passwords, and daily
    bookmarks. (Disable preference and addon syncing to avoid conflicting with
    Nix).
