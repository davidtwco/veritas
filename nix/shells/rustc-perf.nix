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
    pkg-config
    openssl
    zlib

    # rustup for toolchain management
    rustup
    rustup-toolchain-install-master
  ];

  # Always show backtraces.
  RUST_BACKTRACE = 1;
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
