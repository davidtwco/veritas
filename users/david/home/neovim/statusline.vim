" Define colour variables.
let s:black = '#282A2E'
let s:c_black = 0
let s:red = '#A54242'
let s:c_red = 1
let s:green = '#8C9440'
let s:c_green = 2
let s:yellow = '#DE935F'
let s:c_yellow = 3
let s:blue = '#5F819D'
let s:c_blue = 4
let s:magenta = '#85678F'
let s:c_magenta = 5
let s:cyan = '#5E8D87'
let s:c_cyan = 6
let s:white = '#707880'
let s:c_white = 7
let s:bright_black = '#373B41'
let s:c_bright_black = 8
let s:bright_red = '#CC6666'
let s:c_bright_red = 9
let s:bright_green = '#B5BD68'
let s:c_bright_green = 10
let s:bright_yellow = '#F0C674'
let s:c_bright_yellow = 11
let s:bright_blue = '#81A2BE'
let s:c_bright_blue = 12
let s:bright_magenta = '#B294BB'
let s:c_bright_magenta = 13
let s:bright_cyan = '#8ABEB7'
let s:c_bright_cyan = 14
let s:bright_white = '#C5C8C6'
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
\       [ 'obsession' ],
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
\   'obsession': 'LightlineObsessionStatus',
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
  let modified = &modified ? ' +' : ''

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
  return gutentags#statusline('', '', winwidth(0) > s:collapse_threshold ? '△ Tagging...' : '△')
endfunction

function! LightlineObsessionStatus()
  " Show the obsession status if the plugin is enabled, with detail depending on window width.
  let tracked = winwidth(0) > s:collapse_threshold ? '● Tracked' : '●'
  let untracked = winwidth(0) > s:collapse_threshold ? '○ Untracked' : '○'
  return exists('*ObsessionStatus') ? ObsessionStatus(tracked, untracked) : ''
endfunction

function! LightlineCharacterHex()
  " Don't show the character hex on windows that aren't wide.
  "
  " Vim provides a handy '%B' escape code for use in 'statusline', but it's not easy to get
  " the hex value of a character under the cursor without that.
  let hex =  printf('%X', char2nr(matchstr(getline('.'), '\%' . col('.') . 'c.')))
  return winwidth(0) > s:collapse_threshold ? hex : ''
endfunction

function! LightlineFileEncoding()
  " Don't show the file encoding on windows that aren't wide.
  return winwidth(0) > s:collapse_threshold ? &fileencoding : ''
endfunction

function! LightlineGitBranch()
  " Don't show the git branch on windows that aren't wide.
  return winwidth(0) > s:collapse_threshold ? fugitive#head() : ''
endfunction

function! LightlineFileFormat()
  " Don't show the file format on windows that aren't wide.
  return winwidth(0) > s:collapse_threshold ? &fileformat : ''
endfunction

function! LightlineFileType()
  " Don't show the file type on windows that aren't wide.
  return winwidth(0) > s:collapse_threshold ? (&filetype !=# '' ? &filetype : 'no ft') : ''
endfunction

function! LightlineReadonly()
  " Don't show any read-only indicator for writable files.
  return &readonly && &filetype !=# 'help' ? 'RO' : ''
endfunction

function! LightlineTagbar()
  " Don't show the current tag on windows that aren't wide.
  return winwidth(0) > s:collapse_threshold ? tagbar#currenttag('%s', '', 'f') : ''
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
" followed by white foreground (for Gutentags), and then by white foreground (for Obsession),
" finished off with bright black foreground (for line/col/hex/encoding, etc).
let s:p.normal.right = [
\   [s:bright_green, s:bg, s:c_bright_green, s:c_bg],
\   [s:white, s:bg, s:c_white, s:c_bg],
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
let s:p.replace.right = s:p.normal.left

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

" vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
