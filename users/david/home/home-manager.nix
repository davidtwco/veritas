{ config, pkgs, ... }:

# This file contains the configuration for home-manager.

{
  # Set the `stateVersion` for home-manager.
  home.stateVersion = "19.03";

  # Let home-manager manage itself when not using home-manager as a NixOS module.
  programs.home-manager.enable = config.veritas.david.dotfiles.isNonNixOS;
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
