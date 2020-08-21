{ lib, pkgs, ... }:

{
  boot = {
    blacklistedKernelModules = [ "nouveau" ];

    initrd = {
      availableKernelModules = [
        "nvme"
        "ahci"
        "xhci_pci"
        "usbhid"
        "usb_storage"
        "sd_mod"
      ];
      kernelModules = [ "dm-snapshot" ];
    };

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };

    kernelPackages = pkgs.linuxPackages_latest;

    # Required for 2080Ti
    kernelParams = [ "nomodeset" "video=vesa:off" "vga=normal" ];

    # Required for Intel Wi-Fi AX200 card.
    kernelModules = [ "iwlwifi" ];

    vesa = false;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/a449eeb7-aaf0-4b82-968c-519ff2c94a89";
      fsType = "btrfs";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/AA8B-F94D";
      fsType = "vfat";
    };
  };

  hardware = {
    cpu.amd.updateMicrocode = true;
    nvidia.modesetting.enable = true;
    wooting.enable = true;
    zsa.enable = true;
  };

  networking.interfaces.enp36s0.useDHCP = true;

  nix.maxJobs = lib.mkDefault 24;

  services = {
    openvpn.servers.codeplay = {
      autoStart = false;
      config = ''
        script-security 2
        config /etc/nixos/nixos/secrets/openvpn-codeplay
        up ${pkgs.update-systemd-resolved}/libexec/openvpn/update-systemd-resolved
        up-restart
        down ${pkgs.update-systemd-resolved}/libexec/openvpn/update-systemd-resolved
        down-pre
      '';
    };

    xserver = {
      # Disable monitors going to sleep.
      monitorSection = ''
        Option "DPMS" "false"
      '';

      screenSection = ''
        Option "AllowIndirectGLXProtocol" "off"
        Option "TripleBuffer" "on"
      '';
      videoDrivers = [ "nvidiaBeta" ];
    };
  };

  system.stateVersion = "19.09";

  # Disable `systemd-udev-settle` - it's required and just adds 1s to boot time.
  # See nixpkgs#25311.
  systemd.services.systemd-udev-settle.serviceConfig.ExecStart = [
    ""
    "${pkgs.coreutils}/bin/true"
  ];

  # Avoid issues with dual-booting.
  time.hardwareClockInLocalTime = true;

  veritas.profiles = {
    common.enable = true;
    desktop.enable = true;
    development.enable = true;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
