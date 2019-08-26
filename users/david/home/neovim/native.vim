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
set tabstop=4 softtabstop=4 shiftwidth=4 expandtab
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

" Enable syntax highlighting.
syntax enable
colorscheme hybrid

" Colour 40 columns after column 80.
let &colorcolumn='100,'.join(range(140, 1000, 40), ',')
" Set the colour of the colour column (used to highlight where lines should wrap).
highlight ColorColumn ctermbg=8 guibg=lightgrey

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
  augroup END
endif

" vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
