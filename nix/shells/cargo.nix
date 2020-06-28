{ pkgs ? import <nixpkgs> { } }:

# This file contains a development shell for running and working on Cargo.
pkgs.mkShell rec {
  name = "rustc-perf";
  buildInputs = with pkgs; [
    git
    curl
    gnumake
    pkg-config
    openssl

    rustup
  ];

  # Always show backtraces.
  RUST_BACKTRACE = 1;
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
