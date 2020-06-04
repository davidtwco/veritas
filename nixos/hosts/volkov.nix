{ ... }:

{
  boot = {
    blacklistedKernelModules = [ "nouveau" ];

    initrd = {
      availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod" ];

      luks.devices = [
        {
          name = "root";
          device = "/dev/nvme0n1p2";
          preLVM = true;
        }
      ];
    };

    loader = {
      efi.canTouchEfiVariables = true;
      systemd-boot.enable = true;
    };

    kernelParams = [ "nomodeset" "video=vesa:off" "vga=normal" ];

    vesa = false;
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/15e4642b-713f-4e33-bb57-bccba586ca9d";
      fsType = "btrfs";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/54D5-DC0D";
      fsType = "vfat";
    };
    "/data" = {
      device = "/dev/disk/by-uuid/f09ffaad-ce2e-479d-857c-7cd1605c51d3";
      fsType = "btrfs";
    };
  };

  hardware = {
    cpu.intel.updateMicrocode = true;
    wooting.enable = true;
  };

  networking = {
    interfaces.eno1.useDHCP = true;
    wireless.enable = false;
  };

  nix.maxJobs = lib.mkDefault 8;

  services.xserver.videoDrivers = [ "nvidia" ];

  system.stateVersion = "19.03";

  veritas.profiles = {
    desktop.enable = true;
    development.enable = true;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
