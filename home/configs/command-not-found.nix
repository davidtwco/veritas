{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.configs.command-not-found;
in
{
  options.veritas.configs.command-not-found.enable =
    mkEnableOption "command-not-found configuration";

  config = mkIf cfg.enable {
    programs.command-not-found.enable = true;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
