# Do not modify this file!  It was generated by ‘nixos-generate-config’
# and may be overwritten by future invocations.  Please make changes
# to /etc/nixos/configuration.nix instead.
{ config, lib, pkgs, ... }:

{
  imports =
    [ <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "mpt3sas" "nvme" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];

  fileSystems."/" =
    { device = "/dev/disk/by-uuid/1c1552a3-aff0-4f45-b560-76e1897f96ab";
      fsType = "ext4";
      label = "nixos";
    };

  fileSystems."/tmp" =
    { device = "tmpfs";
      fsType = "tmpfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/2BD9-238E";
      fsType = "vfat";
      label = "boot";
    };

  fileSystems."/media/data" =
    { device = "/dev/disk/by-uuid/bd09798f-1676-47a0-b113-b735d4e811f5";
      fsType = "ext4";
      label = "data";
      options = [ "x-systemd.automount" "noauto" ];
    };

  fileSystems."/media/windows" =
    { device = "/dev/disk/by-uuid/B4AE3C45AE3BFE84";
      fsType = "ntfs-3g";
      label = "windows";
      options = [ "uid=jelias" "gid=users" "dmask=022" "fmask=133" "x-systemd.automount" "noauto" "x-systemd.idle-timeout=1min" ];
    };

  fileSystems."/media/ntfs" =
    { device = "/dev/disk/by-uuid/1AF86B704887DADD";
      fsType = "ntfs-3g";
      label = "ntfs";
      options = [ "uid=jelias" "gid=users" "dmask=022" "fmask=133" "x-systemd.automount" "noauto" "x-systemd.idle-timeout=1min" ];
    };

  boot.initrd.luks.devices."data".device = "/dev/disk/by-uuid/677297d7-e77c-457b-a5a8-d2457766882c";

  # fileSystems."/media/ateam/ateam" =
  #   { device = "//ateam/ateam";
  #     fsType = "cifs";
  #     options = [ "uid=jelias" "username=x" "password=" "x-systemd.automount" "noauto" "_netdev" "x-systemd.device-timeout=30" ];
  #   };

  # fileSystems."/media/ateam/upload" =
  #   { device = "//ateam/upload";
  #     fsType = "cifs";
  #     options = [ "uid=jelias" "username=x" "password=" "x-systemd.automount" "noauto" "_netdev" "x-systemd.device-timeout=30" ];
  #   };

  swapDevices = [ ];

  nix.maxJobs = lib.mkDefault 4;
  # powerManagement.cpuFreqGovernor = "powersave";
}