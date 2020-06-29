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
