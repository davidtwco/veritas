{ lib, ... }:

{
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
    interfaces.eno1.useDHCP = true;
    wireless.enable = false;
  };

  nix.maxJobs = lib.mkDefault 4;

  services.ddclient = {
    enable = true;
    use = "web, web=myip.dnsomatic.com";
    domains = [ "campaglia" ];
    protocol = "dyndns2";
    server = "updates.dnsomatic.com";
    username = "davidtwco";
    password = builtins.readFile ../secrets/ddclient-password;
  };

  system.stateVersion = "19.03";

  veritas.profiles.media-server.enable = true;

  virtualisation = {
    docker.autoPrune.enable = true;

    # Use `services.datadog-agent` once NixOS/nixpkgs#105221 is fixed.
    oci-containers.containers.dd-agent = {
      autoStart = true;
      environmentFiles = [ ../secrets/datadog-env ];
      environment = {
        "DD_APM_ENABLED" = "true";
        "DD_PROCESS_AGENT_ENABLED" = "true";
      };
      image = "gcr.io/datadoghq/agent:7";
      volumes = [
        "/etc/passwd:/etc/passwd:ro"
        "/var/run/docker.sock:/var/run/docker.sock:ro"
        "/proc/:/host/proc/:ro"
        "/sys/fs/cgroup/:/host/sys/fs/cgroup:ro"
        "/data:/host/data:ro"
      ];
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
