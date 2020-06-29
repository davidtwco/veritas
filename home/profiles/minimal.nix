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
        feh.enable = mkForce false;
        jq.enable = mkForce false;
        mail.enable = mkForce false;
      };
      profiles.common.withTools = mkDefault false;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
