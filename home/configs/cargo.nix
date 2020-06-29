{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.configs.cargo;
in
{
  options.veritas.configs.cargo.enable = mkEnableOption "Cargo configuration";

  config = mkIf cfg.enable {
    # Add credentials for deploying to Cargo.
    home.file.".cargo/credentials".source = ../secrets/cargo-credentials;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
