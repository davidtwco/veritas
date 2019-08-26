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

" Bind quick shortcuts for sideways.
nnoremap <C-,> :SidewaysJumpLeft<CR>
nnoremap <C-.> :SidewaysJumpRight<CR>

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
nmap <C-@> <plug>(ale_previous_wrap)

" vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:nowrap
