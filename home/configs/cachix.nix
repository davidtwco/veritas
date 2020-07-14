{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.configs.cachix;
in
{
  options.veritas.configs.cachix.enable = mkEnableOption "cachix secret keys and config";

  config = mkIf cfg.enable {
    xdg.configFile."cachix/cachix.dhall".source = ../secrets/cachix;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
