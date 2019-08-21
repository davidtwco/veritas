" Use custom terminal colours.
let g:hybrid_custom_term_colors = 1

" Don't automatically jump to first result or the search results.
let g:FerretAutoJump = 0

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

" vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
