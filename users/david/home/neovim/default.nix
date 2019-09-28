{ config, pkgs, ... }:

# This file contains the configuration for NeoVim.

let
  colours = config.veritas.david.colourScheme;
  plugins = pkgs.callPackage ./plugins.nix {};
in {
  # Use NeoVim as editor. Don't use the full path to the binary as that won't be the customized
  # version.
  home.sessionVariables."EDITOR" = "nvim";

  programs.neovim = {
    configure = {
      customRC = with colours; ''
        ${builtins.readFile ./functions.vim}

        " Hardcode paths into the nix store.
        let g:ale_awk_gawk_executable = '${pkgs.gawk}/bin/gawk'
        let g:ale_c_clang_executable = '${pkgs.unstable.clang}/bin/clang'
        let g:ale_c_clangd_executable = '${pkgs.unstable.clang-tools}/bin/clangd'
        let g:ale_c_clangformat_executable = '${pkgs.unstable.clang-tools}/bin/clang-format'
        let g:ale_c_clangtidy_executable = '${pkgs.unstable.clang-tools}/bin/clang-tidy'
        let g:ale_cpp_clang_executable = '${pkgs.unstable.clang}/bin/clang++'
        let g:ale_cpp_clangd_executable = '${pkgs.unstable.clang-tools}/bin/clangd'
        let g:ale_cpp_clangtidy_executable = '${pkgs.unstable.clang-tools}/bin/clang-tidy'
        let g:ale_cuda_clangformat_executable = '${pkgs.unstable.clang-tools}/bin/clang-format'
        let g:ale_cuda_nvcc_executable = '${pkgs.cudatoolkit_10}/bin/nvcc'
        let g:ale_json_jq_executable = '${pkgs.jq}/bin/jq'
        let g:ale_llvm_llc_executable = '${pkgs.unstable.llvm}/bin/llc'
        let g:ale_lua_luac_executable = '${pkgs.lua}/bin/luac'
        let g:ale_python_flake8_executable = '${pkgs.pythonPackages.flake8}/bin/flake8'
        let g:ale_ruby_rubocop_executable = '${pkgs.rubocop}/bin/rubocop'
        let g:ale_rust_rls_executable = '${pkgs.latest.rustChannels.stable.rust}/bin/rls'
        let g:ale_sh_shellcheck_executable = '${pkgs.shellcheck}/bin/shellcheck'
        let g:ale_vim_vint_executable = '${pkgs.vim-vint}/bin/vint'
        let g:gutentags_ctags_executable = '${pkgs.universal-ctags}/bin/ctags'
        let g:spirv_as_path = '${pkgs.unstable.spirv-tools}/bin/spirv-as'
        let g:spirv_dis_path = '${pkgs.unstable.spirv-tools}/bin/spirv-dis'

        " Set gdb path.
        let termdebugger = '${pkgs.gdb}/bin/gdb'

        " Set up persistent scratch space.
        let g:scratch_persistence_file = '${config.xdg.cacheHome}/nvim/scratch'

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

        if has('autocmd')
          augroup llvm
            function! DisassembleLLVM()
              if getline(1) =~ 'BC\%xC0\%xDE'
                " Keep track of whether this buffer was disassembled so that it can be reassembled.
                let b:isLLVM = 1

                setl binary
                %!${pkgs.llvm_7}/bin/llvm-dis
                setl ft=llvm nobinary ro
                call EchoAU('None', 'Disassembled LLVM IR, viewing as read-only')
              endif
            endfunc

            au BufRead,BufNewFile * call DisassembleLLVM()
          augroup END
        endif

        " Use 24-bit colour.
        set termguicolors
        " Enable syntax highlighting.
        syntax enable
        " Apply colourscheme before our own highlighting.
        colorscheme hybrid
        " Use custom terminal colours.
        let g:hybrid_custom_term_colors = 1

        ${builtins.readFile ./native.vim}
        ${builtins.readFile ./plugins.vim}
        ${builtins.readFile ./completion.vim}
        ${builtins.readFile ./statusline.vim}
        ${builtins.readFile ./mappings.vim}

        " Set the colour of the colour column (used to highlight where lines should wrap).
        hi ColorColumn guibg=#${basic.brightBlack}

        " Set the background colour.
        hi Normal guibg=#${basic.background}

        " Lightline won't colour the single character between two statuslines when there is a
        " vertical split, this will.
        hi StatusLine guifg=#${basic.background} guibg=#${basic.background}

        " Set the colour of the current debugger line and breakpoints in gutter.
        hi debugPC guibg=#${neovim.termdebugProgramCounter}
        hi debugBreakpoint guifg=#${neovim.termdebugBreakpoint.fg} guibg=#${neovim.termdebugBreakpoint.bg}
      '';
      packages.plugins = with plugins; {
        start = [
          # Sensible defaults for Vim.
          vim-sensible
          # Polyglot adds a bunch of syntax handling for different languages and tools, check if
          # new languages are included before adding them manually.
          vim-polyglot
          # Rust (included in Polyglot, but explicitly disabled so that we can use newer versions).
          rust-vim
          # Other languages
          pgsql-vim vim-graphql vim-hocon vim-jinja vim-nix vim-pandoc vim-pandoc-syntax vim-puppet
          vim-spirv
          # Generate ctags for projects.
          vim-gutentags
          # Auto-adds `end` where appropriate.
          vim-endwise
          # Hybrid colour scheme
          vim-hybrid
          # Autocompletion/linting/fixing.
          ale lightline-ale
          # Add operator to comment out lines.
          vim-commentary
          # Improvements to netrw.
          vim-vinegar
          # Show git changes in the sign column
          vim-signify
          # Git wrappers
          vim-fugitive vim-rhubarb fugitive-gitlab-vim
          # Helper functions for unix commands.
          vim-eunuch
          # Easy navigation between vim splits and tmux panes.
          vim-tmux-navigator
          # Focus events and clipboard for tmux.
          vim-tmux-clipboard vim-tmux-focus-events
          # GnuPG
          vim-gnupg
          # Switch to absolute line numbers for buffers that aren't focused.
          vim-numbertoggle
          # Fuzzy file search.
          fzf fzf-vim
          # Statusline
          lightline
          # Show marks in sign column.
          vim-signature
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
          # Move sideways left or right through argument lists, etc.
          sideways-vim
          # Apply indentation from `.editorconfig` files.
          editorconfig-vim
          # Multi-file search (`Ack`)
          ferret
          # Improved incremental search - hides search highlighting after moving cursor.
          is-vim
          # Enhanced `%` functionality.
          vim-matchit
          # Look for project specific `.lvimrc` files.
          vim-localvimrc
          # Scratchpad
          scratch-vim
        ];
        opt = [
          # Activate/deactivate and list virtual environments.
          vim-virtualenv
          # Functions that interact with tmux.
          vim-tbone
          # Hide interface elements for writing.
          goyo-vim
          # Text filtering and alignment.
          tabular
          # Show current tag in statusline.
          tagbar
          # Visualize the undo tree.
          vim-mundo
          # Search/substitution/abbreviation of word variations.
          vim-abolish
          # Date manipulation commands.
          vim-speeddating
          # Access unicode character metadata.
          vim-characterize
          # Session saving.
          vim-obsession
          # Live markdown preview (needs livedown npm package).
          vim-livedown
        ];
      };
    };
    enable = true;
    package = pkgs.unstable.neovim;
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython = true;
    withPython3 = true;
  };
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
