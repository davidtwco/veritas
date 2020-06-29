{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.configs.starship;
in
{
  options.veritas.configs.starship = {
    enable = mkEnableOption "starship configuration";

    colourScheme.mutedGrey = mkOption {
      default = "6B6B6B";
      description = "Define the colour for starship's muted grey.";
      example = "FFFFFF";
      type = types.str;
    };
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableBashIntegration = false;
      enableFishIntegration = true;
      package = pkgs.starship;
      settings = with config.veritas.profiles.common.colourScheme; {
        "aws"."disabled" = true;
        "battery"."disabled" = true;
        "character" = {
          "style_success" = "#${magenta}";
          "style_failure" = "#${red}";
        };
        "cmd_duration"."style" = "#${yellow}";
        "conda"."disabled" = true;
        "crystal"."disabled" = true;
        "directory" = {
          "style" = "#${blue}";
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
          "style" = "#${cfg.colourScheme.mutedGrey}";
        };
        "git_commit" = {
          "disabled" = false;
          "style" = "#${cfg.colourScheme.mutedGrey}";
        };
        "git_state" = {
          "rebase" = "rebasing";
          "merge" = "merging";
          "revert" = "reverting";
          "cherry_pick" = "cherry-picking";
          "bisect" = "bisecting";
          "am" = "am";
          "am_or_rebase" = "am/rebasing";
          "style" = "#${yellow}";
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
          "style" = "#${cfg.colourScheme.mutedGrey}";
          "suffix" = ") ";
          "untracked" = "";
        };
        "golang"."disabled" = true;
        "haskell"."disabled" = true;
        "hg_branch"."disabled" = true;
        "hostname"."style" = "#${green}";
        "java"."disabled" = true;
        "jobs" = {
          "style" = "#${black}";
          "symbol" = "";
          "threshold" = 0;
        };
        "julia"."disabled" = true;
        "kubernetes"."disabled" = true;
        "memory_usage"."disabled" = true;
        "nix_shell" = {
          "symbol" = "";
          "style" = "#${red}";
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
          "style_root" = "#${red}";
          "style_user" = "#${yellow}";
        };
      };
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
