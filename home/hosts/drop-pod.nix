{ config, lib, pkgs, options, ... }:

# `drop-pod` contains the configuration that applies to the drop-pod bundle on `davidtw.co` (a
# self-contained self-extracting executable which contains my tools and their configurations).

with lib;
{
  home.stateVersion = "20.09";

  veritas = {
    drop-pod = {
      enable = true;
      packages =
        # Tools expected by the Neovim configuration
        config.veritas.configs.neovim.additionalTools
        ++ [
          # Neovim (with configuration)
          config.programs.neovim.finalPackage
        ];
      shell = "${pkgs.fish}/bin/fish";
    };

    # Disable GnuPG's fish configuration so it doesn't start an agent in the drop-pod.
    configs.gnupg.withFishConfiguration = mkForce false;

    profiles = {
      common.enable = true;
      minimal.enable = true;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
