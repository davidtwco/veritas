{ config, lib, pkgs, ... }:

# This profile installs virtualization daemons and tools.

with lib;
let
  cfg = config.veritas.configs.virtualisation;
in
{
  options.veritas.configs.virtualisation = {
    enable = mkEnableOption "virtualisation daemons and tools";

    virtualbox = {
      enable = mkEnableOption "VirtualBox";

      headless = mkOption {
        default = true;
        type = types.bool;
        description = "Use VirtualBox without a desktop environment.";
      };
    };
  };

  config = mkIf cfg.enable {
    # Install KVM kernel modules for AMD and Intel.
    boot.kernelModules = [ "kvm-amd" "kvm-intel" ];

    environment.systemPackages = with pkgs; [
      # Virtual machine manager
      virtmanager
      # Utilities for bridge interfaces
      bridge-utils
    ];

    networking.firewall.trustedInterfaces = [
      "virbr0"
      "virbr0-nic"
      "lxdbr0"
      "docker0"
      "vboxnet0"
    ];

    # Idempotently ensures the needed folders are there for LXC.
    system.activationScripts = {
      "lxc-folders" = {
        text = ''
          mkdir -p /var/cache/lxc
          mkdir -p /var/lib/lxc/rootfs
        '';
        deps = [ ];
      };
    };

    systemd = {
      network.networks = {
        # Don't manage the interfaces created by Docker, libvirt or VirtualBox.
        "21-virtualization-interfaces".extraConfig = ''
          [Match]
          Name=docker* virbr* lxdbr* veth* vboxnet*

          [Link]
          Unmanaged=yes
        '';
      };

      tmpfiles.rules = [
        "f /dev/shm/looking-glass 0660 ${config.users.users.david.name} qemu-libvirtd -"
        "f /dev/shm/scream 0660 ${config.users.users.david.name} qemu-libvirtd -"
      ];

      user.services.scream-ivshmem = {
        enable = true;
        description = "Scream IVSHMEM";
        serviceConfig = {
          "ExecStart" = "${pkgs.scream}/bin/scream-ivshmem-pulse /dev/shm/scream";
          "Restart" = "always";
        };
        wantedBy = [ "multi-user.target" ];
        requires = [ "pulseaudio.service" ];
      };
    };

    virtualisation = {
      docker = {
        autoPrune = {
          dates = "weekly";
          enable = true;
        };
        enable = true;
      };

      libvirtd = {
        enable = true;
        qemuOvmf = true;
        qemuRunAsRoot = false;
        onBoot = "ignore";
        onShutdown = "shutdown";
      };

      lxc = {
        defaultConfig = ''
          lxc.network.type = veth
          # Link to the virbr0 interface from libvirt.
          lxc.network.link = virbr0
          # Name of the interface within the container
          lxc.network.name = eth0
          lxc.network.flags = up

          # Don't limit LXC with apparmor.
          lxc.aa_profile = unconfined
        '';
        enable = true;
        lxcfs.enable = true;
        usernetConfig = ''
          ${config.users.users.david.name} veth lxcbr0 10
        '';
      };

      lxd.enable = true;

      virtualbox.host = {
        enable = cfg.virtualbox.enable;
        headless = cfg.virtualbox.headless;
      };
    };

    # Enable VirtualBox by default if virtualisation is enabled.
    veritas.configs.virtualisation.virtualbox.enable = mkDefault true;

    # Allow the root user to remap the uid of the `david` user.
    users.users.root.subUidRanges = [{ count = 1; startUid = config.users.users.david.uid; }];
  };
}
