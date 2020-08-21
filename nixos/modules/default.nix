{ ... }:

# This file just imports all of the modules defined in this folder.

{
  imports = [
    ./nixops-dns.nix
    ./per-user-vpn.nix
    ./zsa.nix
  ];
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
