{ lib, ... }:

{
  imports = [
    ./common.nix
    ./desktop.nix
    ./development.nix
    ./minimal.nix
    ./wsl.nix
  ];

  config.veritas.profiles.common.enable = lib.mkDefault true;
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
