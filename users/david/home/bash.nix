{ config, pkgs, lib, ... }:

# This file contains the configuration for bash.

{
  # bash isn't used, so just make sure there's a sane minimal configuration in place.
  programs.bash = with lib; {
    enable = true;
    profileExtra = mkIf (config.veritas.david.dotfiles.isNonNixOS) (
      config.programs.zsh.profileExtra +
      # Can't set a shell on WSL 1 and can't set the shell to zsh from `.nix-profile` in WSL 2.
      (optionalString
        config.veritas.david.dotfiles.isWsl
        "exec ${config.home.profileDirectory}/bin/zsh")
    );
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
