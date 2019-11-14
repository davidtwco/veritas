{ config, pkgs, ... }:

# This file contains the configuration for autorandr.

{
  programs.autorandr = {
    enable = !config.veritas.david.dotfiles.headless;
    profiles."veritas" = config.veritas.david.dotfiles.autorandrProfile;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
