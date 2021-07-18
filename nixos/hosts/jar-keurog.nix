{ config, lib, pkgs, ... }:

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

    # Required for 2080Ti
    kernelParams = [ "nomodeset" "video=vesa:off" "vga=normal" ];

    # Required for Intel Wi-Fi AX200 card.
    kernelModules = [ "iwlwifi" ];

    vesa = false;
  };

  environment.systemPackages = with pkgs; [ wally-cli ];

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
    keyboard.zsa.enable = true;
    nvidia = {
      modesetting.enable = true;
      nvidiaPersistenced = false;
      package = config.boot.kernelPackages.nvidiaPackages.beta;
    };
    wooting.enable = true;
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
      videoDrivers = [ "nvidia" ];
    };
  };

  system.stateVersion = "19.09";

  # Avoid issues with dual-booting.
  time.hardwareClockInLocalTime = true;

  veritas.profiles = {
    common.enable = true;
    desktop.enable = true;
    development.enable = true;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
