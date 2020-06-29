{ config, lib, pkgs, ... }:

with pkgs;
with lib;
let
  cfg = config.veritas.configs.neovim;
  colourScheme = config.veritas.profiles.common.colourScheme;

  extraConfig = pkgs.substituteAll {
    src = ./config.vim;
    inherit (cfg.colourScheme) termdebugBreakpointBackground termdebugBreakpointForeground;
    inherit (cfg.colourScheme) termdebugProgramCounter;
    inherit (colourScheme) black red green yellow blue magenta cyan white brightBlack brightRed;
    inherit (colourScheme) brightGreen brightYellow brightBlue brightMagenta brightCyan;
    inherit (colourScheme) brightWhite background;
    cacheHome = config.xdg.cacheHome;
  };
in
{
  options.veritas.configs.neovim = {
    enable = mkEnableOption "neovim configuration";

    colourScheme = {
      termdebugBreakpointBackground = mkOption {
        default = "2B2B2B";
        description = "Define the background colour for termdebug's current line.";
        example = "FFFFFF";
        type = types.str;
      };

      termdebugBreakpointForeground = mkOption {
        default = "B2B2B2";
        description = "Define the foreground colour for termdebug's current line.";
        example = "FFFFFF";
        type = types.str;
      };

      termdebugProgramCounter = mkOption {
        default = cfg.colourScheme.termdebugBreakpointBackground;
        description = "Define the colour for termdebug's gutter breakpoint indicator.";
        example = "FFFFFF";
        type = types.str;
      };
    };
  };

  config = mkIf cfg.enable {
    home = {
      # Make binaries expected by the Neovim configuration available.
      packages = with pkgs; [
        gawk
        nixpkgs-fmt
        universal-ctags
        gdb
        ripgrep
      ];

      sessionVariables."EDITOR" = "${config.programs.neovim.finalPackage}/bin/nvim";
    };

    programs.neovim = {
      enable = true;
      extraConfig = "source ${extraConfig}";
      viAlias = true;
      vimAlias = true;
      withNodeJs = true;
      withPython = true;
      withPython3 = true;
      plugins = with pkgs.vimPlugins; with pkgs.vimUtils; [
        # Sensible defaults for Vim.
        vim-sensible
        # Polyglot adds a bunch of syntax handling for different languages and tools, check if
        # new languages are included before adding them manually.
        vim-polyglot
        # Rust (included in Polyglot, but explicitly disabled so that we can use newer versions).
        rust-vim
        # Pandoc
        vim-pandoc
        vim-pandoc-syntax
        # Generate ctags for projects.
        vim-gutentags
        # Auto-adds `end` where appropriate.
        vim-endwise
        # Autocompletion/linting/fixing.
        ale
        deoplete-nvim
        lightline-ale
        # Add operator to comment out lines.
        vim-commentary
        # Improvements to netrw.
        vim-vinegar
        # Show git changes in the sign column
        vim-signify
        # Git wrappers
        vim-fugitive
        vim-rhubarb
        fugitive-gitlab-vim
        # Async build and test dispatcher
        vim-dispatch
        # Helper functions for unix commands.
        vim-eunuch
        # Easy navigation between vim splits and tmux panes.
        vim-tmux-navigator
        # Focus events for tmux.
        vim-tmux-focus-events
        # Fuzzy file search.
        fzfWrapper
        fzf-vim
        # Statusline
        lightline-vim
        # Show marks in sign column.
        vim-signature
        vim-sneak
        # Adds `s` motion for matching any two characters.
        vim-sneak
        # Improve `.` (repeat) for plugin maps.
        vim-repeat
        # Terminal utilities.
        split-term-vim
        # Handy bracket matchings.
        vim-unimpaired
        # Commands for interactig with surroundings ("", '', {}, etc).
        vim-surround
        # Multi-file search (`Ack`)
        ferret
        # Enhanced `%` functionality.
        matchit-zip
        # Text filtering and alignment.
        tabular
        # Search/substitution/abbreviation of word variations.
        vim-abolish
        # Syntax highlighting for HOCON
        vim-hocon
        # Rich syntax highlighting for disassembled SPIR-V (and automatic disassembly)
        vim-spirv
        # Colour scheme
        vim-hybrid
        # Clipboard sync between Vim and tmux.
        vim-tmux-clipboard
        # Switch to absolute line numbers for buffers that aren't focused.
        vim-numbertoggle
        # Improved incremental search - hides search highlighting after moving cursor.
        is-vim
        # Visualize the undo tree.
        vim-mundo
      ];
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
