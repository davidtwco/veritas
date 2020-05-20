{ config, pkgs, ... }:

# This file contains the configuration for picom.

{
  services.picom = {
    enable = true;
    noDockShadow = false;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
