{ ... }:

# This file just imports all of the profiles defined in this folder.

{
  imports = [
    ./desktop-environment.nix
    ./media-server.nix
    ./virtualisation.nix
  ];
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
