{ config, pkgs, ... }:

# This file contains the configuration for starship. This isn't used yet.

{
  # Install Starship package.
  home.packages = with pkgs; [ starship-nightly ];

  # Write configuration for starship.
  xdg.configFile."starship.toml".text = ''
    [battery]
    disabled = true

    [character]
    style_success = "#85678F"
    style_failure = "#A54242"

    [cmd_duration]
    style = "#DE935F"

    [directory]
    style = "#5F819D"
    truncate_to_repo = false

    [git_branch]
    symbol = ""
    style = "#6b6b6b"

    [git_state]
    rebase = "rebasing"
    merge = "merging"
    revert = "reverting"
    cherry_pick = "cherry-picking"
    bisect = "bisecting"
    am = "am"
    am_or_rebase = "am/rebasing"
    style = "yellow"

    [git_status]
    conflicted = "⨯"
    ahead = "↑"
    behind = "↓"
    diverged = "⇅"
    untracked = ""
    stashed = ""
    modified = "∙"
    staged = ""
    renamed = ""
    deleted = ""
    style = "#6b6b6b"

    [golang]
    disabled = true

    [hostname]
    style = "#8C9440"

    [jobs]
    style = "#5F819D"

    [line_break]
    disabled = false

    [nix_shell]
    style = "#A54242"
    use_name = true

    [nodejs]
    disabled = true

    [package]
    disabled = true

    [python]
    disabled = true

    [ruby]
    disabled = true

    [rust]
    disabled = true

    [time]
    disabled = true

    [username]
    style_root = "#A54242"
    style_user = "#DE935F"
  '';
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
