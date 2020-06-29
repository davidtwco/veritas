{ pkgs ? import <nixpkgs> { } }:

# Generic shell for working on Rust projects quickly without setting up a dedicated environment,
# will require `--impure` with `nix dev-shell`.

pkgs.mkShell {
  name = "generic-nightly-rust";
  buildInputs = with pkgs; [
    # Nightly rust toolchain - not reproducible!
    latest.rustChannels.nightly.rust

    git

    pkg-config
    libxml2
    openssl

    # Required by bindgen
    clang
    clang-tools
    llvmPackages.llvm
    llvmPackages.libclang.lib

    # Required for nested shells in lorri to work correctly.
    bashInteractive
  ];

  # Always show backtraces.
  RUST_BACKTRACE = 1;

  # Set `LIBCLANG_PATH` for bindgen.
  LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
