{ config, lib, pkgs, ... }:

with lib;
let
  cfg = config.veritas.configs.git;

  gitalias = pkgs.fetchFromGitHub {
    owner = "GitAlias";
    repo = "gitalias";
    rev = "fb19fde1e4ec901ae7e54ef5b1c40d55cab7e86f";
    sha256 = "0axf8s6j1dg2jp637p4zs98h3a5wma5swqfld9igmyqpghpsgx5q";
  };
in
{
  options.veritas.configs.git = {
    enable = mkEnableOption "git configuration";

    email = mkOption {
      type = types.str;
      default = config.veritas.configs.mail.email;
      description = "Email used in authoring Git commits.";
    };

    name = mkOption {
      type = types.str;
      default = config.veritas.configs.mail.name;
      description = "Name used in authoring Git commits.";
    };
  };

  config = mkIf cfg.enable {
    programs.git = {
      aliases = {
        # Debug a command or alias - preceed it with `debug`.
        debug = "!set -x; GIT_TRACE=2 GIT_CURL_VERBOSE=2 GIT_TRACE_PERFORMANCE=2 GIT_TRACE_PACK_ACCESS=2 GIT_TRACE_PACKET=2 GIT_TRACE_PACKFILE=2 GIT_TRACE_SETUP=2 GIT_TRACE_SHALLOW=2 git";
        # Quote / unquote a sh command, converting it to / from a git alias string
        quote-string = "!read -r l; printf \\\"!; printf %s \"$l\" | sed 's/\\([\\\"]\\)/\\\\\\1/g'; printf \" #\\\"\\n\" #";
        quote-string-undo = "!read -r l; printf %s \"$l\" | sed 's/\\\\\\([\\\"]\\)/\\1/g'; printf \"\\n\" #";
        # Push commits upstream.
        ps = "push";
        # Overrides gitalias.txt `save` to include untracked files.
        save = "stash save --include-untracked";
      };
      enable = true;
      extraConfig = {
        advice = {
          addIgnoredFile = false;
          detachedHead = false;
        };
        color.ui = "auto";
        commit = {
          verbose = true;
          template = "${config.xdg.dataHome}/git/template";
        };
        core.editor = config.home.sessionVariables."EDITOR";
        diff = {
          compactionHeuristic = true;
          indentHeuristic = true;
        };
        feature = {
          experimental = true;
          manyFiles = true;
        };
        merge.conflictStyle = "zdiff3";
        pull.rebase = true;
        push = {
          default = "simple";
          followTags = true;
        };
        status.showStash = true;
        stash.showPatch = true;
        submodule.fetchJobs = 4;
        rebase.autosquash = true;
        user.useConfigOnly = true;
      };
      ignores = [
        # Compiled source
        "*.com"
        "*.class"
        "*.dll"
        "*.exe"
        "*.o"
        "*.so"

        # OS generated files
        ".DS_Store"
        ".DS_Store?"
        "._*"
        ".Spotlight-V100"
        ".Trashes"
        "ehthumbs.db"
        "Thumbs.db"

        # ctags
        "tags"
        "tags.temp"
        "tags.lock"
        "tags.files"

        # Vim
        "Session.vim"

        # GDB
        ".gdb_history"

        # Ripgrep
        ".rgignore"

        # C/C++
        "compile_commands.json"
      ];
      includes = [{ path = "${gitalias}/gitalias.txt"; }];
      lfs = {
        enable = true;
        skipSmudge = false;
      };
      package = pkgs.gitAndTools.gitFull;
      userEmail = cfg.email;
      userName = cfg.name;
    };

    xdg.dataFile."git/template" = {
      text = ''


        # Always `--signoff` commits.
        Signed-off-by: ${cfg.name} <${cfg.email}>
      '';
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
