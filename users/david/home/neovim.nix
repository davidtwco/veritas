{ config, pkgs, lib, ... }:

# This file contains the configuration for NeoVim.

let
  cfg = config.veritas.david;
in
  with pkgs; with lib; {
    home.sessionVariables."EDITOR" = "${config.programs.neovim.finalPackage}/bin/nvim";

    programs.neovim = {
      enable = true;
      extraConfig = let
        prefix = ''
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

            " Check the PATH (useful for overriding the version using shell.nix)
            if executable(binary_name)
                return binary_name
            endif

            " If there wasn't one, use the fallback path.
            return a:fallback_path
          endfunction
        '' + (
          optionalString (!cfg.dotfiles.minimal) (
            let
              sources = import ../../../nix/sources.nix;
              hie = (import sources.all-hies {}).selection {
                selector = p: { inherit (p) ghc865; };
              };
            in
              ''
                let g:ale_c_clang_executable = SearchBuildDirsOr('${unstable.clang}/bin/clang')
                let g:ale_c_clangd_executable = SearchBuildDirsOr('${unstable.clang-tools}/bin/clangd')
                let g:ale_c_clangformat_executable = SearchBuildDirsOr('${unstable.clang-tools}/bin/clang-format')
                let g:ale_c_clangtidy_executable = SearchBuildDirsOr('${unstable.clang-tools}/bin/clang-tidy')
                let g:ale_cpp_clang_executable = SearchBuildDirsOr('${unstable.clang}/bin/clang++')
                let g:ale_cpp_clangd_executable = g:ale_c_clangd_executable
                let g:ale_cpp_clangtidy_executable = g:ale_c_clangtidy_executable
                let g:ale_cuda_clangformat_executable = g:ale_c_clangformat_executable
                let g:ale_cuda_nvcc_executable = '${cudatoolkit_10}/bin/nvcc'
                let g:ale_haskell_hie_executable = '${hie}/bin/hie'
                let g:ale_haskell_ormolu_executable = '${ormolu}/bin/ormolu'
                let g:ale_json_jq_executable = '${jq}/bin/jq'
                let g:ale_llvm_llc_executable = SearchBuildDirsOr('${unstable.llvm}/bin/llc')
                let g:ale_lua_luac_executable = '${lua}/bin/luac'
                let g:ale_python_black_executable = '${unstable.python37Packages.black}/bin/black'
                let g:ale_python_flake8_executable = '${unstable.python37Packages.flake8}/bin/flake8'
                let g:ale_ruby_rubocop_executable = '${rubocop}/bin/rubocop'
                let g:ale_rust_rls_executable = '${latest.rustChannels.stable.rust}/bin/rls'
                let g:ale_rust_rustfmt_executable = '${latest.rustChannels.stable.rust}/bin/rustfmt'
                let g:ale_sh_shellcheck_executable = '${shellcheck}/bin/shellcheck'
                let g:ale_vim_vint_executable = '${vim-vint}/bin/vint'
                let g:spirv_as_path = '${unstable.spirv-tools}/bin/spirv-as'
                let g:spirv_dis_path = '${unstable.spirv-tools}/bin/spirv-dis'
              ''
          )
        );
        body = with cfg.colourScheme; ''
          " Create a directory if it doesn't exist.
          function! MaybeMkdir(path)
            if isdirectory(a:path) == 0
              call mkdir(a:path, 'p')
            endif
          endfunction

          " Toggle between paste and no paste.
          function! TogglePaste()
            if(&paste == 1)
              set nopaste
              echom 'Switched to no paste.'
            else
              set paste
              echom 'Switched to paste.'
            endif
          endfunc
          nmap <silent> <leader>p :call TogglePaste()<CR>

          " Toggle between absolute line numbers and relative line numbers.
          function! ToggleNumber()
            if(&relativenumber == 1)
              set norelativenumber
              set number
              echom 'Switched to absolute line numbers.'
            else
              set relativenumber
              echom 'Switched to relative line numbers.'
            endif
          endfunc
          nmap <silent> <leader>tl :call ToggleNumber()<CR>

          " Capture the output of an ex command.
          function! Redir(cmd)
            " Close any scratch windows.
            for win in range(1, winnr('$'))
              if getwinvar(win, 'scratch')
                execute win . 'windo close'
              endif
            endfor

            if a:cmd =~# '^!'
              " Handle commands starting with `!` by running commands on the system.
              execute "let output = system('" . substitute(a:cmd, '^!', ''\'''\', ''\'''\') . "')"
            else
              " Else run input as ex commands.
              redir => output
              execute a:cmd
              redir END
            endif

            " Open a new scratch window.
            vnew
            let w:scratch = 1
            setlocal nobuflisted buftype=nofile bufhidden=wipe noswapfile

            " Add the command output.
            call setline(1, split(output, "\n"))
          endfunction
          command! -nargs=1 -complete=command Redir silent call Redir(<f-args>)

          function! EchoAU(type, message)
            if has('autocmd')
              augroup EchoAU
                autocmd!
                " Echo the message after entering a file, useful for when
                " we're entering a file (like on SwapExists) and our echo will be
                " eaten.
                autocmd BufWinEnter * echohl a:type
                exec 'autocmd BufWinEnter * echon "\r'.printf('%-60s', a:message).'"'
                autocmd BufWinEnter * echohl NONE

                " Remove these auto commands so that they don't run on entering
                " the next buffer.
                autocmd BufWinEnter * augroup EchoAU
                autocmd BufWinEnter * autocmd!
                autocmd BufWinEnter * augroup END
              augroup END
            endif
          endfunction

          function! HandleSwap(filename)
            " If the swap file is old, delete. If it is new, recover.
            if getftime(v:swapname) < getftime(a:filename)
              let v:swapchoice = 'e'
              call EchoAU('WarningMsg', 'Deleted older swapfile.')
            else
              let v:swapchoice = 'r'
              call EchoAU('WarningMsg', 'Detected newer swapfile, recovering.')
            endif
          endfunc

          let g:ale_awk_gawk_executable = '${gawk}/bin/gawk'
          let g:ale_nix_nixpkgsfmt_executable = SearchBuildDirsOr('${unstable.nixpkgs-fmt}/bin/nixpkgs-fmt')
          let g:gutentags_ctags_executable = '${universal-ctags}/bin/ctags'
          let termdebugger = '${gdb}/bin/gdb'

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
                  %!${llvm_7}/bin/llvm-dis
                  setl ft=llvm nobinary ro
                  call EchoAU('None', 'Disassembled LLVM IR, viewing as read-only')
                endif
              endfunc

              au BufRead,BufNewFile * call DisassembleLLVM()
            augroup END
          endif

          " Define colour variables.
          let s:black = '#${basic.black}'
          let s:c_black = 0
          let s:red = '#${basic.red}'
          let s:c_red = 1
          let s:green = '#${basic.green}'
          let s:c_green = 2
          let s:yellow = '#${basic.yellow}'
          let s:c_yellow = 3
          let s:blue = '#${basic.blue}'
          let s:c_blue = 4
          let s:magenta = '#${basic.magenta}'
          let s:c_magenta = 5
          let s:cyan = '#${basic.cyan}'
          let s:c_cyan = 6
          let s:white = '#${basic.white}'
          let s:c_white = 7
          let s:bright_black = '#${basic.brightBlack}'
          let s:c_bright_black = 8
          let s:bright_red = '#${basic.brightRed}'
          let s:c_bright_red = 9
          let s:bright_green = '#${basic.brightGreen}'
          let s:c_bright_green = 10
          let s:bright_yellow = '#${basic.brightYellow}'
          let s:c_bright_yellow = 11
          let s:bright_blue = '#${basic.brightBlue}'
          let s:c_bright_blue = 12
          let s:bright_magenta = '#${basic.brightMagenta}'
          let s:c_bright_magenta = 13
          let s:bright_cyan = '#${basic.brightCyan}'
          let s:c_bright_cyan = 14
          let s:bright_white = '#${basic.brightWhite}'
          let s:c_bright_white = 15

          " Set NeoVim terminal mode colour scheme.
          let g:terminal_color_0 = s:black
          let g:terminal_color_1 = s:red
          let g:terminal_color_2 = s:green
          let g:terminal_color_3 = s:yellow
          let g:terminal_color_4 = s:blue
          let g:terminal_color_5 = s:magenta
          let g:terminal_color_6 = s:cyan
          let g:terminal_color_7 = s:white
          let g:terminal_color_8 = s:bright_black
          let g:terminal_color_9 = s:bright_red
          let g:terminal_color_10 = s:bright_green
          let g:terminal_color_12 = s:bright_yellow
          let g:terminal_color_13 = s:bright_blue
          let g:terminal_color_14 = s:bright_magenta
          let g:terminal_color_15 = s:bright_cyan
          let g:terminal_color_16 = s:bright_white

          let s:bg = '#1C1C1C'
          let s:c_bg = 234
          let s:fg = s:bright_white
          let s:c_fg = s:c_bright_white

          " Use 24-bit colour.
          set termguicolors
          " Enable syntax highlighting.
          syntax enable
          " Apply colourscheme before our own highlighting.
          colorscheme hybrid
          " Use custom terminal colours.
          let g:hybrid_custom_term_colors = 1

          " Show incomplete commands.
          set showcmd
          " Highlight the current line.
          set nocursorline
          " Lazy redraw.
          set lazyredraw
          " Line Numbers
          set number
          " Display messages for changes (ie. yank, delete, etc.)
          set report=0
          " Show matching brackets.
          set showmatch
          " Matching bracket duration.
          set matchtime=5
          " Shut up, Vim.
          set visualbell
          " Use relative line numbers.
          set relativenumber
          " Don't display '-- INSERT --', handled by statusline.
          set noshowmode
          " Enable keeping track of undo history.
          set undofile
          " Set defaults for when detection fails or in new files.
          set tabstop=4 softtabstop=4
          " Configure wildmenu for file name tab completion.
          set wildmode=longest,list,full
          " Highlight matches.
          set hlsearch
          " Ignore case when searching.
          set ignorecase
          " Don't ignore case when different cases searched for.
          set smartcase
          " Sets the expected modeline format.
          set modeline modelines=1
          " Enable the mouse.
          set mouse=a
          " Enable folding.
          set foldenable
          " Open 10 levels of folds by default.
          set foldlevelstart=10
          " 10 nested folds max.
          set foldnestmax=10
          " Fold based on indentation.
          set foldmethod=indent
          " Set the background to dark.
          set background=dark
          " Don't prompt when switching between open buffers w/ changes.
          set hidden
          " Don't add 2 spaces after end of sentence.
          set nojoinspaces
          " Format text (r - insert comment leader on 'o' and 'O'; q - allow formatting with 'gq').
          set formatoptions+=rq
          " Indicates a fast terminal connection.
          set ttyfast
          " Allow : in filenames.
          set isfname-=:.
          " Use 24-bit colour.
          set termguicolors

          " Display the tab characters and end of line characters.
          set list
          " Non breaking space:
          " * Circled Reverse Solidus (U+29B8, utf-8: E2 A6 B8)
          set listchars=nbsp:⦸
          " Trailing space:
          " * Middle Dot (U+00B7, utf-8: C2 B7)
          set listchars+=trail:·
          " Tab stop:
          " * Black Right-Pointing Small Triangle (U+25B8, utf-8: E2 96 B8)
          set listchars+=tab:▸\ ,
          " End of line:
          " * Not Sign (U+00AC, utf-8: C2 AC)
          set listchars+=eol:¬
          " Line extended beyond screen when nowrap:
          " * Right-Pointing Double Angle Quotation Mark (U+00BB, utf-8: C2 BB)
          set listchars+=extends:»
          " Line preceded beyond screen when nowrap:
          " * Left-Pointing Double Angle Quotation Mark (U+00AB, utf-8: C2 AB)
          set listchars+=precedes:«

          " Enable termdebug's floating hover support.
          let g:termdebug_useFloatingHover=1

          " Enable syntax highlighting.
          syntax enable
          colorscheme hybrid

          " Colour 40 columns after column 80.
          let &colorcolumn='100,'.join(range(140, 1000, 40), ',')

          if has('autocmd')
            augroup vimrc
              au!
              " Syntax of these languages is dependant on tabs/spaces.
              au FileType make setlocal ts=8 sts=8 sw=8 noexpandtab
              au FileType yaml setlocal ts=2 sts=2 sw=2 expandtab nosmarttab
              au FileType puppet setlocal ts=2 sts=2 sw=2 expandtab nosmarttab
              au FileType ruby setlocal ts=2 sts=2 sw=2 expandtab nosmarttab

              " Markdown indentation should mirror YAML for use in frontmatter, also enable
              " spelling.
              au FileType markdown setlocal ts=2 sts=2 sw=2 expandtab nosmarttab spell
              au FileType markdown set foldexpr=NestedMarkdownFolds()

              " Git commits should break lines at 72 characters.
              au FileType gitcommit setlocal tw=72

              " Always use spaces for the package.json file.
              au BufNewFile,BufRead package.json setlocal ts=2 sts=2 sw=2 expandtab nosmarttab sts=2

              " Correct file type/extension mismatches.
              au BufNewFile,BufRead *.reg setlocal ft=registry
              au BufNewFile,BufRead *.tera setlocal ft=jinja
              au BufNewFile,BufRead *.nuspec setlocal ft=xml
              au BufNewFile,BufRead *.hocon setlocal ft=hocon
              au BufNewFile,BufRead *.md setlocal ft=markdown
              au BufNewFile,BufRead *.pp setlocal ft=puppet

              " Highlight special-cased file names.
              au BufNewFile,BufRead Jenkinsfile setlocal ft=groovy
              au BufNewFile,BufRead Vagrantfile setlocal ft=ruby

              " Automatically handle most swap prompts.
              au SwapExists * call HandleSwap(expand('<afile>:p'))

              " Do not keep track of undo history in temporary files.
              au BufWritePre /tmp/* setlocal noundofile

              " Highlight conflict markers in any filetype.
              au FileType * call matchadd('Todo', '^\(<<<<<<<\s.*\||||||||\|=======\|>>>>>>>\s.*\)$')

              " Make sure that enter works in the quickfix list.
              au BufReadPost quickfix nnoremap <buffer> <CR> <CR>

              " Override the netrw CTRL+L binding and preserve navigation to tmux.
              au FileType netrw nnoremap <buffer> <silent> <c-l> :TmuxNavigateRight<cr>
            augroup END
          endif

          " Use custom terminal colours.
          let g:hybrid_custom_term_colors = 1

          " Don't automatically jump to first result or the search results.
          let g:FerretAutoJump = 0
          " Ferret should prefer rg.
          let g:FerretExecutable = 'rg'

          " Silences an error about this being unset.
          let g:gutentags_exclude_filetypes = []

          " Only generate tags for files tracked by Git (e.g. stops LLVM being included for Rust)
          let g:gutentags_file_list_command = {
          \   'markers': { '.git': 'git ls-files', '.hg': 'hg files'  },
          \ }

          " Enable global loading of local .vimrc files.
          let g:localvimrc_enable = 1

          " Ask me before loading any files.
          let g:localvimrc_ask = 1

          " Keep track of which files I've loaded in the past and don't ask again.
          " (only if answer was uppercase)
          let g:localvimrc_persistent = 1

          " Disable pandoc's markdown folding.
          let g:pandoc#filetypes#pandoc_markdown = 0
          let g:pandoc#folding#fdc = 0

          let g:vim_markdown_conceal = 0
          let g:markdown_syntax_conceal = 0

          " Enable fenced language highlighting.
          let g:markdown_fenced_languages = ['c', 'python', 'cpp', 'bash=sh', 'lua', 'rust']

          " Allow line numbers in netrw buffers.
          let g:netrw_bufsettings = 'noma nomod nu nobl nowrap ro'

          " Disable rust syntax highlighting from polyglot, use rust.vim manually instead.
          let g:polyglot_disabled = ['rust']

          " Use Postgres highlighting for all SQL.
          let g:sql_type_default = 'pgsql'

          " Specify which VCS to check for.
          let g:signify_vcs_list = [ 'git', 'yadm' ]

          " Work in near-realtime.
          let g:signify_realtime = 1

          " Disable two of the sign update methods as they write the buffer.
          let g:signify_cursorhold_normal = 0
          let g:signify_cursorhold_insert = 0

          " Enable automatic disassembly of binary SPIR-V.
          let g:spirv_enable_autoassemble = 1

          " Fix completion bug in some versions of Vim.
          set completeopt=menu,menuone,preview,noselect,noinsert

          " Use deoplete.
          let g:deoplete#enable_at_startup = 1

          " Set formatting.
          let g:ale_echo_msg_error_str = 'E'
          let g:ale_echo_msg_warning_str = 'W'
          let g:ale_echo_msg_format = '[%linter%] %s [%severity%]'

          " Set linters and fixers.
          let g:ale_linters_explicit = 1
          let g:ale_linters = {
          \   'awk': [ 'gawk' ],
          \   'c': [ 'clangd', 'clangtidy' ],
          \   'cpp': [ 'clangd', 'clangtidy' ],
          \   'cuda': [ 'nvcc' ],
          \   'haskell': [ 'hie' ],
          \   'llvm': [ 'llc' ],
          \   'lua': [ 'luac' ],
          \   'json': [ 'jq' ],
          \   'python': [ 'flake8' ],
          \   'ruby': [ 'rubocop' ],
          \   'rust': [ 'cargo', 'rls' ],
          \   'sh': [ 'shell', 'shellcheck' ],
          \   'vim': [ 'vint' ],
          \   'zsh': [ 'shell', 'shellcheck' ],
          \ }

          " Use stable Rust for RLS.
          let g:ale_rust_rls_toolchain = 'stable'

          " Limit clangtidy checks.
          let g:ale_c_clangtidy_checks = [ 'clang-analyzer-*', 'cppcoreguidelines-*', 'llvm-*' ]
          let g:ale_cpp_clangtidy_checks = g:ale_c_clangtidy_checks

          " `*` means any language not matched explicitly, not all languages (ie. if ft is `rust`, ALE will
          " only load the `rust` list, not `rust` and `*`).
          let g:ale_fixers = {
          \   '*': [ 'remove_trailing_lines', 'trim_whitespace' ],
          \   'cpp': [ 'clang-format', 'remove_trailing_lines', 'trim_whitespace' ],
          \   'cuda': [ 'clang-format', 'remove_trailing_lines', 'trim_whitespace' ],
          \   'haskell': [ 'ormolu', 'remove_trailing_lines', 'trim_whitespace' ],
          \   'nix': [ 'nixpkgs-fmt', 'remove_trailing_lines', 'trim_whitespace' ],
          \   'opencl': [ 'clang-format', 'remove_trailing_lines', 'trim_whitespace' ],
          \   'python': [ 'black', 'remove_trailing_lines', 'trim_whitespace' ],
          \   'rust': [ 'rustfmt', 'remove_trailing_lines', 'trim_whitespace' ],
          \   'sh': ['shfmt', 'remove_trailing_lines', 'trim_whitespace' ],
          \ }

          " Don't apply formatters that re-write files on save, these sometimes aren't used in projects.
          " Use `.lvimrc` to override this.
          let g:ale_fix_on_save = 1
          let g:ale_fix_on_save_ignore = {
          \   'cpp': [ 'clang-format' ],
          \   'cmake': [ 'cmakeformat' ],
          \   'cuda': [ 'clang-format' ],
          \   'opencl': [ 'clang-format' ],
          \   'python': [ 'black' ],
          \ }

          " Disable Ale for `.tex.njk` files.
          let g:ale_pattern_options = {
          \   '.*\.tex\.njk$': { 'ale_enabled': 0 },
          \ }

          " Show hover balloon when over a definition.
          let g:ale_set_balloons = 1

          " Use clippy instead of cargo.
          let g:ale_rust_cargo_use_clippy = 1

          let g:lightline = {}
          let g:lightline.colorscheme = 'davidtwco'
          let g:lightline.separator = { 'left': '⬣', 'right': '⬣' }
          let g:lightline.subseparator = g:lightline.separator

          let g:lightline.active = {
          \   'left': [
          \       [ 'mode' ],
          \       [ 'paste', 'spell', 'gitbranch', 'readonly' ],
          \       [ 'filename' ]
          \   ],
          \   'right': [
          \       [ 'linter_checking', 'linter_errors', 'linter_warnings', 'linter_ok' ],
          \       [ 'gutentags' ],
          \       [ 'fileformat', 'fileencoding', 'filetype', 'charvaluehex', 'lineinfo', 'percent' ]
          \   ]
          \ }

          let g:lightline.component_expand = {
          \   'linter_checking': 'lightline#ale#checking',
          \   'linter_warnings': 'lightline#ale#warnings',
          \   'linter_errors': 'lightline#ale#errors',
          \   'linter_ok': 'lightline#ale#ok',
          \ }

          let g:lightline.component_type = {
          \   'linter_checking': 'left',
          \   'linter_warnings': 'warning',
          \   'linter_errors': 'error',
          \   'linter_ok': 'left',
          \ }

          let g:lightline.component_function = {
          \   'gitbranch': 'LightlineGitBranch',
          \   'gutentags': 'LightlineGutentags',
          \   'readonly': 'LightlineReadonly',
          \   'charvaluehex': 'LightlineCharacterHex',
          \   'fileencoding': 'LightlineFileEncoding',
          \   'fileformat': 'LightlineFileFormat',
          \   'filetype': 'LightlineFileType',
          \   'filename': 'LightlineFilename',
          \   'tagbar': 'LightlineTagbar'
          \ }

          function! LightlineFilename()
            " Get the full path of the current file.
            let filepath =  expand('%:p')
            let modified = &modified ? ' +' : ' '

            " If the filename is empty, then display
            " nothing as appropriate.
            if empty(filepath)
              return '[No Name]' . modified
            endif

            " Find the correct expansion depending on whether Vim has
            " autochdir.
            let mod = (exists('+acd') && &autochdir) ? ':~' : ':~:.'

            " Apply the above expansion to the expanded file path and split
            " by the separator.
            let shortened_filepath = fnamemodify(filepath, mod)

            if len(shortened_filepath) < (winwidth('%') / 1.8)
              return shortened_filepath.modified
            endif

            " Ensure that we have the correct slash for the OS.
            let dirsep = has('win32') && ! &shellslash ? '\' : '/'
            " Check if the filepath was shortened above.
            let was_shortened = filepath != shortened_filepath

            " Split the filepath.
            let filepath_parts = split(shortened_filepath, dirsep)

            " Take the first character from each part of the path (except the tidle and filename).
            let initial_position = was_shortened ? 0 : 1
            let excluded_parts = filepath_parts[initial_position:-2]
            let shortened_paths = map(excluded_parts, 'v:val[0]')

            " Recombine the shortened paths with the tilde and filename.
            let combined_parts = shortened_paths + [filepath_parts[-1]]
            let combined_parts = (was_shortened ? [] : [filepath_parts[0]]) + combined_parts

            " Recombine into a single string.
            let finalpath = join(combined_parts, dirsep)
            return finalpath . modified
          endfunction

          " Define an arbitrary number of columns, below which the statusline becomes less detailed.
          let s:collapse_threshold = 106

          function! LightlineGutentags()
            " Show the tag generation status, with detail depending on window width.
            return gutentags#statusline(''\'''\', ''\'''\', winwidth(0) > s:collapse_threshold ? '△ Tagging...' : '△')
          endfunction

          function! LightlineCharacterHex()
            " Don't show the character hex on windows that aren't wide.
            "
            " Vim provides a handy '%B' escape code for use in 'statusline', but it's not easy to get
            " the hex value of a character under the cursor without that.
            let hex =  printf('%X', char2nr(matchstr(getline('.'), '\%' . col('.') . 'c.')))
            return winwidth(0) > s:collapse_threshold ? hex : ''\'''\'
          endfunction

          function! LightlineFileEncoding()
            " Don't show the file encoding on windows that aren't wide.
            return winwidth(0) > s:collapse_threshold ? &fileencoding : ''\'''\'
                endfunction

          function! LightlineGitBranch()
            " Don't show the git branch on windows that aren't wide.
            return winwidth(0) > s:collapse_threshold ? fugitive#head() : ''\'''\'
          endfunction

          function! LightlineFileFormat()
            " Don't show the file format on windows that aren't wide.
              return winwidth(0) > s:collapse_threshold ? &fileformat : ''\'''\'
          endfunction

          function! LightlineFileType()
            " Don't show the file type on windows that aren't wide.
            return winwidth(0) > s:collapse_threshold ? (&filetype !=# ''\'''\' ? &filetype : 'no ft') : ''\'''\'
          endfunction

          function! LightlineReadonly()
            " Don't show any read-only indicator for writable files.
            return &readonly && &filetype !=# 'help' ? 'RO' : ''\'''\'
          endfunction

          function! LightlineTagbar()
            " Don't show the current tag on windows that aren't wide.
            return winwidth(0) > s:collapse_threshold ? tagbar#currenttag('%s', ''\'''\' 'f') : ''\'''\'
          endfunction

          " Define a custom colorscheme that matches the tmux configuration.
          let s:p = {
          \   'normal': {},
          \   'inactive': {},
          \   'insert': {},
          \   'replace': {},
          \   'visual': {},
          \   'terminal': {},
          \   'command': {},
          \   'tabline': {}
          \ }

          " All palettes have the form:
          "   s:p.{mode}.{where] = [ [ {guifg}, {guibg}, {ctermfg}, {ctermbg} ] ]

          " Inactive windows have terminal background and a muted foreground.
          let s:p.inactive.middle = [ [s:bright_black, s:bg, s:c_bright_black, s:c_bg] ]
          let s:p.inactive.right = [ s:p.inactive.middle[0], s:p.inactive.middle[0] ]
          let s:p.inactive.left = [ s:p.inactive.middle[0], s:p.inactive.middle[0] ]

          " Normal mode's left statusline has terminal background with green foreground (for `NORMAL`),
          " followed gray foreground (for the git branch or `PASTE`) and then white foreground for filename.
          let s:p.normal.left = [
          \   [s:bright_green, s:bg, s:c_bright_green, s:c_bg],
          \   [s:bright_black, s:bg, s:c_bright_black, s:c_bg],
          \   [s:fg, s:bg, s:c_fg, s:c_bg]
          \ ]
          let s:p.normal.middle = [ [ s:bright_black, s:bg, s:c_bright_black, s:c_bg] ]
          " Normal mode's right status line has terminal background with green foreground (for ALE),
          " followed by white foreground (for Gutentags), finished off with bright black foreground
          " (for line/col/hex/encoding, etc).
          let s:p.normal.right = [
          \   [s:bright_green, s:bg, s:c_bright_green, s:c_bg],
          \   [s:white, s:bg, s:c_white, s:c_bg],
          \   s:p.normal.left[1], s:p.normal.left[2]
          \ ]

          let s:p.normal.error = [ [s:bright_red, s:bg, s:c_bright_red, s:c_bg] ]
          let s:p.normal.warning = [ [s:yellow, s:bg, s:c_yellow, s:c_bg] ]

          " Insert mode has terminal background and blue foreground, followed by the same as normal
          " mode.
          let s:p.insert.left = [
          \   [s:bright_blue, s:bg, s:c_bright_blue, s:c_bg],
          \   s:p.normal.left[1], s:p.normal.left[2]
          \ ]
          let s:p.insert.middle = s:p.normal.middle
          let s:p.insert.right = s:p.normal.right

          " Insert mode has terminal background and red foreground, followed by the same as normal mode.
          let s:p.replace.left = [
          \   [s:bright_red, s:bg, s:c_bright_red, s:c_bg],
          \   s:p.normal.left[1], s:p.normal.left[2]
          \ ]
          let s:p.replace.middle = s:p.normal.middle
          let s:p.replace.right = s:p.normal.right

          " Visual mode has terminal background and yellow foreground, followed by the same as normal
          " mode.
          let s:p.visual.left = [
          \   [s:bright_yellow, s:bg, s:c_bright_yellow, s:c_bg],
          \   s:p.normal.left[1], s:p.normal.left[2]
          \ ]
          let s:p.visual.middle = s:p.normal.middle
          let s:p.visual.right = s:p.normal.right

          " Terminal mode has terminal background and magenta foreground, followed by the same as normal
          " mode.
          let s:p.terminal.left = [
          \   [s:bright_magenta, s:bg, s:c_bright_magenta, s:c_bg],
          \   s:p.normal.left[1], s:p.normal.left[2]
          \ ]
          let s:p.terminal.middle = s:p.normal.middle
          let s:p.terminal.right = s:p.normal.right

          " Command mode has terminal background and cyan foreground, followed by the same as normal
          " mode.
          let s:p.command.left = [
          \   [s:bright_cyan, s:bg, s:c_bright_cyan, s:c_bg],
          \   s:p.normal.left[1], s:p.normal.left[2]
          \ ]
          let s:p.command.middle = s:p.normal.middle
          let s:p.command.right = s:p.normal.right

          " Tabline has current tab in white, other tabs in gray, and terminal background.
          let s:p.tabline.left = [ [s:white, s:bg, s:c_white, s:c_bg] ]
          let s:p.tabline.tabsel = [ [s:fg, s:bg, s:c_fg, s:c_bg] ]
          let s:p.tabline.middle = s:p.tabline.left
          let s:p.tabline.right = [ [s:white, s:bg, s:c_white, s:c_bg], [s:fg, s:bg, s:c_fg, s:c_bg] ]

          let g:lightline#colorscheme#davidtwco#palette = s:p

          " Map %% to the current opened file's path.
          cnoremap %% <C-R>=fnameescape(expand('%:h')).'/'<CR>

          " Map helpful commands for editing files in that directory.
          map <leader>ew :e %%
          map <leader>es :sp %%
          map <leader>ev :vsp %%
          map <leader>et :tabe %%

          " Set leader mappings for fzf.
          nnoremap <leader>pf :Files<CR>
          nnoremap <leader>pg :GFiles<CR>
          nnoremap <leader>pc :Commits<CR>
          nnoremap <leader>pb :Buffers<CR>
          nnoremap <leader>pt :Tags<CR>
          nnoremap <leader>pr :Rg<CR>

          " Set quicker mappings for fzf.
          nnoremap <C-p> :Files<CR>
          nnoremap <C-q> :Tags<CR>
          nnoremap <C-s> :Buffers<CR>
          nnoremap <C-x> :Rg<CR>

          " Set visual mappings for fzf.
          nmap <leader><tab> <plug>(fzf-maps-n)
          xmap <leader><tab> <plug>(fzf-maps-x)
          omap <leader><tab> <plug>(fzf-maps-o)

          " Insert mode completion
          imap <c-x><C-k> <plug>(fzf-complete-word)
          imap <c-x><C-f> <plug>(fzf-complete-path)
          imap <c-x><C-j> <plug>(fzf-complete-file-ag)
          imap <c-x><C-l> <plug>(fzf-complete-line)

          " `w!!` will save a file opened without sudo.
          cnoremap w!! execute 'silent! write !sudo tee % >/dev/null' <bar> edit!

          if has('nvim') || has('terminal')
            " Bind ESC to exit terminal mode.
            tnoremap <Esc> <C-\><c-n>
            " Bind Ctrl + V and ESC to send ESC to terminal process.
            tnoremap <C-v><Esc> <Esc>
          endif

          " Set mappings for ALE.
          nmap <leader>ad <plug>(ale_go_to_definition)
          nmap <leader>ar <plug>(ale_find_references)
          nmap <leader>ah <plug>(ale_hover)
          nmap <leader>af <plug>(ale_fix)
          nmap <leader>at <plug>(ale_detail)
          nmap <leader>an <plug>(ale_next_wrap)
          nmap <leader>ap <plug>(ale_previous_wrap)

          " Set quicker mappings for ALE.
          nmap <C-n> <plug>(ale_next_wrap)
          nmap <C-m> <plug>(ale_previous_wrap)

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
      in
        prefix + body;
      viAlias = true;
      vimAlias = true;
      withNodeJs = true;
      withPython = true;
      withPython3 = true;
      package = unstable.neovim;
      plugins =
        let
          sources = import ../../../nix/sources.nix;
        in
          # Define our own plugin list with pinned versions so that we can guarantee
          # a working configuration. Some plugins require `dontBuild` as they include
          # `Makefile`s to run tests and build docs.
          [
            # Sensible defaults for Vim.
            (pkgs.vimUtils.buildVimPlugin { name = "vim-sensible"; src = sources.vim-sensible; })
            # Polyglot adds a bunch of syntax handling for different languages and tools, check if
            # new languages are included before adding them manually.
            (pkgs.vimUtils.buildVimPlugin { name = "vim-polyglot"; src = sources.vim-polyglot; })
            # Rust (included in Polyglot, but explicitly disabled so that we can use newer versions).
            (pkgs.vimUtils.buildVimPlugin { name = "rust.vim"; src = sources."rust.vim"; })
            # Other languages
            (pkgs.vimUtils.buildVimPlugin { name = "vim-hocon"; src = sources.vim-hocon; })
            (pkgs.vimUtils.buildVimPlugin { name = "vim-pandoc"; src = sources.vim-pandoc; })
            (
              pkgs.vimUtils.buildVimPlugin {
                name = "vim-pandoc-syntax";
                src = sources.vim-pandoc-syntax;
              }
            )
            (pkgs.vimUtils.buildVimPlugin { name = "vim-spirv"; src = sources.vim-spirv; })
            # Generate ctags for projects.
            (pkgs.vimUtils.buildVimPlugin { name = "vim-gutentags"; src = sources.vim-gutentags; })
            # Auto-adds `end` where appropriate.
            (pkgs.vimUtils.buildVimPlugin { name = "vim-endwise"; src = sources.vim-endwise; })
            # Hybrid colour scheme
            (pkgs.vimUtils.buildVimPlugin { name = "vim-hybrid"; src = sources.vim-hybrid; })
            # Autocompletion/linting/fixing.
            (pkgs.vimUtils.buildVimPlugin { name = "ale"; src = sources.ale; })
            (
              pkgs.vimUtils.buildVimPlugin {
                name = "deoplete.nvim";
                src = sources."deoplete.nvim";
                dontBuild = true;
              }
            )
            (pkgs.vimUtils.buildVimPlugin { name = "lightline-ale"; src = sources.lightline-ale; })
            # Add operator to comment out lines.
            (pkgs.vimUtils.buildVimPlugin { name = "vim-commentary"; src = sources.vim-commentary; })
            # Improvements to netrw.
            (pkgs.vimUtils.buildVimPlugin { name = "vim-vinegar"; src = sources.vim-vinegar; })
            # Show git changes in the sign column
            (pkgs.vimUtils.buildVimPlugin { name = "vim-signify"; src = sources.vim-signify; })
            # Git wrappers
            (pkgs.vimUtils.buildVimPlugin { name = "vim-fugitive"; src = sources.vim-fugitive; })
            (pkgs.vimUtils.buildVimPlugin { name = "vim-rhubarb"; src = sources.vim-rhubarb; })
            (
              pkgs.vimUtils.buildVimPlugin {
                name = "fugitive-gitlab.vim";
                src = sources."fugitive-gitlab.vim";
              }
            )
            # Async build and test dispatcher
            (pkgs.vimUtils.buildVimPlugin { name = "vim-dispatch"; src = sources.vim-dispatch; })
            # Helper functions for unix commands.
            (pkgs.vimUtils.buildVimPlugin { name = "vim-eunuch"; src = sources.vim-eunuch; })
            # Easy navigation between vim splits and tmux panes.
            (
              pkgs.vimUtils.buildVimPlugin {
                name = "vim-tmux-navigator";
                src = sources.vim-tmux-navigator;
              }
            )
            # Focus events and clipboard for tmux.
            (
              pkgs.vimUtils.buildVimPlugin {
                name = "vim-tmux-clipboard";
                src = sources.vim-tmux-clipboard;
              }
            )
            (
              pkgs.vimUtils.buildVimPlugin {
                name = "vim-tmux-focus-events";
                src = sources.vim-tmux-focus-events;
              }
            )
            # Switch to absolute line numbers for buffers that aren't focused.
            (
              pkgs.vimUtils.buildVimPlugin {
                name = "vim-numbertoggle";
                src = sources.vim-numbertoggle;
              }
            )
            # Fuzzy file search.
            (pkgs.vimPlugins.fzfWrapper)
            (pkgs.vimUtils.buildVimPlugin { name = "fzf.vim"; src = sources."fzf.vim"; })
            # Statusline
            (pkgs.vimUtils.buildVimPlugin { name = "lightline"; src = sources."lightline.vim"; })
            # Show marks in sign column.
            (pkgs.vimUtils.buildVimPlugin { name = "vim-signature"; src = sources.vim-signature; })
            # Adds `s` motion for matching any two characters.
            (
              pkgs.vimUtils.buildVimPlugin {
                name = "vim-sneak";
                src = sources.vim-sneak;
                dontBuild = true;
              }
            )
            # Improve `.` (repeat) for plugin maps.
            (
              pkgs.vimUtils.buildVimPlugin {
                name = "vim-repeat";
                src = sources.vim-repeat;
              }
            )
            # Terminal utilities.
            (
              pkgs.vimUtils.buildVimPlugin {
                name = "split-term.vim";
                src = sources."split-term.vim";
              }
            )
            # Handy bracket matchings.
            (pkgs.vimUtils.buildVimPlugin { name = "vim-unimpaired"; src = sources.vim-unimpaired; })
            # Commands for interactig with surroundings ("", '', {}, etc).
            (pkgs.vimUtils.buildVimPlugin { name = "vim-surround"; src = sources.vim-surround; })
            # Multi-file search (`Ack`)
            (pkgs.vimUtils.buildVimPlugin { name = "ferret"; src = sources.ferret; })
            # Improved incremental search - hides search highlighting after moving cursor.
            (pkgs.vimUtils.buildVimPlugin { name = "is.vim"; src = sources."is.vim"; })
            # Enhanced `%` functionality.
            (pkgs.vimUtils.buildVimPlugin { name = "vim-matchit"; src = sources.vim-matchit; })
            # Look for project specific `.lvimrc` files.
            (
              pkgs.vimUtils.buildVimPlugin {
                name = "vim-localvimrc";
                src = sources.vim-localvimrc;
                dontBuild = true;
              }
            )
            # Scratchpad
            (pkgs.vimUtils.buildVimPlugin { name = "scratch.vim"; src = sources."scratch.vim"; })
            # Text filtering and alignment.
            (pkgs.vimUtils.buildVimPlugin { name = "tabular"; src = sources.tabular; })
            # Visualize the undo tree.
            (pkgs.vimUtils.buildVimPlugin { name = "vim-mundo"; src = sources.vim-mundo; })
            # Search/substitution/abbreviation of word variations.
            (pkgs.vimUtils.buildVimPlugin { name = "vim-abolish"; src = sources.vim-abolish; })
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
