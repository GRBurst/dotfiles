{
  config,
  lib,
  pkgs,
  ...
}: let
  cfg = config.my.hm.features.ai;

  # "claude" -> "nono run --profile nolabs-ai/claude --allow-cwd -- claude"
  mkSandboxAlias = command: profile:
    lib.concatStringsSep " "
    (["nono" "run" "--profile" profile] ++ cfg.sandbox.args ++ ["--" command]);

  sandboxAliases = lib.mapAttrs mkSandboxAlias cfg.sandbox.profiles;
in {
  options.my.hm.features.ai = {
    enable =
      lib.mkEnableOption "AI tooling (agent CLIs and the nono sandbox)"
      // {default = true;};

    packages = lib.mkOption {
      type = with lib.types; listOf package;
      default = with pkgs; [
        aichat
        antigravity-ide
        claude-code
        claude-monitor
        codex
        gemini-cli-bin
        lmstudio
        opencode
        opencode-claude-auth
        # openai-whisper  # disabled: drags torch + piper-tts + faster-whisper (all uncached)
      ];
      description = "AI tool packages installed into the user profile.";
    };

    sandbox = {
      enable =
        lib.mkEnableOption "run AI agents through the nono sandbox"
        // {default = true;};

      package = lib.mkOption {
        type = lib.types.package;
        default = pkgs.nono;
        description = "Package providing the nono sandbox CLI.";
      };

      profiles = lib.mkOption {
        type = with lib.types; attrsOf str;
        default = {
          claude = "nolabs-ai/claude";
          opencode = "opencode-claude"; # local profile written below
        };
        description = ''
          Command name mapped to its nono profile. Each entry generates the alias
          `<command> = nono run --profile <profile> <sandbox.args> -- <command>`.
          Add a sandboxed tool by adding one attribute here.
        '';
      };

      args = lib.mkOption {
        type = with lib.types; listOf str;
        default = ["--allow-cwd"];
        description = ''
          Extra `nono run` flags applied to every generated sandbox alias.
          `--allow-cwd` grants the working directory at the level the profile
          declares; without it nono prompts for it on every run.
        '';
      };

      autoInstallPacks = lib.mkOption {
        type = lib.types.bool;
        default = true;
        description = ''
          Set NONO_AUTO_MIGRATE so nono installs missing registry packs
          non-interactively. nono no longer ships built-in profiles, so without
          this the first sandboxed run prompts before fetching from
          registry.nono.sh.
        '';
      };
    };

    aliases = lib.mkOption {
      type = with lib.types; attrsOf str;
      default = {};
      description = ''
        Additional AI aliases. Overrides a generated sandbox alias of the same
        name, which is how a single tool gets extra `nono run` flags.
      '';
    };
  };

  config = lib.mkIf cfg.enable {
    home.packages = cfg.packages ++ lib.optional cfg.sandbox.enable cfg.sandbox.package;

    # mkDefault so shell-specific modules (features/zsh.nix) can still override
    # individual aliases -- same reasoning as features/shellAliases.nix.
    home.shellAliases =
      lib.mapAttrs (_: lib.mkDefault)
      ((lib.optionalAttrs cfg.sandbox.enable sandboxAliases) // cfg.aliases);

    home.sessionVariables =
      lib.optionalAttrs (cfg.sandbox.enable && cfg.sandbox.autoInstallPacks)
      {NONO_AUTO_MIGRATE = "1";};

    xdg.configFile =
      {
        # opencode scans ~/.config/opencode/{plugin,plugins}/*.{ts,js} at startup
        # (symlinks followed), so no opencode.jsonc entry is needed. Export only
        # ClaudeAuthPlugin: the legacy loader path invokes *every* export as a
        # plugin, and dist/index.js also exports ten non-plugin helpers.
        "opencode/plugin/claude-auth.js".text = ''
          export { ClaudeAuthPlugin } from "${pkgs.opencode-claude-auth}/lib/node_modules/opencode-claude-auth/dist/index.js";
        '';
      }
      // lib.optionalAttrs cfg.sandbox.enable {
        "nono/profiles/opencode-claude.json".text = builtins.toJSON {
          "$schema" = "https://nono.sh/schemas/nono-profile.schema.json";
          # Union of both packs: opencode-claude-auth refreshes an expired token by
          # shelling out to `claude -p`, so the nested claude needs its pack's
          # grants (~/.claude rw, ~/.cache/claude, /tmp/claude-$UID) too.
          extends = ["nolabs-ai/opencode" "nolabs-ai/claude"];
          meta = {
            name = "opencode-claude";
            description = "opencode with Claude Code credential access for opencode-claude-auth";
          };
          # open_urls is replace-on-override rather than append, so without this
          # the claude pack (last base) drops opencode's openai/github origins.
          open_urls = {
            allow_origins = [
              "https://auth.openai.com"
              "https://github.com"
              "https://claude.ai"
              "https://claude.com"
              "https://api.anthropic.com"
              "https://platform.claude.com"
            ];
            allow_localhost = true;
          };
        };
      };
  };
}
