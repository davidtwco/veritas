" Make pressing `esc` more responsive.
set timeoutlen=0 ttimeoutlen=0
" Show ruler.
set ruler
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
set mat=5
" Shut up, Vim.
set visualbell
" Always show the status line.
set laststatus=2
" Use relative line numbers.
set relativenumber
" Don't display '-- INSERT --', handled by statusline.
set noshowmode
" Display the tab characters and end of line characters.
set list
set listchars=tab:▸\ ,eol:¬
" Enable keeping track of undo history.
set undofile
" Set defaults for when detection fails or in new files.
set ts=4 sts=4 sw=4 et
" Turn on wildmenu for file name tab completion.
set wildmode=longest,list,full
set wildmenu
" Automatically reload files if changed from outside.
set autoread
" Highlight matches.
set hlsearch
" Highlight matches as we type.
set incsearch
" Ignore case when searching.
set ignorecase
" Don't ignore case when different cases searched for.
set smartcase
" Keep a minimum of 5 line below the cursor.
set scrolloff=5
" Keep a minimum of 5 columns left of the cursor.
set sidescrolloff=5
" Sets the expected modeline format.
set modeline modelines=1
" Increase history.
set history=1000
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
" We can delete backwards over anything.
set backspace=indent,eol,start
" Set the background to dark.
set background=dark
" Don't prompt when switching between open buffers w/ changes.
set hidden

" Enable syntax highlighting.
syntax enable
colorscheme hybrid

" Colour 40 columns after column 80.
let &colorcolumn="100,".join(range(140, 1000, 40), ",")
" Set the colour of the colour column (used to highlight where lines should wrap).
highlight ColorColumn ctermbg=8 guibg=lightgrey

" Delete comment character when joining commented lines
if v:version > 703 || v:version == 703 && has("patch541")
  set formatoptions+=j
endif

if has("autocmd")
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
  augroup END
endif

" vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
