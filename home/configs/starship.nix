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
        "character" = {
          "success_symbol" = "[❯](#${magenta})";
          "error_symbol" = "[❯](#${red})";
          "vicmd_symbol" = "[❮](#${magenta})";
        };
        "cmd_duration"."style" = "#${yellow}";
        "directory" = {
          "style" = "#${blue}";
          "truncation_length" = 8;
          "truncate_to_repo" = false;
        };
        "git_branch" = {
          "symbol" = "";
          "style" = "#${cfg.colourScheme.mutedGrey}";
        };
        "git_commit" = {
          "style" = "#${cfg.colourScheme.mutedGrey}";
        };
        "git_metrics" = {
          "disabled" = false;
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
          "renamed" = "";
          "staged" = "";
          "stashed" = "";
          "style" = "#${cfg.colourScheme.mutedGrey}";
          "untracked" = "";
        };
        "hostname" = {
          "ssh_symbol" = "";
          "style" = "#${green}";
        };
        "jobs" = {
          "number_threshold" = 0;
          "style" = "#${black}";
          "symbol" = "";
          "symbol_threshold" = 0;
        };
        "nix_shell"."format" = "via [$state](#${red}) ";
        "username" = {
          "style_root" = "#${red}";
          "style_user" = "#${yellow}";
        };
        # Disabled modules
        "aws"."disabled" = true;
        "azure"."disabled" = true;
        "battery"."disabled" = true;
        "buf"."disabled" = true;
        "c"."disabled" = true;
        "cmake"."disabled" = true;
        "cobol"."disabled" = true;
        "conda"."disabled" = true;
        "container"."disabled" = true;
        "crystal"."disabled" = true;
        "dart"."disabled" = true;
        "deno"."disabled" = true;
        "docker_context"."disabled" = true;
        "dotnet"."disabled" = true;
        "elixir"."disabled" = true;
        "elm"."disabled" = true;
        "env_var"."disabled" = true;
        "erlang"."disabled" = true;
        "gcloud"."disabled" = true;
        "golang"."disabled" = true;
        "haskell"."disabled" = true;
        "helm"."disabled" = true;
        "hg_branch"."disabled" = true;
        "java"."disabled" = true;
        "julia"."disabled" = true;
        "kotlin"."disabled" = true;
        "kubernetes"."disabled" = true;
        "localip"."disabled" = true;
        "lua"."disabled" = true;
        "memory_usage"."disabled" = true;
        "nim"."disabled" = true;
        "nodejs"."disabled" = true;
        "ocaml"."disabled" = true;
        "openstack"."disabled" = true;
        "package"."disabled" = true;
        "perl"."disabled" = true;
        "php"."disabled" = true;
        "pulumi"."disabled" = true;
        "purescript"."disabled" = true;
        "python"."disabled" = true;
        "rlang"."disabled" = true;
        "red"."disabled" = true;
        "ruby"."disabled" = true;
        "rust"."disabled" = true;
        "scala"."disabled" = true;
        "shlvl"."disabled" = true;
        "singularity"."disabled" = true;
        "spack"."disabled" = true;
        "swift"."disabled" = true;
        "terraform"."disabled" = true;
        "time"."disabled" = true;
        "vlang"."disabled" = true;
        "vagrant"."disabled" = true;
        "vcsh"."disabled" = true;
        "zig"."disabled" = true;
      };
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
