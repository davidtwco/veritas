{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.configs.autorandr;
in
{
  options.veritas.configs.autorandr = {
    enable = mkEnableOption "autorandr configuration for X";

    profile = mkOption {
      type = types.attrs;
      description = "Configuration for autorandr.";
    };
  };

  config = mkIf cfg.enable {
    programs.autorandr = {
      enable = true;
      profiles."veritas" = cfg.profile;
    };

    xsession.initExtra = ''
      # Load the monitor configuration.
      ${pkgs.autorandr}/bin/autorandr --load veritas
    '';
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
