{ config, pkgs, ... }:

# This file contains the configuration for rofi.

{
  programs.rofi = {
    enable = true;
    font = "Iosevka 12";
    terminal = "${pkgs.alacritty}/bin/alacritty";
    theme = "Arc-Dark";
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
