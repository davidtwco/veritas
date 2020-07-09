let s:is_win = has('win32') || has('win64')

let s:default_action = { 'ctrl-t': 'tab split', 'ctrl-x': 'split', 'ctrl-v': 'vsplit', }
let s:action = get(g:, 'fzf_action', s:default_action)

let s:options = extend(deepcopy(get(g:, 'fzf_options', [])), [
      \ '--expect=' . join(keys(s:action), ','),
      \ '--ansi',
      \ '--prompt', 'Zettelkasten> ',
      \ '--multi'
      \ ])

let s:opts =  {
      \ 'options': s:options,
      \ 'placeholder': get(g:, 'veritas_neuron_directory') . '/' . '{1}',
      \ 'down': '25%',
      \ }

func! s:veritas_path_escape(path)
  let path = fnameescape(a:path)
  return s:is_win ? escape(path, '$') : path
endf

func! s:veritas_neuron_source()
  call veritas#neuron#refresh_cache()
  let l:zettel_cache = get(g:, 'veritas_neuron_cache', {})

  let l:final = []
  for i in keys(l:zettel_cache)
    call add(l:final, l:zettel_cache[i]['zettelPath'] . ': ' . l:zettel_cache[i]['zettelTitle'])
  endfor
  return l:final
endf

func! s:veritas_neuron_sink(lines)
  if len(a:lines) < 2
    return
  endif

  let l:cmd = get(s:action, a:lines[0], 'e')

  let l:parts = matchlist(a:lines[1], '\(.\{-}\): \(.*\)')
  let l:path = &autochdir ? fnamemodify(l:parts[1], ':p') : l:parts[1]

  try
    " Don't edit the open the file if it is the currently open file.
    if stridx('edit', l:cmd) == 0 && fnamemodify(l:path, ':p') ==# expand('%:p')
      return
    endif

    " Execute the command (`edit`, `vsplit`, etc.) with the path.
    execute l:cmd s:veritas_path_escape(l:path)
    normal! zz
  catch
  endtry
endf

func! s:veritas_neuron_reducer(lines)
  call veritas#neuron#refresh_cache()
  let l:zettel_cache = get(g:, 'veritas_neuron_cache', {})

  for zettel_id in keys(l:zettel_cache)
    let l:matched = matchstr(a:lines[0], zettel_id)
    if !empty(l:matched)
      " Return the zettel in the format of Neuron's links.
      return util#format_zettelid(l:matched)
    endif
  endfor

  throw 'Could not find selected Zettel'
endf

func! s:veritas_neuron_run(cmd)
  let l:neuron_path = get(g:, 'veritas_neuron_path', 'neuron')
  let l:zettelkasten_dir = shellescape(get(g:, 'veritas_neuron_directory'))
  return system(l:neuron_path . ' -d ' . l:zettelkasten_dir . ' ' . a:cmd)
endf

func! veritas#neuron#refresh_cache()
  let l:neuron_output = s:veritas_neuron_run("query --uri 'z:zettels'")

  let l:jq_path = get(g:, 'veritas_jq_path', 'jq')
  let l:jq_output = system(l:jq_path
        \ . " 'reduce .result[] as $i ({}; .[$i.zettelID]=$i)'",
        \ l:neuron_output)

  let g:veritas_neuron_cache = json_decode(jq_output)
endf

func! veritas#neuron#edit_zettel()
  let l:opts = extend(s:opts, {
        \ 'sink*': function('s:veritas_neuron_sink'),
        \ 'source': s:veritas_neuron_source(),
        \ })
  call fzf#run(fzf#wrap(fzf#vim#with_preview(l:opts)))
endf

func! veritas#neuron#insert_zettel()
  let l:opts = extend(s:opts, {
        \ 'reducer': function('s:veritas_neuron_reducer'),
        \ 'source': s:veritas_neuron_source(),
        \ })
  return fzf#vim#complete(fzf#wrap(fzf#vim#with_preview(l:opts)))
endf

func! veritas#neuron#new_zettel()
  exec 'tabnew '
        \ . s:veritas_neuron_run(' new "New Zettel"')
        \ . ' | call search("New Zettel") | norm"_D'
  startinsert!
  call veritas#neuron#refresh_cache()
endf

" vim:foldmethod=marker:foldlevel=0:ts=2:sts=2:sw=2:et:nowrap
