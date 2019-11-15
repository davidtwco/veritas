{ config, lib, pkgs, ... }:

{
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.09"; # Did you read the comment?
  nix.maxJobs = lib.mkDefault 24;

  imports = [ ../common.nix ];

  # Filesystems {{{
  # ===========
  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/a449eeb7-aaf0-4b82-968c-519ff2c94a89";
      fsType = "btrfs";
    };

  fileSystems."/home" =
    {
      device = "/dev/disk/by-uuid/f973fbf5-1f7f-4655-b5c9-0bba1ac85f50";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/AA8B-F94D";
      fsType = "vfat";
    };

  swapDevices = [];
  # }}}

  # Hardware {{{
  # ========
  boot = {
    blacklistedKernelModules = [ "nouveau" "nvidia" ];
    # Use the `vfio-pci` driver for the RTX 2080 Ti.
    extraModprobeConfig = ''
      options vfio-pci ids=10de:1e07,10de:10f7
    '';
    initrd = {
      availableKernelModules = [
        "nvme"
        "ahci"
        "xhci_pci"
        "usbhid"
        "usb_storage"
        "sd_mod"
        "vfio_pci"
      ];
      kernelModules = [ "dm-snapshot" ];
    };
    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };
    kernelPackages = pkgs.linuxPackages_latest;
    kernelParams = [ "nomodeset" "video=vesa:off" "vga=normal" "amd_iommu=on" "pci_aspm=off" ];
    kernelModules = [
      # Virtualization
      "vfio_pci"
      "vfio"
      "vfio_iommu_type1"
      "vfio_virqfd"
      # Wi-Fi
      "iwlwifi"
    ];
    vesa = false;
  };

  services.xserver.videoDrivers = [ "nvidia" ];
  # }}}

  # Microcode {{{
  # =========
  hardware.cpu.amd.updateMicrocode = true;
  # }}}

  # Networking {{{
  # ==========
  networking = {
    hostName = "dtw-jar-keurog";
    interfaces.enp36s0.useDHCP = true;
    interfaces.enp46s0.useDHCP = true;
    wireless.enable = true;
  };
  # }}}

  # Veritas {{{
  # ========
  veritas = {
    profiles.virtualisation.enable = true;
    david.dotfiles = {
      autorandrProfile = {
        fingerprint = {
          "DP-0" = "00ffffffffffff001e6d077742dc0400061c0104b53c22789f3e31ae5047ac270c50542108007140818081c0a9c0d1c08100010101014dd000a0f0703e803020650c58542100001a286800a0f0703e800890650c58542100001a000000fd00283d878738010a202020202020000000fc004c472048445220344b0a20202001ed0203197144900403012309070783010000e305c000e3060501023a801871382d40582c450058542100001e565e00a0a0a029503020350058542100001a00000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000029";
          "HDMI-0" = "00ffffffffffff001e6d067749dc0400061c0103803c2278ea3e31ae5047ac270c50542108007140818081c0a9c0d1c081000101010108e80030f2705a80b0588a0058542100001e04740030f2705a80b0588a0058542100001a000000fd00283d1e873c000a202020202020000000fc004c472048445220344b0a20202001c3020341714d9022201f1203040161605d5e5f230907076d030c001000b83c20006001020367d85dc401788003e30f0003681a00000101283d00e305c000e3060501023a801871382d40582c450058542100001e565e00a0a0a029503020350058542100001a0000000000000000000000000000000000000000000000000000ee";
        };
        config = {
          "DP-0" = {
            dpi = 163;
            enable = true;
            mode = "3840x2160";
            position = "3840x0";
            rate = "60.00";
          };
          "HDMI-0" = {
            dpi = 163;
            enable = true;
            mode = "3840x2160";
            position = "0x0";
            primary = true;
            rate = "60.00";
          };
        };
      };
      headless = false;
      uiScale = 1.5;
    };
  };
  # }}}
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
