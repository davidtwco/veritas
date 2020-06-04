{ lib, system }:

builtins.map (overlay: import overlay { inherit lib system; }) [
  ./plex.nix
  ./vaapi.nix
]

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
