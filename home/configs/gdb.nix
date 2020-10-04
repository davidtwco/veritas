{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.configs.gdb;

  # gcc contains libstdc++ pretty printers.
  libStdCppPrettyPrinters = pkgs.fetchgit {
    url = "git://gcc.gnu.org/git/gcc.git";
    rev = "7df1534c136e2556ca10d3a60d2b2cc77544dbc8";
    sha256 = "sha256-wVo/EoiXkmetb0gJ9FM6Hgj9JoicGk/UU7MND/J4NaM=";
  };
  # LLVM provides pretty printers for LLVM data types.
  llvmPrettyPrinters = pkgs.fetchgit {
    url = "https://github.com/llvm/llvm-project.git";
    rev = "89074bdc813a0e8bd9ff5e69e76b134dc7ae1bd9";
    sha256 = "sha256-ZeJvQmg7D3f8korxJMf3F0ow3bjZ6GmhUbl/dNpL9jw=";
  };
in
{
  options.veritas.configs.gdb.enable = mkEnableOption "gdb configuration";

  config = mkIf cfg.enable {
    home.file.".gdbinit".text = ''
      # Add libstdc++ pretty printers.
      python
      import sys
      sys.path.insert(0, '${libStdCppPrettyPrinters}/libstdc++-v3/python')
      from libstdcxx.v6.printers import register_libstdcxx_printers
      register_libstdcxx_printers (None)
      end

      # Allow gdb to autoload from the nix store.
      add-auto-load-safe-path /nix/store

      # Add LLVM pretty printers.
      source ${llvmPrettyPrinters}/llvm/utils/gdb-scripts/prettyprinters.py

      # Don't ever step into the standard library or system packages.
      skip -gfi /usr/**/*
      skip -gfi /nix/store/**/*

      # Set a coloured prompt.
      set extended-prompt \[\e[0;33m\]❯ \[\e[0m\]
    '';
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
