{ config, pkgs, lib, ... }:

# This file contains the configuration for Redshift.

{
  services.redshift = lib.mkIf (!config.veritas.david.dotfiles.headless) {
    enable = true;
    latitude = "55.953251";
    longitude = "-3.188267";
    temperature = {
      day = 5500;
      night = 4800;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
