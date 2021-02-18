{ lib, pkgs, ... }:

{
  boot = {
    initrd = {
      availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
      kernelModules = [ "dm-snapshot" ];
    };

    loader = {
      grub.enable = true;
      grub.version = 2;
      grub.devices = [ "/dev/nvme0n1" "/dev/nvme1n1" ];
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/991d2060-032a-4b31-9d90-dcb1f8f2aa34";
      fsType = "btrfs";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/196cb06a-640d-477d-a26b-29ac197dc55a";
      fsType = "ext4";
    };
  };

  hardware.cpu.amd.updateMicrocode = true;

  networking = {
    useDHCP = false;
    interfaces.enp35s0.useDHCP = true;
  };

  nix.maxJobs = lib.mkDefault 16;

  system.stateVersion = "20.09";

  veritas = {
    profiles = {
      common.enable = true;
      development.enable = true;
    };
    services.nixops-dns.enable = lib.mkForce false;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
