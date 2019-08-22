{ config, pkgs, lib, ... }:

# This host is in WSL and only uses Nix for dotfiles, symlink this to `home.nix`.

{
  # Import the main home-manager configuration.
  imports = [ ../users/david/home ];

  # Add the `veritas.david` configuration options. These are also used from NixOS.
  options.veritas.david = import ../users/david/module.nix { inherit lib; };
  config.veritas.david.dotfiles.isWsl = true;
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
