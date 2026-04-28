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
      format = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional format override.";
      };
      formatAlt = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional alternate format override.";
      };
      interval = lib.mkOption {
        type = lib.types.int;
        default = 5;
        description = "Network block update interval.";
      };
      inactiveFormat = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Format shown when the interface is inactive.";
      };
      missingFormat = lib.mkOption {
        type = lib.types.str;
        default = "";
        description = "Format shown when the interface is missing.";
      };
    };
  };

  renderOptionalLine = name: value:
    lib.optionalString (value != null) ''${name} = "${value}"'';

  renderIconOverrides =
    lib.concatStringsSep "\n"
    (lib.mapAttrsToList (name: value: ''${name} = "${value}"'') ({
        net_up = "";
        net_down = "";
      }
      // barCfg.iconOverrides));

  renderBlockIconOverrides = iconOverrides:
    lib.optionalString (iconOverrides != {}) ''
      [block.icons_overrides]
      ${lib.concatStringsSep "\n" (lib.mapAttrsToList (name: value: ''${name} = "${value}"'') iconOverrides)}
    '';

  mkNetBlock = nd: let
    formatByType = {
      wired = {
        format = " $speed_down.eng(prefix:M)⇅$speed_up.eng(prefix:M)";
        formatAlt = " {$ip}";
      };
      wifi = {
        format = " $icon {$signal_strength|} $speed_down.eng(prefix:M)⇅$speed_up.eng(prefix:M)";
        formatAlt = " {$ssid} {$ip}";
      };
      mobile = {
        format = " $icon {$signal_strength|} $speed_down.eng(prefix:M)⇅$speed_up.eng(prefix:M)";
        formatAlt = " {$ssid} {$ip}";
      };
    };
    defaults = formatByType.${nd.type};
    format = nd.format or null;
    formatAlt = nd.formatAlt or null;
  in ''

    [[block]]
    block = "net"
    device = "${nd.device}"
    format = "${lib.optionalString (format != null) format}${lib.optionalString (format == null) defaults.format}"
    format_alt = "${lib.optionalString (formatAlt != null) formatAlt}${lib.optionalString (formatAlt == null) defaults.formatAlt}"
    interval = ${toString nd.interval}
    inactive_format = "${nd.inactiveFormat}"
    missing_format = "${nd.missingFormat}"
  '';

  defaultGpuFormat = {
    amd = "$icon $utilization ";
    nvidia = "$icon $utilization";
  };

  gpuBlock = gpu: ''

    [[block]]
    block = "${gpu}_gpu"
    format = "${lib.optionalString (barCfg.gpuFormat != null) barCfg.gpuFormat}${lib.optionalString (barCfg.gpuFormat == null) defaultGpuFormat.${gpu}}"
    ${lib.optionalString (gpu == "amd") ''format_alt = "$icon MEM: $vram_used_percents ($vram_used/$vram_total) "''}
    ${lib.optionalString (barCfg.gpuInterval != null) "interval = ${toString barCfg.gpuInterval}"}
  '';

  soundClick = lib.optionalString (barCfg.sound.clickCommand != null) ''
    [[block.click]]
    button = "left"
    cmd = "${barCfg.sound.clickCommand}"
  '';

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
      ${renderIconOverrides}
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
      format = "${barCfg.disk.format}"
      ${renderOptionalLine "format_alt" barCfg.disk.formatAlt}
      ${renderBlockIconOverrides barCfg.disk.iconOverrides}

      [[block]]
      block = "memory"
      format = "${barCfg.memory.format}"
      format_alt = "${barCfg.memory.formatAlt}"

      [[block]]
      block = "cpu"
      info_cpu = 20
      warning_cpu = 50
      critical_cpu = 90
      ${renderOptionalLine "format" barCfg.cpu.format}
    ''

    (lib.optionalString (barCfg.gpu != null) (gpuBlock barCfg.gpu))

    ''
      [[block]]
      block = "sound"
      format = "${barCfg.sound.sinkFormat}"
      headphones_indicator = true
      ${soundClick}

      [[block]]
      block = "sound"
      device_kind = "source"
      format = "${barCfg.sound.sourceFormat}"
    ''

    (lib.concatMapStringsSep "\n" mkNetBlock barCfg.networkDevices)

    ''
      [[block]]
      block = "time"
      interval = 5
      format = " $timestamp.datetime(f:'${barCfg.timeFormat}')"
      ${renderOptionalLine "timezone" barCfg.timezone}
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
    iconOverrides = lib.mkOption {
      type = lib.types.attrsOf lib.types.str;
      default = {};
      description = "Icon overrides merged after net_up/net_down defaults.";
    };
    disk = {
      format = lib.mkOption {
        type = lib.types.str;
        default = "$icon $available.eng(w:2)";
        description = "Disk space block format.";
      };
      formatAlt = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Optional disk space alternate format.";
      };
      iconOverrides = lib.mkOption {
        type = lib.types.attrsOf lib.types.str;
        default = {};
        description = "Disk block icon overrides.";
      };
    };
    memory = {
      format = lib.mkOption {
        type = lib.types.str;
        default = "$mem_avail.eng(prefix:Gi)";
        description = "Memory block format.";
      };
      formatAlt = lib.mkOption {
        type = lib.types.str;
        default = "$swap_used_percents.eng(w:2)";
        description = "Memory block alternate format.";
      };
    };
    cpu.format = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional CPU block format.";
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
    gpuFormat = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      default = null;
      description = "Optional GPU block format override.";
    };
    gpuInterval = lib.mkOption {
      type = lib.types.nullOr lib.types.int;
      default = 3;
      description = "Optional GPU block interval.";
    };
    sound = {
      sinkFormat = lib.mkOption {
        type = lib.types.str;
        default = " $icon {$volume|}";
        description = "Sound output block format.";
      };
      sourceFormat = lib.mkOption {
        type = lib.types.str;
        default = " $icon {$volume|}";
        description = "Sound input block format.";
      };
      clickCommand = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        default = null;
        description = "Command run when clicking the sound block.";
      };
    };
    timeFormat = lib.mkOption {
      type = lib.types.str;
      default = "%R";
      description = "strftime-compatible time block format.";
    };
    timezone = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
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
