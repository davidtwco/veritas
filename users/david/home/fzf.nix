{ config, pkgs, ... }:

# This file contains the configuration for fzf.

{
  home.sessionVariables = {
    # Configure fzf to use ripgrep.
    "FZF_DEFAULT_COMMAND" =
      "${pkgs.ripgrep}/bin/rg --files --hidden --follow -g \"!{.git}\" 2>/dev/null";
    "FZF_CTRL_T_COMMAND" = config.home.sessionVariables."FZF_DEFAULT_COMMAND";
    "FZF_DEFAULT_OPTS" = "";
  };

  programs.fzf.enable = true;
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
