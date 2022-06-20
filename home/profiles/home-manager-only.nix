{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.profiles.homeManagerOnly;
in
{
  options.veritas.profiles.homeManagerOnly.enable = mkEnableOption "home-manager only support";

  config = mkIf cfg.enable {
    veritas.configs = {
      fish.homeManagerOnlyCompatibility = true;
      mail.withSystemdNotifyUnit = false;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
