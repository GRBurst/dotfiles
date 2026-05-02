{
  config,
  lib,
  pkgs,
  inputs,
  ...
}: let
  cfg = config.my.hm.features.librewolf;
  addons = inputs.firefox-addons.packages.${pkgs.system};
in {
  options.my.hm.features.librewolf = {
    enable = lib.mkEnableOption "Declarative LibreWolf via Home Manager";

    package = lib.mkOption {
      type = lib.types.package;
      default = pkgs.librewolf-bin;
      description = ''
        LibreWolf package used by `programs.librewolf`. Defaults to the
        binary build to match the system-wide install and avoid long
        source compiles.
      '';
    };

    profileName = lib.mkOption {
      type = lib.types.str;
      default = "nix-managed";
      description = ''
        Name of the HM-owned LibreWolf profile. Distinct from any
        pre-existing `default` profile to keep the migration
        non-destructive and reversible.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    programs.librewolf = {
      enable = true;
      package = cfg.package;
      # Keep pre-migration profile on disk as an escape hatch; id=1 leaves id=0 for the managed profile
      profiles.manual = {
        id = 1;
        path = "mi3lqq74.default";
        isDefault = false;
      };
      profiles.${cfg.profileName} = {
        id = 0;
        isDefault = true;
        extensions.packages = with addons; [
          ublock-origin
          keepassxc-browser
          darkreader
          noscript
          tridactyl
          temporary-containers
          multi-account-containers
          cookie-autodelete
          decentraleyes
          refined-github
          web-developer
          containerise
          canvasblocker
        ];
        settings = {
          # --- privacy / fingerprinting ---
          "privacy.fingerprintingProtection" = true;
          "privacy.trackingprotection.enabled" = true;
          "privacy.trackingprotection.emailtracking.enabled" = true;
          "privacy.trackingprotection.socialtracking.enabled" = true;
          "privacy.trackingprotection.allow_list.baseline.enabled" = false;
          "privacy.trackingprotection.allow_list.convenience.enabled" = false;
          "privacy.trackingprotection.consentmanager.skip.pbmode.enabled" = false;
          "privacy.annotate_channels.strict_list.enabled" = true;
          "privacy.bounceTrackingProtection.mode" = 1;
          "privacy.donottrackheader.enabled" = true;
          "privacy.query_stripping.enabled" = true;
          "privacy.query_stripping.enabled.pbmode" = true;
          "privacy.spoof_english" = 1;
          "privacy.history.custom" = true;
          "privacy.clearOnShutdown_v2.formdata" = true;
          "privacy.clearOnShutdown_v2.historyFormDataAndDownloads" = true;
          "privacy.sanitize.sanitizeOnShutdown" = false;

          # --- network hardening ---
          "network.captive-portal-service.enabled" = false;
          "network.connectivity-service.enabled" = false;
          "network.early-hints.preconnect.max_connections" = 0;
          "network.http.http3.enable_0rtt" = false;
          "network.http.referer.disallowCrossSiteRelaxingDefault.top_navigation" = true;
          "network.http.speculative-parallel-limit" = 0;
          "network.predictor.enabled" = false;
          "network.prefetch-next" = false;

          # --- WebRTC / media ---
          "media.peerconnection.enabled" = false;
          "media.peerconnection.ice.no_host" = true;
          "media.eme.enabled" = true;

          # --- TLS ---
          "security.tls.enable_0rtt_data" = false;

          # --- history / browsing data ---
          "places.history.enabled" = false;
          "browser.contentblocking.category" = "strict";
          "browser.startup.page" = 3;

          # --- UI ---
          "accessibility.typeaheadfind.flashBar" = 0;
          "browser.toolbars.bookmarks.showOtherBookmarks" = false;
          "browser.toolbars.bookmarks.visibility" = "never";
          "browser.urlbar.placeholderName" = "DuckDuckGo";
          "browser.urlbar.placeholderName.private" = "DuckDuckGo";
          "browser.urlbar.suggest.searches" = true;

          # --- locale ---
          "javascript.use_us_english_locale" = true;

          # --- credentials ---
          "signon.autofillForms" = true;
          "signon.firefoxRelay.feature" = "disabled";
          "signon.generation.enabled" = false;
          "signon.rememberSignons" = true;
          "dom.forms.autocomplete.formautofill" = true;

          # --- sync (disable history/tabs/prefs to avoid conflicting with Nix; P5 uses Sync for bookmarks only) ---
          "identity.fxaccounts.enabled" = true;
          "services.sync.declinedEngines" = "history,creditcards,tabs";
          "services.sync.engine.history" = false;
          "services.sync.engine.prefs.modified" = false;
          "services.sync.engine.tabs" = false;

          # --- extensions (prevent browser from disabling declaratively installed extensions on first launch) ---
          "extensions.autoDisableScopes" = 0;
        };
      };
    };
  };
}
