{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.configs.picom;
in
{
  options.veritas.configs.picom.enable = mkEnableOption "picom configuration";

  config = mkIf cfg.enable {
    services.picom = {
      enable = true;
      noDockShadow = true;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
