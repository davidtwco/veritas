{ config, pkgs, ... }:

# This file contains the configuration for starship. This isn't used yet.
let
  colours = config.veritas.david.colourScheme;
in
{
  programs.starship = {
    enable = true;
    enableBashIntegration = false;
    enableFishIntegration = true;
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
      "crystal"."disabled" = true;
      "directory" = {
        "style" = "#${basic.blue}";
        "truncation_length" = 8;
        "truncate_to_repo" = false;
      };
      "docker_context"."disabled" = true;
      "dotnet"."disabled" = true;
      "elixir"."disabled" = true;
      "elm"."disabled" = true;
      "env_var"."disabled" = true;
      "erlang"."disabled" = true;
      "git_branch" = {
        "symbol" = "";
        "style" = "#${starship.mutedGrey}";
      };
      "git_commit" = {
        "disabled" = false;
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
        "ahead" = "↑";
        "behind" = "↓";
        "conflicted" = "✖";
        "deleted" = "";
        "diverged" = "⇅";
        "modified" = "※";
        "prefix" = "(";
        "renamed" = "";
        "staged" = "";
        "stashed" = "";
        "style" = "#${starship.mutedGrey}";
        "suffix" = ") ";
        "untracked" = "";
      };
      "golang"."disabled" = true;
      "haskell"."disabled" = true;
      "hg_branch"."disabled" = true;
      "hostname"."style" = "#${basic.green}";
      "java"."disabled" = true;
      "jobs" = {
        "style" = "#${basic.black}";
        "symbol" = "";
        "threshold" = 0;
      };
      "julia"."disabled" = true;
      "kubernetes"."disabled" = true;
      "memory_usage"."disabled" = true;
      "nix_shell" = {
        "symbol" = "";
        "style" = "#${basic.red}";
        "use_name" = false;
      };
      "nodejs"."disabled" = true;
      "package"."disabled" = true;
      "php"."disabled" = true;
      "prompt"."scan_timeout" = 10;
      "python"."disabled" = true;
      "ruby"."disabled" = true;
      "rust"."disabled" = true;
      "singularity"."disabled" = true;
      "terraform"."disabled" = true;
      "time"."disabled" = true;
      "username" = {
        "style_root" = "#${basic.red}";
        "style_user" = "#${basic.yellow}";
      };
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
