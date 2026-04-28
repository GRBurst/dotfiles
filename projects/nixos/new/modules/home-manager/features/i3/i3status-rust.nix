{
  config,
  lib,
  ...
}: let
  cfg = config.my.hm.features.i3;
  barCfg = cfg.statusBar;

  networkDeviceType = lib.types.submodule {
    options = {
      device = lib.mkOption {
        type = lib.types.str;
        description = "Network device name.";
      };
      type = lib.mkOption {
        type = lib.types.enum ["wired" "wifi" "mobile"];
        default = "wired";
        description = "Network device type.";
      };
    };
  };

  mkNetBlock = nd: let
    formatByType = {
      wired = ''
        format = " $speed_down.eng(prefix:M)⇅$speed_up.eng(prefix:M)"
        format_alt = " {$ip}"'';
      wifi = ''
        format = " $icon {$signal_strength|} $speed_down.eng(prefix:M)⇅$speed_up.eng(prefix:M)"
        format_alt = " {$ssid} {$ip}"'';
      mobile = ''
        format = " $icon {$signal_strength|} $speed_down.eng(prefix:M)⇅$speed_up.eng(prefix:M)"
        format_alt = " {$ssid} {$ip}"'';
    };
  in ''

    [[block]]
    block = "net"
    device = "${nd.device}"
    ${formatByType.${nd.type}}
    interval = 5
    inactive_format = ""
    missing_format = ""
  '';

  gpuBlock = {
    amd = ''

      [[block]]
      block = "amd_gpu"
      format = "$icon $utilization "
      format_alt = "$icon MEM: $vram_used_percents ($vram_used/$vram_total) "
      interval = 3
    '';
    nvidia = ''

      [[block]]
      block = "nvidia_gpu"
      format = "$icon $utilization"
      interval = 3
    '';
  };

  tomlContent = lib.concatStringsSep "\n" (lib.filter (s: s != "") [
    ''
      icons_format = "{icon}"

      [theme]
      theme = "${barCfg.theme}"

      [theme.overrides]
      separator = ""

      [icons]
      icons = "${barCfg.iconSet}"

      [icons.overrides]
      net_up = ""
      net_down = ""
    ''

    ''
      [[block]]
      block = "disk_space"
      path = "/"
      info_type = "available"
      alert_unit = "GB"
      interval = 20
      warning = 20.0
      alert = 10.0
      format = "$icon $available.eng(w:2)"

      [[block]]
      block = "memory"
      format = "$mem_avail.eng(prefix:Gi)"
      format_alt = "$swap_used_percents.eng(w:2)"

      [[block]]
      block = "cpu"
      info_cpu = 20
      warning_cpu = 50
      critical_cpu = 90
    ''

    (lib.optionalString (barCfg.gpu != null) gpuBlock.${barCfg.gpu})

    ''
      [[block]]
      block = "sound"
      format = " $icon {$volume|}"
      headphones_indicator = true

      [[block]]
      block = "sound"
      device_kind = "source"
      format = " $icon {$volume|}"
    ''

    (lib.concatMapStringsSep "\n" mkNetBlock barCfg.networkDevices)

    ''
      [[block]]
      block = "time"
      interval = 5
      format = " $timestamp.datetime(f:'%R')"
      timezone = "${barCfg.timezone}"
    ''

    barCfg.extraBlocks
  ]);
in {
  options.my.hm.features.i3.statusBar = {
    theme = lib.mkOption {
      type = lib.types.str;
      default = "slick";
      description = "i3status-rust theme name.";
    };
    iconSet = lib.mkOption {
      type = lib.types.str;
      default = "awesome6";
      description = "i3status-rust icon set.";
    };
    networkDevices = lib.mkOption {
      type = lib.types.listOf networkDeviceType;
      default = [];
      description = "Network interfaces to monitor.";
    };
    gpu = lib.mkOption {
      type = lib.types.nullOr (lib.types.enum ["amd" "nvidia"]);
      default = null;
      description = "GPU vendor for monitoring block. null disables.";
    };
    timezone = lib.mkOption {
      type = lib.types.str;
      default = "Europe/Berlin";
      description = "Timezone for the time block.";
    };
    extraBlocks = lib.mkOption {
      type = lib.types.lines;
      default = "";
      description = "Additional TOML blocks.";
    };
  };

  config = lib.mkIf cfg.enable {
    xdg.configFile."i3status-rust/config.toml".text = tomlContent;
  };
}
