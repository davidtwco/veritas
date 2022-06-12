{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.configs.direnv;
in
{
  options.veritas.configs.direnv.enable = mkEnableOption "direnv configuration";

  config = mkIf cfg.enable {
    programs.direnv.enable = true;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
