{ config, pkgs, ... }:

{
  # Install KVM kernel modules for AMD and Intel.
  boot.kernelModules = [ "kvm-amd" "kvm-intel" ];

  # Use libvirtd to manage virtual machines.
  virtualisation.libvirtd.enable = true;

  # Enable docker.
  virtualisation.docker = {
    autoPrune = {
      dates = "weekly";
      enable = true;
    };
    enable = true;
  };

  # Enable lxc and lxd.
  virtualisation.lxc = {
    enable = true;
    lxcfs.enable = true;
  };
  virtualisation.lxd.enable = true;
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2
