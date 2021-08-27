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
      settings = {
        detailed_cpu_time = true;
        show_thread_names = true;
        tree_view = true;
      };
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
