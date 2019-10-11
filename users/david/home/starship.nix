{ config, pkgs, ... }:

# This file contains the configuration for starship. This isn't used yet.

let
  colours = config.veritas.david.colourScheme;
in
{
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    package = pkgs.unstable.starship;
    settings = with colours; {
      "aws"."disabled" = true;
      "battery"."disabled" = true;
      "character" = {
        "style_success" = "#${basic.magenta}";
        "style_failure" = "#${basic.red}";
      };
      "cmd_duration"."style" = "#${basic.yellow}";
      "conda"."disabled" = true;
      "directory" = {
        "style" = "#${basic.blue}";
        "truncation_length" = 8;
        "truncate_to_repo" = false;
      };
      "dotnet"."disabled" = true;
      "env_var"."disabled" = true;
      "git_branch" = {
        "symbol" = "";
        "style" = "#${starship.mutedGrey}";
      };
      "git_state" = {
        "rebase" = "rebasing";
        "merge" = "merging";
        "revert" = "reverting";
        "cherry_pick" = "cherry-picking";
        "bisect" = "bisecting";
        "am" = "am";
        "am_or_rebase" = "am/rebasing";
        "style" = "#${basic.yellow}";
      };
      "git_status" = {
        "conflicted" = "⨯";
        "ahead" = "↑";
        "behind" = "↓";
        "diverged" = "⇅";
        "untracked" = "";
        "stashed" = "";
        "modified" = "∙";
        "staged" = "";
        "renamed" = "";
        "deleted" = "";
        "style" = "#${starship.mutedGrey}";
      };
      "golang"."disabled" = true;
      "hostname"."style" = "#${basic.green}";
      "jobs" = {
        "style" = "#${basic.black}";
        "symbol" = "";
        "threshold" = 0;
      };
      "kubernetes"."disabled" = true;
      "nix_shell" = {
        "style" = "#${basic.red}";
        "use_name" = true;
      };
      "memory_usage"."disabled" = true;
      "java"."disabled" = true;
      "nodejs"."disabled" = true;
      "package"."disabled" = true;
      "python"."disabled" = true;
      "ruby"."disabled" = true;
      "rust"."disabled" = true;
      "time"."disabled" = true;
      "username" = {
        "style_root" = "#${basic.red}";
        "style_user" = "#${basic.yellow}";
      };
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
