{ config, lib, ... }:

with lib;
let
  cfg = config.veritas.configs.readline;
in
{
  options.veritas.configs.readline.enable = mkEnableOption "readline configuration";

  config = mkIf cfg.enable {
    programs.readline = {
      bindings = {
        # Fix bindings for beginning of line and end of line on some machines
        "\\e[1~" = "beginning-of-line";
        "\\e[4~" = "end-of-line";
        "\\e[7~" = "beginning-of-line";
        "\\e[8~" = "end-of-line";
        "\\eOH" = "beginning-of-line";
        "\\eOF" = "end-of-line";
        "\\e[H" = "beginning-of-line";
        "\\e[F" = "end-of-line";

        # Disable clearing the screen with CTRL+L.
        "\\C-l" = "nop";

        # Use the text that has already been typed as the prefix for searching through
        # commands (basically more intelligent Up/Down behavior)
        "\\e[A" = "history-search-backward";
        "\\e[B" = "history-search-forward";

        # Use Alt/Meta + Delete to delete the preceding word
        "\\e[3;3~" = "kill-word";
      };
      enable = true;
      extraConfig = ''
        # Perform file completion in a case insensitive fashion
        set completion-ignore-case on

        # Treat hyphens and underscores as equivalent
        set completion-map-case on

        # Display matches for ambiguous patterns at first tab press
        set show-all-if-ambiguous on

        # Immediately add a trailing slash when autocompleting symlinks to directories
        set mark-symlinked-directories on

        # Do not autocomplete hidden files unless the pattern explicitly begins with a dot
        set match-hidden-files off

        # Show all autocomplete results at once
        set page-completions off

        # If there are more than 200 possible completions for a word, ask to show them all
        set completion-query-items 200

        # Show extra file information when completing, like `ls -F` does
        set visible-stats on

        # Be more intelligent when autocompleting by also looking at the text after
        # the cursor. For example, when the current line is "cd ~/src/mozil", and
        # the cursor is on the "z", pressing Tab will not autocomplete it to "cd
        # ~/src/mozillail", but to "cd ~/src/mozilla". (This is supported by the
        # Readline used by Bash 4.)
        set skip-completed-text on

        # Allow UTF-8 input and output, instead of showing stuff like $'\0123\0456'
        set input-meta on
        set output-meta on
        set convert-meta off

        # Set timeout for key sequences.
        set keyseq-timeout 50
      '';
      includeSystemConfig = true;
    };
  };
}
