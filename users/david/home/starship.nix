{ config, pkgs, ... }:

# This file contains the configuration for starship. This isn't used yet.

{
  # Install Starship package.
  home.packages = with pkgs; [ unstable.starship ];

  # Write configuration for starship.
  xdg.configFile."starship.toml".text = ''
    [battery]
    disabled = true

    [directory]
    truncate_to_repo = false

    [git_branch]
    symbol = ""

    [git_state]
    rebase = "rebasing"
    merge = "merging"
    revert = "reverting"
    cherry_pick = "cherry-picking"
    bisect = "bisecting"

    [golang]
    disabled = true

    [ruby]
    disabled = true

    [nodejs]
    disabled = true

    [package]
    disabled = true

    [python]
    disabled = true

    [rust]
    disabled = true
  '';
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
