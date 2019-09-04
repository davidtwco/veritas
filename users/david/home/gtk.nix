{ config, pkgs, lib, ... }:

# This file contains the configuration for GTK.

{
  gtk = lib.mkIf (!config.veritas.david.dotfiles.isWsl) {
    enable = true;
    gtk3.extraConfig = {
      "gtk-application-prefer-dark-theme" = 1;
    };
    iconTheme = {
      package = pkgs.paper-icon-theme;
      name = "Paper";
    };
    theme = {
      package = pkgs.arc-theme;
      name = "Arc-Darker";
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
