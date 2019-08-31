{ config, pkgs, lib, ... }:

# This host is in WSL and only uses Nix for dotfiles, symlink this to `home.nix`.

{
  # Import the main home-manager configuration.
  imports = [ ../users/david/home ];

  # Add the `veritas.david` configuration options. These are also used from NixOS.
  options.veritas.david = import ../users/david/options.nix { inherit config; inherit lib; };
  config.veritas.david = {
    dotfiles.isWsl = true;
    hostName = "dtw-intrepid";
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
