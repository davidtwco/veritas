{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.configs.redshift;
in
{
  options.veritas.configs.redshift.enable = mkEnableOption "redshift configuration";

  config = mkIf cfg.enable {
    services.redshift = {
      enable = true;
      latitude = "55.953251";
      longitude = "-3.188267";
      temperature = {
        day = 5500;
        night = 4800;
      };
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
