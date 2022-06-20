{ pkgs ? import <nixpkgs> {
    # `pkgs` is provided by the flake normally, but `nix-shell` and `lorri` both use the default
    # value, so make sure that our custom packages are available using an overlay.
    overlays = [
      (_: super: {
        cargo-bisect-rustc = super.callPackage ../packages/cargo-bisect-rustc { };

        measureme = super.callPackage ../packages/measureme { };

        rustfilt = super.callPackage ../packages/rustfilt { };

        rustup-toolchain-install-master =
          super.callPackage ../packages/rustup-toolchain-install-master { };
      })
    ];
  }
}:

# This file contains a development shell for working on rustc.
let
  # Custom Vim configuration to disable ctags on directories we never want to look at.
  lvimrc = pkgs.writeText "rustc-lvimrc" ''
    let g:gutentags_ctags_exclude = [
    \   "src/llvm-project",
    \   "src/librustdoc/html",
    \   "src/doc",
    \   "src/ci",
    \   "src/bootstrap",
    \   "*.md"
    \ ]

    " Only use rust-analyzer.
    let g:ale_linters['rust'] = [ 'analyzer' ]

    " Same configuration as `x.py fmt`.
    let g:ale_rust_rustfmt_options = '--edition 2018 --unstable-features --skip-children'
    let g:ale_rust_rustfmt_executable = './build/x86_64-unknown-linux-gnu/stage0/bin/rustfmt'

    augroup RustcAU
      au!
      " Disable ALE in Clippy, rustfmt isn't used.
      au! BufRead,BufNewFile,BufEnter **/src/tools/clippy/** :ALEDisableBuffer
      au! BufRead,BufNewFile,BufEnter **/src/tools/clippy/** :let b:ale_fix_on_save = 0
      " Disable ALE in cranelift, rustfmt isn't used.
      au! BufRead,BufNewFile,BufEnter **/compiler/rustc_codegen_cranelift/** :ALEDisableBuffer
      au! BufRead,BufNewFile,BufEnter **/compiler/rustc_codegen_cranelift/** :let b:ale_fix_on_save = 0
      " Disable ALE in tests - exact formatting is sometimes important.
      au! BufRead,BufNewFile,BufEnter **/src/test/** :ALEDisableBuffer
      au! BufRead,BufNewFile,BufEnter **/src/test/** :let b:ale_fix_on_save = 0
    augroup END
  '';

  ripgrepConfig =
    let
      # Files that are ignored by ripgrep when searching.
      ignoreFile = pkgs.writeText "rustc-rgignore" ''
        configure
        config.toml.example
        x.py
        LICENSE-MIT
        LICENSE-APACHE
        COPYRIGHT
        **/*.txt
        **/*.toml
        **/*.yml
        **/*.nix
        *.md
        src/ci
        src/doc/
        src/etc/
        src/llvm-emscripten/
        src/llvm-project/
        src/rtstartup/
        src/rustllvm/
        src/stdsimd/
        src/tools/rls/rls-analysis/test_data/
      '';
    in
    pkgs.writeText "rustc-ripgreprc" "--ignore-file=${ignoreFile}";
in
# Switch back to `clangMultiStdenv` after NixOS/nixpkgs#94023 is fixed (need to switch temporarily when rebuilding LLVM).
pkgs.gccMultiStdenv.mkDerivation rec {
  name = "rustc";
  buildInputs = with pkgs; [
    git
    pythonFull
    gnumake
    cmake
    curl

    pkg-config
    libxml2
    ncurses
    swig
    openssl

    # If `llvm.ninja` is `true` in `config.toml`.
    ninja
    # If `llvm.ccache` is `true` in `config.toml`.
    ccache
    # Used by debuginfo tests.
    gdb
    # Used with emscripten target.
    nodejs

    # Local toolchain is added to rustup to avoid needing to set up
    # environment variables.
    rustup

    # Useful tools for working on upstream issues.
    cargo-bisect-rustc
    measureme
    rustfilt
    rustup-toolchain-install-master

    # Required for nested shells in lorri to work correctly.
    bashInteractive
  ];

  # Environment variables consumed by tooling.
  RIPGREP_CONFIG_PATH = ripgrepConfig;
  DTW_LOCALVIMRC = lvimrc;

  # Always show backtraces.
  RUST_BACKTRACE = 1;

  # Disable compiler hardening - required for LLVM.
  hardeningDisable = [ "all" ];
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
