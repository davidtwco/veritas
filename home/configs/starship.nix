{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.configs.starship;
in
{
  options.veritas.configs.starship = {
    enable = mkEnableOption "starship configuration";
  };

  config = mkIf cfg.enable {
    programs.starship = {
      enable = true;
      enableBashIntegration = false;
      enableFishIntegration = true;
      package = pkgs.starship;
      settings = {
        "character" = {
          "success_symbol" = "[❯](#85678F)";
          "error_symbol" = "[❯](#A54242)";
          "vicmd_symbol" = "[❮](#85678F)";
        };
        "cmd_duration"."style" = "#DE935F";
        "directory" = {
          "style" = "#5F819D";
          "truncation_length" = 8;
          "truncate_to_repo" = false;
        };
        "git_branch" = {
          "symbol" = "";
          "style" = "#6B6B6B";
        };
        "git_commit"."style" = "#6B6B6B";
        "git_metrics"."disabled" = false;
        "git_state" = {
          "rebase" = "rebasing";
          "merge" = "merging";
          "revert" = "reverting";
          "cherry_pick" = "cherry-picking";
          "bisect" = "bisecting";
          "am" = "am";
          "am_or_rebase" = "am/rebasing";
          "style" = "#DE935F";
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
          "style" = "#6B6B6B";
          "untracked" = "";
        };
        "hostname" = {
          "ssh_symbol" = "";
          "style" = "#8C9440";
        };
        "jobs" = {
          "style" = "#282A2E";
          "symbol" = "◦";
        };
        "nix_shell"."format" = "via [$state](#A54242) ";
        "username" = {
          "style_root" = "#A54242";
          "style_user" = "#DE935F";
        };
        # Disabled modules
        "aws"."disabled" = true;
        "azure"."disabled" = true;
        "battery"."disabled" = true;
        "buf"."disabled" = true;
        "bun"."disabled" = true;
        "c"."disabled" = true;
        "cmake"."disabled" = true;
        "cobol"."disabled" = true;
        "conda"."disabled" = true;
        "container"."disabled" = true;
        "crystal"."disabled" = true;
        "daml"."disabled" = true;
        "dart"."disabled" = true;
        "deno"."disabled" = true;
        "docker_context"."disabled" = true;
        "dotnet"."disabled" = true;
        "elixir"."disabled" = true;
        "elm"."disabled" = true;
        "env_var"."disabled" = true;
        "erlang"."disabled" = true;
        "fennel"."disabled" = true;
        "fill"."disabled" = true;
        "fossil_branch"."disabled" = true;
        "gcloud"."disabled" = true;
        "golang"."disabled" = true;
        "guix_shell"."disabled" = true;
        "gradle"."disabled" = true;
        "haskell"."disabled" = true;
        "haxe"."disabled" = true;
        "helm"."disabled" = true;
        "hg_branch"."disabled" = true;
        "java"."disabled" = true;
        "julia"."disabled" = true;
        "kotlin"."disabled" = true;
        "kubernetes"."disabled" = true;
        "localip"."disabled" = true;
        "lua"."disabled" = true;
        "memory_usage"."disabled" = true;
        "meson"."disabled" = true;
        "nim"."disabled" = true;
        "nodejs"."disabled" = true;
        "ocaml"."disabled" = true;
        "opa"."disabled" = true;
        "openstack"."disabled" = true;
        "os"."disabled" = true;
        "package"."disabled" = true;
        "perl"."disabled" = true;
        "php"."disabled" = true;
        "pijul_channel"."disabled" = true;
        "pulumi"."disabled" = true;
        "purescript"."disabled" = true;
        "python"."disabled" = true;
        "rlang"."disabled" = true;
        "raku"."disabled" = true;
        "red"."disabled" = true;
        "ruby"."disabled" = true;
        "rust"."disabled" = true;
        "scala"."disabled" = true;
        "shlvl"."disabled" = true;
        "singularity"."disabled" = true;
        "solidity"."disabled" = true;
        "spack"."disabled" = true;
        "sudo"."disabled" = true;
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
