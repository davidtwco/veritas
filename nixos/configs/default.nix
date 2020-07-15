{ ... }:

{
  imports = [
    ./networking.nix
    ./user.nix
    ./virtualisation.nix
    ./yubikey.nix
  ];
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
