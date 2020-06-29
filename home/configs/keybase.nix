{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.configs.kbfs;
in
{
  options.veritas.configs.kbfs.enable = mkEnableOption "kbfs configuration";

  config = mkIf cfg.enable {
    services.kbfs.enable = true;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
