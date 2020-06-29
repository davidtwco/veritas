{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.configs.ccache;
in
{
  options.veritas.configs.ccache.enable = mkEnableOption "ccache configuration";

  config = mkIf cfg.enable {
    home.file.".ccache/ccache.conf".text = ''
      compression = true
      max_size = 50G
    '';
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
