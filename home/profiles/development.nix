{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.profiles.development;
in
{
  options.veritas.profiles.development.enable = mkEnableOption "development configuration";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      # Haskell toolchain manager - normally wouldn't install this globally and instead rely on
      # `shell.nix` files, but using the Nix-integration in stack is easier and avoids the
      # downsides of having stack installed globally for my purposes.
      stack
      # Symbol demangler for Rust.
      rustfilt
      # Alternative version control systems.
      mercurial
      breezy
      subversion
      pijul
      # Incremental git merging/rebasing.
      gitAndTools.git-imerge
      # Tools for manipulating patch files.
      patchutils
      # Benchmarking.
      hyperfine
      # Codebase statistics.
      tokei
      # Library call tracer.
      ltrace
      # System call tracer.
      strace
      # Tools for manipulating binaries.
      binutils
      # Performance analysis tools.
      linuxPackages.perf
      # eBPF tracing language and frontend.
      linuxPackages.bpftrace
      # Utility for creating gists from stdout.
      gist
      # ClusterSSH with tmux.
      tmux-cssh
      # Yet another diff highlighting tool
      diffr
      # Personal project for managing working directories.
      workman
      # Used by `breakpointHook` in nixpkgs.
      cntr
      # Download rust toolchains from CI builds.
      rustup-toolchain-install-master
    ];

    veritas.configs = {
      cargo.enable = true;
      ccache.enable = true;
      direnv.enable = true;
      eyaml.enable = true;
      flake8.enable = true;
      gdb.enable = true;
      lorri.enable = true;
      neovim.withDeveloperTools = true;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
