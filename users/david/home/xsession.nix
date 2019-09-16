{ config, pkgs, ... }:

# This file contains the configuration for the Xsession.

{
  xsession = {
    enable = !config.veritas.david.dotfiles.headless;
    initExtra = ''
      # Load the monitor configuration.
      ${pkgs.autorandr}/bin/autorandr --load ${config.veritas.david.hostName}

      # Set wallpaper.
      ${pkgs.feh}/bin/feh --bg-scale '${../wallpaper.jpg}'
    '';
    pointerCursor = {
      package = pkgs.vanilla-dmz;
      name = "Vanilla-DMZ-AA";
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
