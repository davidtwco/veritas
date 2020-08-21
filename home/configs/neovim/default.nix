{ config, lib, pkgs, ... }:

with pkgs;
with lib;
let
  cfg = config.veritas.configs.neovim;
  colourScheme = config.veritas.profiles.common.colourScheme;

  cfgDevTool = pkg: binaryName:
    if cfg.withDeveloperTools then "${pkg}/bin/${binaryName}" else binaryName;

  extraConfig = substituteAll {
    src = ./config.vim;
    inherit (cfg.colourScheme) termdebugBreakpointBackground termdebugBreakpointForeground;
    inherit (cfg.colourScheme) termdebugProgramCounter;
    inherit (colourScheme) black red green yellow blue magenta cyan white brightBlack brightRed;
    inherit (colourScheme) brightGreen brightYellow brightBlue brightMagenta brightCyan;
    inherit (colourScheme) brightWhite background;
    aleBlack = cfgDevTool python38Packages.black "black";
    aleClang = cfgDevTool clang "clang";
    aleClangFormat = cfgDevTool clang-tools "clang-format";
    aleClangPlusPlus = cfgDevTool clang "clang++";
    aleClangTidy = cfgDevTool clang-tools "clang-tidy";
    aleClangd = cfgDevTool clang-tools "clangd";
    aleFlake8 = cfgDevTool python38Packages.flake8 "flake8";
    aleJq = "${jq}/bin/jq";
    aleLlc = cfgDevTool llvm "llc";
    aleLuac = cfgDevTool lua "luac";
    aleNixpkgsfmt = cfgDevTool nixpkgs-fmt "nixpkgs-fmt";
    aleNvcc = cfgDevTool cudatoolkit_10 "nvcc";
    aleOrmolu = cfgDevTool ormolu "ormolu";
    aleRubocop = cfgDevTool rubocop "rubocop";
    aleRustAnalyzer = cfgDevTool rust-analyzer "rust-analyzer";
    aleShellcheck = "${shellcheck}/bin/shellcheck";
    aleSpirvAs = cfgDevTool spirv-tools "spirv-as";
    aleSpirvDis = cfgDevTool spirv-tools "spirv-dis";
    aleVint = cfgDevTool vim-vint "vint";
    tagbarUniversalCtags = cfgDevTool universal-ctags "ctags";
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

    withDeveloperTools = mkOption {
      default = false;
      description = "Make additional development tools available to Vim configuration.";
      type = types.bool;
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
      configure = {
        customRC = ''
          " Load primary configuration file.
          source ${extraConfig}
        '';

        packages.veritas = with pkgs; with vimPlugins; with vimUtils; {
          start = [
            # Sensible defaults for Vim.
            vim-sensible
            # Polyglot adds a bunch of syntax handling for different languages and tools, check if
            # new languages are included before adding them manually.
            vim-polyglot
            # Rust
            (rust-vim.overrideAttrs (_: {
              patches = [ ./0001-rust-vim-no-tagbar-integration.patch ];
            }))
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
            # Adds `s` motion for matching any two characters.
            vim-sneak
            # Improve `.` (repeat) for plugin maps.
            vim-repeat
            # Handy bracket matchings.
            vim-unimpaired
            # Commands for interactig with surroundings ("", '', {}, etc).
            vim-surround
            # Multi-file search (`Ack`)
            ferret
            # Enhanced `%` functionality.
            matchit-zip
            # Colour scheme
            vim-hybrid
            # Clipboard sync between Vim and tmux.
            vim-tmux-clipboard
            # Switch to absolute line numbers for buffers that aren't focused.
            vim-numbertoggle
            # Improved incremental search - hides search highlighting after moving cursor.
            is-vim
            # Tagbar (show scope in statusline)
            tagbar
          ];

          # Load these with `:packadd` command.
          opt = [
            # Search/substitution/abbreviation of word variations.
            vim-abolish
            # Syntax highlighting for HOCON
            vim-hocon
            # Rich syntax highlighting for disassembled SPIR-V (and automatic disassembly)
            vim-spirv
            # Pandoc
            vim-pandoc
            vim-pandoc-syntax
            # Terminal utilities.
            split-term-vim
            # Text filtering and alignment.
            tabular
            # Visualize the undo tree.
            vim-mundo
          ];
        };
      };
      enable = true;
      viAlias = true;
      vimAlias = true;
      withNodeJs = true;
      withPython = true;
      withPython3 = true;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
