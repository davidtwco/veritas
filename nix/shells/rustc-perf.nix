{ pkgs ? import <nixpkgs> {
    # `pkgs` is provided by the flake normally, but `nix-shell` and `lorri` both use the default
    # value, so make sure that our custom packages are available using an overlay.
    overlays = [
      (_: super: {
        measureme = super.callPackage ../packages/measureme { };

        rustup-toolchain-install-master =
          super.callPackage ../packages/rustup-toolchain-install-master { };
      })
    ];
  }
}:

# This file contains a development shell for running and working on rustc-perf.
pkgs.clangStdenv.mkDerivation rec {
  name = "rustc-perf";
  buildInputs = with pkgs; [
    # Dependencies from `rustc-perf`'s Dockerfile
    git
    curl
    gnumake
    cmake
    file
    python2Full
    python3Full

    autoconf213
    expat
    freetype
    llvm
    openssl
    perl
    pkg-config
    python37Packages.rpm
    watchman
    xorg.libX11
    zlib

    valgrind
    linuxPackages.perf
    oprofile

    rustup
    rustup-toolchain-install-master
    measureme

    # Required for nested shells in lorri to work correctly.
    bashInteractive
  ];

  # Always show backtraces.
  RUST_BACKTRACE = 1;

  # Required by bindgen.
  LIBCLANG_PATH = "${pkgs.llvmPackages.libclang.lib}/lib";

  # Disable compiler hardening.
  hardeningDisable = [ "all" ];
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
