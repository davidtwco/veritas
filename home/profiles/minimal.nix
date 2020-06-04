{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.profiles.minimal;
in
{
  options.veritas.profiles.minimal.enable = mkEnableOption "minimal configuration";

  config = mkIf cfg.enable {
    veritas = {
      configs = {
        feh.enable = mkPriority false;
        jq.enable = mkPriority false;
        mail.enable = mkPriority false;
      };
      profiles = {
        common.withTools = mkDefault false;
        development = mkDefault false;
      };
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
