{ config, pkgs, ... }:

# This file contains the configuration for Git.

let
  cfg = config.veritas.david;
in
{
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
      color = {
        ui = "auto";
      };
      commit = {
        verbose = true;
        template = "${config.xdg.dataHome}/git/template";
      };
      core = {
        pager =
          with config.veritas.david.colourScheme.delta;
          ''
            ${pkgs.delta}/bin/delta \
              --dark \
              --plus-color="#${plus.regular}" \
              --plus-emph-color="#${plus.emphasised}" \
              --minus-color="#${minus.regular}" \
              --minus-emph-color="#${minus.emphasised}"
          '';
        editor = config.home.sessionVariables."EDITOR";
      };
      diff = {
        compactionHeuristic = true;
        indentHeuristic = true;
      };
      push = {
        default = "simple";
        followTags = true;
      };
      status = {
        showStash = true;
      };
      stash = {
        showPatch = true;
      };
      submodule = {
        fetchJobs = 4;
      };
      rebase = {
        autosquash = true;
      };
      user = {
        useConfigOnly = true;
      };
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
      ".lvimrc"
      "Session.vim"

      # GDB
      ".gdb_history"

      # Workman
      ".workman_active_working_directory"
      ".workman_do_not_assign"
      ".workman_needs_refresh"

      # Ripgrep
      ".rgignore"

      # C/C++
      "compile_commands.json"
    ];
    includes = let
      aliases = builtins.fetchGit {
        url = "https://github.com/GitAlias/gitalias.git";
        ref = "master";
        rev = "04410eab725ef152e1eb70a87cb6fd4f52f7b4ea";
      };
    in
      [ { path = "${aliases}/gitalias.txt"; } ];
    lfs = {
      enable = true;
      skipSmudge = false;
    };
    package = pkgs.gitAndTools.gitFull;
    signing = {
      key = "9F53F154";
      signByDefault = true;
    };
    userEmail = cfg.email.address;
    userName = cfg.name;
  };

  xdg.dataFile."git/template" = {
    text = ''


      # Always `--signoff` commits.
      Signed-off-by: ${cfg.name} <${cfg.email.address}>
    '';
  };

}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
