{ config, lib, pkgs, ... }:

with pkgs;
with lib;
let
  cfg = config.veritas.configs.neovim;
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
      extraConfig = with config.veritas.profiles.common.colourScheme; with cfg.colourScheme; ''
        " Define colour variables.
        let s:black = '#${black}'
        let s:c_black = 0
        let s:red = '#${red}'
        let s:c_red = 1
        let s:green = '#${green}'
        let s:c_green = 2
        let s:yellow = '#${yellow}'
        let s:c_yellow = 3
        let s:blue = '#${blue}'
        let s:c_blue = 4
        let s:magenta = '#${magenta}'
        let s:c_magenta = 5
        let s:cyan = '#${cyan}'
        let s:c_cyan = 6
        let s:white = '#${white}'
        let s:c_white = 7
        let s:bright_black = '#${brightBlack}'
        let s:c_bright_black = 8
        let s:bright_red = '#${brightRed}'
        let s:c_bright_red = 9
        let s:bright_green = '#${brightGreen}'
        let s:c_bright_green = 10
        let s:bright_yellow = '#${brightYellow}'
        let s:c_bright_yellow = 11
        let s:bright_blue = '#${brightBlue}'
        let s:c_bright_blue = 12
        let s:bright_magenta = '#${brightMagenta}'
        let s:c_bright_magenta = 13
        let s:bright_cyan = '#${brightCyan}'
        let s:c_bright_cyan = 14
        let s:bright_white = '#${brightWhite}'
        let s:c_bright_white = 15

        ${builtins.readFile ./config.vim}

        " Change backup, swap and undo directory. If a path ends in '//' then the file name
        " is built from the entire path. No more issues between projects.
        call MaybeMkdir('${config.xdg.cacheHome}/nvim/swap/')
        set directory=${config.xdg.cacheHome}/nvim/swap//

        call MaybeMkdir('${config.xdg.cacheHome}/nvim/backup/')
        set backupdir=${config.xdg.cacheHome}/nvim/backup//

        if exists('+undofile')
          call MaybeMkdir('${config.xdg.cacheHome}/nvim/undo/')
          set undodir=${config.xdg.cacheHome}/nvim/undo//
        end

        if exists('+shada')
          " Change SHAred DAta path.
          set shada+=n${config.xdg.cacheHome}/nvim/shada
        else
          " Change viminfo path.
          set viminfo+=n${config.xdg.cacheHome}/nvim/viminfo
        endif

        " Save the `.lvimrc` persistence file in the cache folder.
        let g:localvimrc_persistence_file = '${config.xdg.cacheHome}/nvim/lvimrc_persistence'

        " Set the colour of the colour column (used to highlight where lines should wrap).
        hi ColorColumn guibg=#${brightBlack}

        " Set the background colour.
        hi Normal guibg=#${background}

        " Lightline won't colour the single character between two statuslines when there is a
        " vertical split, this will.
        hi StatusLine gui=NONE guifg=#${background} guibg=#${background}

        " Set the colour of the current debugger line and breakpoints in gutter.
        hi debugPC guibg=#${termdebugProgramCounter}
        hi debugBreakpoint guifg=#${termdebugBreakpointForeground} guibg=#${termdebugBreakpointBackground}
      '';
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
        # Look for project specific `.lvimrc` files.
        vim-localvimrc
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
