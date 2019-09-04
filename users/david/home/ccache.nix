{ pkgs, ... }:

# This file contains the configuration for ccache.

{
  home.file.".ccache/ccache.conf".text = ''
    compression = true
    max_size = 50G
  '';
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
