{ config, pkgs, lib, ... }:

# This file contains the configuration for bash.

{
  # bash isn't used, so just make sure there's a sane minimal configuration in place.
  programs.bash = {
    enable = true;
    profileExtra = lib.mkIf (config.veritas.david.dotfiles.isNonNixOS) (
      config.programs.zsh.profileExtra +
      # Can't set a shell on WSL 1 and can't set the shell to zsh from `.nix-profile` in WSL 2.
      (if config.veritas.david.dotfiles.isWsl
       then "exec ${config.home.profileDirectory}/bin/zsh"
       else "")
    );
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
