{ config, lib, pkgs, ... }:

{
  # This value determines the NixOS release with which your system is to be
  # compatible, in order to avoid breaking some software such as database
  # servers. You should change this only after NixOS release notes say you
  # should.
  system.stateVersion = "19.03"; # Did you read the comment?
  nix.maxJobs = lib.mkDefault 4;

  imports = [ ../common.nix ];

  # Boot Loader {{{
  # ===========
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ehci_pci"
    "ahci"
    "usbhid"
    "usb_storage"
    "sd_mod"
    "sr_mod"
  ];
  boot.supportedFilesystems = [ "ntfs" ];
  # }}}

  # Filesystems {{{
  # ===========
  fileSystems."/" =
    {
      device = "/dev/disk/by-uuid/4bd2471e-40a7-45a7-85b3-d9cbaeceae8f";
      fsType = "btrfs";
    };

  fileSystems."/boot" =
    {
      device = "/dev/disk/by-uuid/7890-1735";
      fsType = "vfat";
    };

  fileSystems."/data" =
    {
      device = "/dev/disk/by-uuid/84ddf5cd-d603-4e8b-8c5c-cf095c17973c";
      fsType = "btrfs";
    };
  # }}}

  # Microcode {{{
  # =========
  hardware.cpu.intel.updateMicrocode = true;
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

  # Networking {{{
  # ==========
  networking = {
    hostName = "dtw-campaglia";
    interfaces.eno1.useDHCP = true;
    wireless.enable = false;
  };

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

  # Veritas {{{
  # =======
  veritas.profiles = {
    media-server.enable = true;
    virtualisation.enable = true;
  };
  # }}}
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
