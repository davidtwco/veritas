{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.configs.feh;
in
{
  options.veritas.configs.feh.enable = mkEnableOption "feh configuration";

  config = mkIf cfg.enable {
    programs.feh.enable = true;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
