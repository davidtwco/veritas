{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.configs.qt;
in
{
  options.veritas.configs.qt.enable = mkEnableOption "qt configuration";

  config = mkIf cfg.enable {
    qt = {
      enable = true;
      platformTheme = "gtk";
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
