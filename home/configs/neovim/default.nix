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
    # Use `cfgDevTool` again once nixpkgs#103009 if fixed.
    aleRustAnalyzer = "rust-analyzer";
    aleShellcheck = "${shellcheck}/bin/shellcheck";
    aleSpirvAs = cfgDevTool spirv-tools "spirv-as";
    aleSpirvDis = cfgDevTool spirv-tools "spirv-dis";
    aleVint = cfgDevTool vim-vint "vint";
    tagbarUniversalCtags = cfgDevTool universal-ctags "ctags";
  };
in
{
  options.veritas.configs.neovim = {
    enable = mkEnableOption "neovim configuration";

    additionalTools = mkOption {
      type = types.listOf types.package;
      default = with pkgs; [
        gawk
        gdb
        nixpkgs-fmt
        perl
        ripgrep
        universal-ctags
      ];
      description = "Tools expected by Neovim that should be installed.";
    };

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

    withLanguageSupport = mkOption {
      default = true;
      description = "Make NodeJS, Python and Python 3 available to Neovim.";
      type = types.bool;
    };
  };

  config = mkIf cfg.enable {
    home = {
      packages = cfg.additionalTools;

      sessionVariables."EDITOR" = "${config.programs.neovim.finalPackage}/bin/nvim";
    };

    programs.neovim = {
      enable = true;
      extraConfig = ''
        " Load primary configuration file.
        source ${extraConfig}
      '';
      plugins = with pkgs; with vimPlugins; with vimUtils; [
        # Sensible defaults for Vim.
        { plugin = vim-sensible; }
        # Polyglot adds a bunch of syntax handling for different languages and tools, check if
        # new languages are included before adding them manually.
        { plugin = vim-polyglot; }
        # Rust
        {
          plugin = rust-vim.overrideAttrs (_: {
            patches = [ ./0001-rust-vim-no-tagbar-integration.patch ];
          });
        }
        # Generate ctags for projects.
        { plugin = vim-gutentags; }
        # Auto-adds `end` where appropriate.
        { plugin = vim-endwise; }
        # Autocompletion/linting/fixing.
        { plugin = ale; }
        { plugin = deoplete-nvim; }
        { plugin = lightline-ale; }
        # Add operator to comment out lines.
        { plugin = vim-commentary; }
        # Improvements to netrw.
        { plugin = vim-vinegar; }
        # Show git changes in the sign column
        { plugin = vim-signify; }
        # Git wrappers
        { plugin = vim-fugitive; }
        { plugin = vim-rhubarb; }
        { plugin = fugitive-gitlab-vim; }
        # Async build and test dispatcher
        { plugin = vim-dispatch; }
        # Helper functions for unix commands.
        { plugin = vim-eunuch; }
        # Easy navigation between vim splits and tmux panes.
        { plugin = vim-tmux-navigator; }
        # Focus events for tmux.
        { plugin = vim-tmux-focus-events; }
        # Fuzzy file search.
        { plugin = fzfWrapper; }
        { plugin = fzf-vim; }
        # Statusline
        { plugin = lightline-vim; }
        # Show marks in sign column.
        { plugin = vim-signature; }
        # Adds `s` motion for matching any two characters.
        { plugin = vim-sneak; }
        # Improve `.` (repeat) for plugin maps.
        { plugin = vim-repeat; }
        # Handy bracket matchings.
        { plugin = vim-unimpaired; }
        # Commands for interactig with surroundings ("", '', {}, etc).
        { plugin = vim-surround; }
        # Multi-file search (`Ack`)
        { plugin = ferret; }
        # Enhanced `%` functionality.
        { plugin = matchit-zip; }
        # Colour scheme
        { plugin = vim-hybrid; }
        # Clipboard sync between Vim and tmux.
        { plugin = vim-tmux-clipboard; }
        # Switch to absolute line numbers for buffers that aren't focused.
        { plugin = vim-numbertoggle; }
        # Improved incremental search - hides search highlighting after moving cursor.
        { plugin = is-vim; }
        # Tagbar (show scope in statusline)
        { plugin = tagbar; }
        # Search/substitution/abbreviation of word variations.
        { plugin = vim-abolish; optional = true; }
        # Syntax highlighting for HOCON
        { plugin = vim-hocon; optional = true; }
        # Rich syntax highlighting for disassembled SPIR-V (and automatic disassembly)
        { plugin = vim-spirv; optional = true; }
        # Pandoc
        { plugin = vim-pandoc; optional = true; }
        { plugin = vim-pandoc-syntax; optional = true; }
        # Terminal utilities.
        { plugin = split-term-vim; optional = true; }
        # Text filtering and alignment.
        { plugin = tabular; optional = true; }
        # Visualize the undo tree.
        { plugin = vim-mundo; optional = true; }
      ];
      viAlias = true;
      vimAlias = true;
      withNodeJs = cfg.withLanguageSupport;
      withPython = cfg.withLanguageSupport;
      withPython3 = cfg.withLanguageSupport;
    };
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
