{ config, pkgs, ... }:

# This file contains the configuration for the Xsession.

let
  cfg = config.veritas.david;
in
{
  xsession = {
    enable = !cfg.dotfiles.headless;
    initExtra = ''
      # Load the monitor configuration.
      ${pkgs.autorandr}/bin/autorandr --load veritas

      # Set wallpaper.
      ${pkgs.hsetroot}/bin/hsetroot -solid "#${cfg.colourScheme.xsession.wallpaper}"
    '';
    pointerCursor = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ-AA";
      size = 24;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
