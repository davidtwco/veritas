{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.configs.jq;
in
{
  options.veritas.configs.jq.enable = mkEnableOption "jq configuration";

  config = mkIf cfg.enable {
    programs.jq.enable = true;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
