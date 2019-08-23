{ config, lib, pkgs, ... }:

{
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
  nix.maxJobs = lib.mkDefault 4;

  # Automatically update the system periodically.
  system.autoUpgrade.enable = false;

  # Boot Loader {{{
  # ===========
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [ "xhci_pci" "ehci_pci" "ahci" "usbhid" "usb_storage" "sd_mod" "sr_mod" ];
  boot.supportedFilesystems = [ "ntfs" ];
  # }}}

  # Networking {{{
  # ==========
  networking.hostName = "dtw-campaglia";
  networking.wireless.enable = false;
  networking.useDHCP = true;

  services.ddclient = {
    enable = true;
    use = "web, web=myip.dnsomatic.com";
    domains = [ "campaglia" ];
    protocol = "dyndns2";
    server = "updates.dnsomatic.com";
    username = "davidtwco";
    password = builtins.readFile ../secrets/ddclient.password;
  };
  # }}}

  # Filesystems {{{
  # ===========
  fileSystems."/" =
    { device = "/dev/disk/by-uuid/4bd2471e-40a7-45a7-85b3-d9cbaeceae8f";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    { device = "/dev/disk/by-uuid/7890-1735";
      fsType = "vfat";
    };

  fileSystems."/data" =
    { device = "/dev/disk/by-uuid/84ddf5cd-d603-4e8b-8c5c-cf095c17973c";
      fsType = "btrfs";
    };
  # }}}

  # Monitoring {{{
  # ==========
  services.datadog-agent = {
    apiKeyFile = ../secrets/datadog.api_key;
    enable = true;
    enableLiveProcessCollection = true;
    enableTraceAgent = true;
  };
  # }}}

  # Microcode {{{
  # =========
  hardware.cpu.intel.updateMicrocode = true;
  # }}}

  # Veritas {{{
  # =======
  veritas.profiles.media-server.enable = true;
  # }}}

  imports = [
    ../common.nix
    ../services/media.nix
    ../services/networking.nix
    ../services/ssh.nix
    ../services/virtualization.nix
  ];
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
