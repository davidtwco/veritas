{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.configs.gdb;

  libStdCppPrettyPrinters = pkgs.stdenv.mkDerivation {
    name = "libstdcxx-printers-${pkgs.gcc-unwrapped.version}";
    src = pkgs.gcc-unwrapped.src;
    phases = [ "unpackPhase" "installPhase" ];
    installPhase = ''
      mkdir -p $out
      cp -r libstdc++-v3/python/* $out/
    '';
  };
in
{
  options.veritas.configs.gdb.enable = mkEnableOption "gdb configuration";

  config = mkIf (cfg.enable && !pkgs.stdenv.isDarwin) {
    home.file.".gdbinit".text = ''
      # Add libstdc++ pretty printers.
      python
      import sys
      sys.path.insert(0, '${libStdCppPrettyPrinters}')
      from libstdcxx.v6.printers import register_libstdcxx_printers
      register_libstdcxx_printers (None)
      end

      # Allow gdb to autoload from the nix store and /usr.
      add-auto-load-safe-path /lib
      add-auto-load-safe-path /usr
      add-auto-load-safe-path /nix/store

      # Add LLVM pretty printers.
      source ${pkgs.llvmPackages_14.llvm.src}/llvm/utils/gdb-scripts/prettyprinters.py

      # Don't ever step into the standard library or system packages.
      skip -gfi /lib/**/*
      skip -gfi /usr/**/*
      skip -gfi /nix/store/**/*

      # Set a coloured prompt.
      set extended-prompt \[\e[0;33m\]❯ \[\e[0m\]
    '';
  };
}
