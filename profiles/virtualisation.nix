{ config, pkgs, options, lib, ... }:

# This profile installs virtualization daemons and tools.

with lib;
let
  cfg = config.veritas.profiles.virtualisation;
in
{
  options.veritas.profiles.virtualisation.enable =
    mkEnableOption "Enable virtualisation daemons and tools";

  config = mkIf cfg.enable {
    # Install KVM kernel modules for AMD and Intel.
    boot.kernelModules = [ "kvm-amd" "kvm-intel" ];

    environment.systemPackages = with pkgs; [
      # Interact with VM
      looking-glass-client
      # Receive audio from VM
      scream-receivers
      # Virtual machine manager
      virtmanager
    ];

    # Idempotently ensures the needed folders are there for LXC.
    system.activationScripts = {
      "lxc-folders" = {
        text = ''
          mkdir -p /var/cache/lxc
          mkdir -p /var/lib/lxc/rootfs
        '';
        deps = [];
      };
    };

    systemd = {
      network.networks = {
        # Don't manage the interfaces created by Docker, libvirt or VirtualBox.
        "60-docker".extraConfig = ''
          [Match]
          Name=docker*

          [Link]
          Unmanaged=yes
        '';
        "61-virbr".extraConfig = ''
          [Match]
          Name=virbr*

          [Link]
          Unmanaged=yes
        '';
        "62-lxdbr".extraConfig = ''
          [Match]
          Name=lxdbr*

          [Link]
          Unmanaged=yes
        '';
        "63-veth".extraConfig = ''
          [Match]
          Name=veth*

          [Link]
          Unmanaged=yes
        '';
        "64-vboxnet".extraConfig = ''
          [Match]
          Name=vboxnet*

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
          "ExecStart" = "${pkgs.scream-receivers}/bin/scream-ivshmem-pulse /dev/shm/scream";
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
          # Network interface piggy-backed from libvirt.
          lxc.network.type = veth
          lxc.network.link = virbr0
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
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
