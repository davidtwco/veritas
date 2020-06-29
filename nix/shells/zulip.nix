{ pkgs ? import <nixpkgs> { } }:

pkgs.mkShell {
  buildInputs = with pkgs; [
    vagrant
    docker
    git
    openssh

    # Required for nested shells in lorri to work correctly.
    bashInteractive
  ];
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
