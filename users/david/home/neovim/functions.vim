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
    execute "let output = system('" . substitute(a:cmd, '^!', '', '') . "')"
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

function! EchoSwapMessage(message)
  if has('autocmd')
    augroup EchoSwapMessage
      autocmd!
      " Echo the message after entering a file, useful for when
      " we're entering a file (like on SwapExists) and our echo will be
      " eaten.
      autocmd BufWinEnter * echohl WarningMsg
      exec 'autocmd BufWinEnter * echon "\r'.printf('%-60s', a:message).'"'
      autocmd BufWinEnter * echohl NONE

      " Remove these auto commands so that they don't run on entering
      " the next buffer.
      autocmd BufWinEnter * augroup EchoSwapMessage
      autocmd BufWinEnter * autocmd!
      autocmd BufWinEnter * augroup END
    augroup END
  endif
endfunction

function! HandleSwap(filename)
  " If the swap file is old, delete. If it is new, recover.
  if getftime(v:swapname) < getftime(a:filename)
    let v:swapchoice = 'e'
    call EchoSwapMessage('Deleted older swapfile.')
  else
    let v:swapchoice = 'r'
    call EchoSwapMessage('Detected newer swapfile, recovering.')
  endif
endfunc

" vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
