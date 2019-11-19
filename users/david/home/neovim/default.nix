{ config, pkgs, ... }:

# This file contains the configuration for NeoVim.

let
  colours = config.veritas.david.colourScheme;
  external = import ../../../../shared/external.nix;
  hie = let
    all-hies = import external.all-hies {};
  in
    all-hies.selection {
      selector = p: { inherit (p) ghc865; };
    };
  plugins = pkgs.callPackage ./plugins.nix {};
in
{
  home.sessionVariables."EDITOR" = "${config.programs.neovim.finalPackage}/bin/nvim";

  programs.neovim = {
    enable = true;
    extraConfig = with colours; ''
      ${builtins.readFile ./functions.vim}

      " Tell ALE where to look for `compilation-commands.json`.
      let g:ale_c_build_dir_names = [ 'build', 'build_debug', 'bin' ]

      function! SearchBuildDirsOr(fallback_path)
        " Get the name of the binary from the fallback path.
        let binary_name = fnamemodify(a:fallback_path, ':t')

        " Look in the build directories that ALE uses for a local-version of the
        " binary.
        for build_dir in g:ale_c_build_dir_names
            let binary_path = './' . build_dir . '/bin/' . binary_name
            if executable(binary_path)
                return binary_path
            endif
        endfor

        " If there wasn't one, use the fallback path.
        return a:fallback_path
      endfunction

      " Hardcode paths into the nix store.
      let g:ale_awk_gawk_executable = '${pkgs.gawk}/bin/gawk'
      let g:ale_c_clang_executable = SearchBuildDirsOr('${pkgs.unstable.clang}/bin/clang')
      let g:ale_c_clangd_executable = SearchBuildDirsOr('${pkgs.unstable.clang-tools}/bin/clangd')
      let g:ale_c_clangformat_executable = SearchBuildDirsOr('${pkgs.unstable.clang-tools}/bin/clang-format')
      let g:ale_c_clangtidy_executable = SearchBuildDirsOr('${pkgs.unstable.clang-tools}/bin/clang-tidy')
      let g:ale_cpp_clang_executable = SearchBuildDirsOr('${pkgs.unstable.clang}/bin/clang++')
      let g:ale_cpp_clangd_executable = g:ale_c_clangd_executable
      let g:ale_cpp_clangtidy_executable = g:ale_c_clangtidy_executable
      let g:ale_cuda_clangformat_executable = g:ale_c_clangformat_executable
      let g:ale_cuda_nvcc_executable = '${pkgs.cudatoolkit_10}/bin/nvcc'
      let g:ale_haskell_hie_executable = '${hie}/bin/hie'
      let g:ale_haskell_ormolu_executable = '${pkgs.ormolu}/bin/ormolu'
      let g:ale_json_jq_executable = '${pkgs.jq}/bin/jq'
      let g:ale_llvm_llc_executable = SearchBuildDirsOr('${pkgs.unstable.llvm}/bin/llc')
      let g:ale_lua_luac_executable = '${pkgs.lua}/bin/luac'
      let g:ale_nix_nixpkgsfmt_executable = '${pkgs.unstable.nixpkgs-fmt}/bin/nixpkgs-fmt'
      let g:ale_python_black_executable = '${pkgs.unstable.python37Packages.black}/bin/black'
      let g:ale_python_flake8_executable = '${pkgs.unstable.python37Packages.flake8}/bin/flake8'
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
      hi StatusLine gui=NONE guifg=#${basic.background} guibg=#${basic.background}

      " Set the colour of the current debugger line and breakpoints in gutter.
      hi debugPC guibg=#${neovim.termdebugProgramCounter}
      hi debugBreakpoint guifg=#${neovim.termdebugBreakpoint.fg} guibg=#${neovim.termdebugBreakpoint.bg}
    '';
    viAlias = true;
    vimAlias = true;
    withNodeJs = true;
    withPython = true;
    withPython3 = true;
    package = pkgs.unstable.neovim;
    plugins = with plugins; [
      # Sensible defaults for Vim.
      vim-sensible
      # Polyglot adds a bunch of syntax handling for different languages and tools, check if
      # new languages are included before adding them manually.
      vim-polyglot
      # Rust (included in Polyglot, but explicitly disabled so that we can use newer versions).
      rust-vim
      # Other languages
      vim-hocon
      vim-pandoc
      vim-pandoc-syntax
      vim-spirv
      # Generate ctags for projects.
      vim-gutentags
      # Auto-adds `end` where appropriate.
      vim-endwise
      # Hybrid colour scheme
      vim-hybrid
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
      # Focus events and clipboard for tmux.
      vim-tmux-clipboard
      vim-tmux-focus-events
      # Switch to absolute line numbers for buffers that aren't focused.
      vim-numbertoggle
      # Fuzzy file search.
      fzf
      fzf-vim
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
      # Text filtering and alignment.
      tabular
      # Visualize the undo tree.
      vim-mundo
      # Search/substitution/abbreviation of word variations.
      vim-abolish
    ];
  };

  # Configure the `flake8` linter for Python to match `black`'s formatting.
  xdg.configFile."flake8".text = ''
    [flake8]
    # Recommend matching the black line length (default 88),
    # rather than using the flake8 default of 79:
    max-line-length = 88
    extend-ignore =
        # See https://github.com/PyCQA/pycodestyle/issues/373
        E203,
  '';
}

# vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
