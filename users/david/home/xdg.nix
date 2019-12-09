{ pkgs, config, ... }:

# This file contains the configuration for xdg.

{
  xdg = {
    enable = true;
    mime.enable = config.xdg.enable;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
