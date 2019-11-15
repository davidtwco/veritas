{ config, lib, pkgs, ... }:

{
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
  nix.maxJobs = lib.mkDefault 4;

  imports = [ ../common.nix ];

  boot = {
    initrd.availableKernelModules = [
      "xhci_pci"
      "ehci_pci"
      "ahci"
      "usbhid"
      "usb_storage"
      "sd_mod"
      "sr_mod"
    ];
    loader = {
      systemd-boot.enable = true;
      efi.canTouchEfiVariables = true;
    };
    supportedFilesystems = [ "ntfs" ];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/4bd2471e-40a7-45a7-85b3-d9cbaeceae8f";
      fsType = "btrfs";
    };
    "/boot" = {
      device = "/dev/disk/by-uuid/7890-1735";
      fsType = "vfat";
    };
    "/data" = {
      device = "/dev/disk/by-uuid/84ddf5cd-d603-4e8b-8c5c-cf095c17973c";
      fsType = "btrfs";
    };
  };

  hardware.cpu.intel.updateMicrocode = true;

  networking = {
    hostName = "dtw-campaglia";
    interfaces.eno1.useDHCP = true;
    wireless.enable = false;
  };

  services = {
    datadog-agent = {
      apiKeyFile = ../secrets/datadog.api_key;
      enable = true;
      enableLiveProcessCollection = true;
      enableTraceAgent = true;
    };
    ddclient = {
      enable = true;
      use = "web, web=myip.dnsomatic.com";
      domains = [ "campaglia" ];
      protocol = "dyndns2";
      server = "updates.dnsomatic.com";
      username = "davidtwco";
      password = builtins.readFile ../secrets/ddclient.password;
    };
  };

  veritas.profiles = {
    media-server.enable = true;
    virtualisation.enable = true;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
