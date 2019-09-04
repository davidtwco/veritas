{ pkgs, ... }:

# This file contains the configuration for manpages.

{
  # Don't clear the screen when leaving man.
  home.sessionVariables."MANPAGER" = "less -X";
  # Install home-manager manpages.
  manual.manpages.enable = true;
  # Install man output for any Nix packages.
  programs.man.enable = true;
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
