{ config, pkgs, lib, ... }:

# This file installs fonts and enables fontconfig.

{
  fonts.fontconfig.enable = config.veritas.david.dotfiles.isNonNixOS;

  home.packages = lib.lists.optionals (!config.veritas.david.dotfiles.headless) (
    with pkgs; [
      meslo-lg
      source-code-pro
      source-sans-pro
      source-serif-pro
      font-awesome_5
      inconsolata
      siji
      material-icons
      powerline-fonts
      roboto
      roboto-mono
      roboto-slab
      iosevka
    ]
  );
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
