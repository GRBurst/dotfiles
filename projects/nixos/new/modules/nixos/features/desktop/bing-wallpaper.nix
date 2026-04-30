{
  config,
  lib,
  ...
}: let
  cfg = config.my.nixos.features.desktop.bingWallpaper;
  types = lib.types;
in {
  options.my.nixos.features.desktop.bingWallpaper = {
    enable = lib.mkEnableOption "Bing wallpaper for the desktop user";

    user = lib.mkOption {
      type = types.str;
      default = config.my.nixos.core.user.primary;
      description = "Home Manager user that owns the Bing wallpaper service.";
    };

    market = lib.mkOption {
      type = types.str;
      default = "de-DE";
      description = "Bing image archive market, for example de-DE or en-US.";
    };

    interval = lib.mkOption {
      type = types.str;
      default = "6h";
      description = "systemd timer interval used after each successful run.";
    };

    count = lib.mkOption {
      type = types.ints.between 1 8;
      default = 2;
      description = "Number of recent Bing images to fetch and pass to the setter.";
    };

    preferUhd = lib.mkOption {
      type = types.bool;
      default = true;
      description = "Try the derived UHD image URL before falling back to Bing's advertised URL.";
    };

    hyprlandPrimaryMonitor = lib.mkOption {
      type = types.nullOr types.str;
      default = null;
      description = "Preferred Hyprland monitor for the primary Bing wallpaper.";
    };

    nasaApod = {
      enable = lib.mkEnableOption "NASA APOD secondary wallpaper";

      apiKey = lib.mkOption {
        type = types.str;
        default = "DEMO_KEY";
        description = "NASA APOD API key.";
      };

      preferHd = lib.mkOption {
        type = types.bool;
        default = true;
        description = "Prefer APOD hdurl over url when APOD returns an image.";
      };
    };
  };

  config = lib.mkIf cfg.enable {
    assertions = [
      {
        assertion = cfg.user != "";
        message = "my.nixos.features.desktop.bingWallpaper requires a non-empty user.";
      }
    ];

    home-manager.users.${cfg.user}.my.hm.features.bingWallpaper = {
      enable = true;
      inherit (cfg) market interval count preferUhd hyprlandPrimaryMonitor nasaApod;
    };
  };
}
