{ config, lib, pkgs, ... }:

{
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
  nix.maxJobs = lib.mkDefault 12;

  # Automatically update the system periodically.
  system.autoUpgrade.enable = true;

  # Boot Loader {{{
  # ===========
  boot.loader.grub.enable = true;
  boot.loader.grub.version = 2;
  boot.loader.grub.devices = ["/dev/nvme0n1" "/dev/nvme1n1"];

  boot.initrd.availableKernelModules = [ "xhci_pci" "ahci" "nvme" "usbhid" "usb_storage" "sd_mod" ];
  boot.kernelModules = [ "kvm-intel" ];
  boot.extraModulePackages = [ ];
  # }}}

  # Networking {{{
  # ==========
  networking = {
    hostName = "dtw-avendahl";

    firewall = {
      allowPing = true;
      enable = true;
      pingLimit = "--limit 1/minute --limit-burst 5";
    };

    useNetworkd = true;

    wireless.enable = false;
  };
  # }}}

  # Filesystems {{{
  # ===========
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/9c941292-69fb-4dcd-89e3-f255712700a5";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/99b75992-0079-438c-ae96-a4edbfae52ab";
      fsType = "ext3";
    };

  swapDevices =
    [ { device = "/dev/disk/by-uuid/eb08dc81-dddc-4763-8a13-9b8270836df4"; }
    ];
  # }}}

  # OpenSSH {{{
  # =======
  # Change the SSH port to being port scanned all the time.
  services.openssh.ports = [ 28028 ];
  # }}}

  # Cron {{{
  # ====
  services.cron.systemCronJobs = [
    # Run `workman update` to keep unused Rust working directories fresh every day at 2am.
    "0 2 * * *      david      $HOME/.local/bin/workman-update-cron-for-rust"
  ];
  # }}}

  imports = [
    <nixpkgs/nixos/modules/installer/scan/not-detected.nix>
    ../common.nix
    ../services/dev.nix
    ../services/ssh.nix
    ../services/users.nix
    ../services/mail.nix
  ];
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2
