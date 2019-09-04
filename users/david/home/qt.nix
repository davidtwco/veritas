{ config, pkgs, lib, ... }:

# This file contains the configuration for Qt.

{
  qt = lib.mkIf (!config.veritas.david.dotfiles.isWsl) {
    enable = true;
    platformTheme = "gtk";
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
