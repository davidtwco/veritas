{ pkgs ? import <nixpkgs> { } }:

# This file contains a development shell for running and working on rustc-perf.
pkgs.mkShell rec {
  name = "rustc-perf";
  buildInputs = with pkgs; [
    # Dependencies from `rustc-perf`'s Dockerfile
    git
    curl
    gnumake
    cmake
    file
    python

    pkg-config
    expat
    freetype
    openssl
    xorg.libX11
    zlib

    rustup
  ];

  # Always show backtraces.
  RUST_BACKTRACE = 1;
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
