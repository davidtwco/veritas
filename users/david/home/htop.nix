{ pkgs, ... }:

# This file contains the configuration for htop.

{
  programs.htop = {
    enable = true;
    detailedCpuTime = true;
    showThreadNames = true;
    treeView = true;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
