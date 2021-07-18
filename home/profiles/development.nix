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
      # Alternative version control systems.
      mercurial
      breezy
      subversion
      pijul
      # Incremental git merging/rebasing.
      gitAndTools.git-imerge
      # Remove large files from repositories.
      gitAndTools.git-filter-repo
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
      # Utility for creating gists from stdout.
      gist
      # ClusterSSH with tmux.
      tmux-cssh
      # Used by `breakpointHook` in nixpkgs.
      cntr
      # DNS client
      dogdns
      # tmux collaboration
      tmate
      # Socket forwarding
      socat
    ];

    veritas.configs = {
      cargo.enable = true;
      ccache.enable = true;
      direnv.enable = true;
      eyaml.enable = true;
      fish.withDeveloperTools = true;
      flake8.enable = true;
      gdb.enable = true;
      lorri.enable = true;
      neovim.withDeveloperTools = true;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
