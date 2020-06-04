{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.configs.htop;
in
{
  options.veritas.configs.htop.enable = mkEnableOption "htop configuration";

  config = mkIf cfg.enable {
    programs.htop = {
      enable = true;
      detailedCpuTime = true;
      showThreadNames = true;
      treeView = true;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
