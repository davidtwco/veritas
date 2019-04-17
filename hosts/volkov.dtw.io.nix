{ config, lib, pkgs, ... }:

{
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "18.09"; # Did you read the comment?
  nix.maxJobs = lib.mkDefault 16;

  # Boot Loader {{{
  # ===========
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [ "nvme" "xhci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-amd" ];
  boot.extraModulePackages = [ ];
  # }}}

  # Networking {{{
  # ==========
  networking.hostName = "dtw-volkov";
  networking.wireless.enable = false;
  # }}}

  # Filesystems {{{
  # ===========
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/03f05dab-f4cc-4f94-901c-e17092319eb4";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/7120-97E9";
      fsType = "vfat";
    };

  swapDevices = [ ];
  # }}}

  # Hardware {{{
  # ========
  hardware.opengl =
    { enable = true;
      extraPackages = with pkgs; [ intel-ocl ];
    };
  # }}}

  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ../common.nix
    ../services/users.nix
    ../services/xorg.nix
    ../services/dev.nix
    ../services/ssh.nix
    ../services/audio.nix
  ];
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2
