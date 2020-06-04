{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.configs.info;
in
{
  options.veritas.configs.info.enable = mkEnableOption "info configuration";

  config = mkIf cfg.enable {
    programs.info.enable = true;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
