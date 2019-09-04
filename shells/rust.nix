{ pkgs ? import <nixpkgs> {} }:

# This file contains a development shell for working on rustc.

pkgs.mkShell rec {
  name = "rust";
  buildInputs = [
    pkgs.git
    pkgs.pythonFull
    pkgs.gnumake
    pkgs.cmake
    pkgs.curl
    pkgs.clang

    # If `llvm.ninja` is `true` in `config.toml`.
    pkgs.ninja
    # If `llvm.ccache` is `true` in `config.toml`.
    pkgs.ccache
    # Used by debuginfo tests.
    pkgs.gdb
    # Used with emscripten target.
    pkgs.nodejs

    # Local toolchain is added to rustup to avoid needing to set up
    # environment variables.
    pkgs.rustup
  ];
}
