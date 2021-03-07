{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.profiles.wsl;
in
{
  options.veritas.profiles.wsl.enable = mkEnableOption "wsl compatibility";

  config = mkIf cfg.enable {
    home.packages = with pkgs; [
      (
        # `home-manager` utility does not work with Nix's flakes yet.
        writeScriptBin "veritas-wsl-switch-config" ''
          #! ${runtimeShell} -e
          nix build ".#homeManagerConfigurations.$(hostname).activationPackage"
          ./result/activate
        ''
      )
    ];

    veritas.configs = {
      bash.wslCompatibility = true;
      fish.wslCompatibility = true;
      gnupg.wslCompatibility = true;
      tmux.wslCompatibility = true;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
