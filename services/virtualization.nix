{ config, pkgs, ... }:

{
  # Install KVM kernel modules for AMD and Intel.
  boot.kernelModules = [ "kvm-amd" "kvm-intel" ];

  virtualisation = {
    # Enable docker.
    docker = {
      autoPrune = {
        dates = "weekly";
        enable = true;
      };
      enable = true;
    };
    # Use libvirtd to manage virtual machines.
    libvirtd.enable = true;
    # Allow LXC/LXD containers.
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
        david veth lxcbr0 10
      '';
    };
    lxd.enable = true;
  };

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
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2
