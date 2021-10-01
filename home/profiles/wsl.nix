{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.profiles.wsl;
in
{
  options.veritas.profiles.wsl.enable = mkEnableOption "wsl compatibility";

  config = mkIf cfg.enable {
    veritas = {
      configs = {
        bash.wslCompatibility = true;
        gnupg.wslCompatibility = true;
        tmux.wslCompatibility = true;
      };
      profiles.homeManagerOnly.enable = true;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
