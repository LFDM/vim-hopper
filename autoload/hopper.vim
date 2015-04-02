"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                             Movement hopper                             "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! hopper#search(direction, ws)
  call hopper#save_position()
  let flags = a:direction.'W'
  call search('\v^\s'.a:ws.'\zs'.b:hopper_pattern, flags)
  call hopper#centralize()
endfunction

function! hopper#go_to_last_hop()
  if exists('b:hopper_last_hop')
    let last_pos = b:hopper_last_hop
    call hopper#save_position()
    call setpos('.', last_pos)
    call hopper#centralize()
  endif
endfunction

function! hopper#go_to_end()
  try
    call b:hop_to_special_end()
  catch
    " don't call this with !, as matchit wraps the built-in % behavior
    normal %
  endtry
endfunction

function! hopper#centralize()
  if g:hopper_center_on_jump
    normal! zz
  endif
endfunction

function! hopper#save_position()
  let b:hopper_last_hop = getpos('.')
endfunction

function! hopper#next()
  call hopper#search('', '*')
endfunction

function! hopper#prev()
  call hopper#search('b', '*')
endfunction

function! hopper#prev_outer()
  let ind = indent(line('.'))
  if ind == 0
    return
  endif
  call hopper#search('b', '{0,'.string(ind - 1).'}')
endfunction

function! hopper#next_inner()
  let ind = indent(line('.')) + 1
  call hopper#search('', '{'.ind.',}')
endfunction

function! hopper#search_with_same_indentation(direction)
  call hopper#search(a:direction, '{'.indent('.').'}')
endfunction

function! hopper#next_with_same_indentation()
  call hopper#search_with_same_indentation('')
endfunction

function! hopper#prev_with_same_indentation()
  call hopper#search_with_same_indentation('b')
endfunction

function! s:add_movement_mappings(mode, mappings)
  for [key, cmd] in items(a:mappings)
    call s:map_movement_key(a:mode, key, cmd)
  endfor
endfunction

function! s:map_movement_key(mode, key, move)
  call submode#map(a:mode, 'n', '', a:key, ':call hopper#'.a:move.'()<cr>')
endfunction

function! s:map_movement_enter_key(mode, key, move)
  call submode#enter_with(a:mode, 'n', 'b', g:hopper_prefix.a:key, ':call hopper#'.a:move.'()<cr>')
endfunction

function! s:define_movement_mode()
  let mode_name = b:hopper_movement_mode_name.'-hopper'
  let mappings = {
        \ 'j' : 'next',
        \ 'k' : 'prev',
        \ 'h' : 'prev_outer',
        \ 'l' : 'next_inner',
        \ 'J' : 'next_with_same_indentation',
        \ 'K' : 'prev_with_same_indentation',
        \ 'b' : 'go_to_last_hop',
        \ 'f' : 'go_to_last_hop',
  \}

  if exists('g:loaded_matchit')
    let mappings['e'] = 'go_to_end'
  endif

  call s:map_movement_enter_key(mode_name, 'j', 'next')
  call s:map_movement_enter_key(mode_name, 'k', 'prev')
  call s:add_movement_mappings(mode_name, mappings)
endfunction



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                             Support hoppers                             "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""
"  buffer  "
""""""""""""

function! s:load_buffer()
  let mode = 'buffer-hopper'
  let enter_key = 'b'
  let mappings = {
        \ 'j' : ':bnext<cr>',
        \ 'k' : ':bprev<cr>',
        \ 'h' : ':bfirst<cr>',
        \ 'l' : ':blast<cr>',
        \ 'w' : ':w<cr>',
        \ 'x' : ':w<cr>:bd<cr>',
        \ 'q' : ':bd<cr>',
        \ 'm' : ':call hopper#guard("bmodified", "No modified buffer present")<cr>',
        \ 's' : ':sp<cr><c-w>p:bnext<cr>',
        \ 'v' : ':vsp<cr><c-w>p:bnext<cr>',
  \}

  if exists('g:loaded_ctrlp')
    " it probably would be helpful to enter the submode afterwards again
    " or probably not because that buffer should be where you want to go
    " anyway
    let mappings['f'] = ':CtrlPBuffer<cr>'
  endif

  call hopper#create_mode(mode, 'n', '', enter_key, mappings)
endfunction


"""""""""
"  tab  "
"""""""""

function! s:load_tab()
  let mode = 'tab-hopper'
  let enter_key = 'tb'
  let mappings = {
        \  'j' : ':tabnext<cr>',
        \  'k' : ':tabprev<cr>',
        \  'h' : ':tabfirst<cr>',
        \  'l' : ':tablast<cr>',
        \  'n' : ':tabnew<cr>',
        \  'c' : ':tabclose<cr>',
  \}

  call hopper#create_mode(mode, 'n', '', enter_key, mappings)
endfunction


"""""""""
"  tag  "
"""""""""

function! s:load_tag()
  let mode = 'tag-hopper'
  let enter_key = 't'
  let mappings = {
        \  'j' : ':call hopper#cycle_next("t")<cr>',
        \  'k' : ':call hopper#cycle_prev("t")<cr>',
        \  'h' : ':tfirst<cr>',
        \  'l' : ':tlast<cr>',
        \  'f' : '<c-]>',
  \}

  call hopper#create_mode(mode, 'n', '', enter_key, mappings)
endfunction


""""""""""""""
"  quickfix  "
""""""""""""""

function! s:load_quickfix()
  let mode = 'qf-hopper'
  let enter_key = 'q'
  let mappings = {
        \  'j' : ':call hopper#guard("call hopper#cycle_next(\"c\")", "Quickfix list empty")<cr>',
        \  'k' : ':call hopper#guard("call hopper#cycle_prev(\"c\")", "Quickfix list empty")<cr>',
        \  'J' : ':call hopper#guard("cnfile", "Last file reached")<cr>',
        \  'K' : ':call hopper#guard("cpfile", "First file reached")<cr>',
        \  'h' : ':call hopper#guard("cfirst", "Quickfix list empty")<cr>)',
        \  'l' : ':call hopper#guard("clast", "Quickfix list empty")<cr>)',
        \  'o' : ':copen<cr>,',
        \  'q' : ':cclose<cr>,',
        \  '<c-j>' : ':call hopper#guard("cnewer")<cr>',
        \  '<c-k>' : ':call hopper#guard("colder")<cr>',
  \}

  call hopper#create_mode(mode, 'n', '', enter_key, mappings)
endfunction


""""""""""""""
"  location  "
""""""""""""""

function! s:load_location()
  let mode = 'loc-hopper'
  let enter_key = 'l'
  let mappings = {
        \  'j' : ':call hopper#guard("call hopper#cycle_next(\"l\")", "Location list empty")<cr>',
        \  'k' : ':call hopper#guard("call hopper#cycle_prev(\"l\")", "Location list empty")<cr>',
        \  'J' : ':call hopper#guard("lnfile", "Last file reached")<cr>',
        \  'K' : ':call hopper#guard("lpfile", "First file reached")<cr>',
        \  'h' : ':call hopper#guard("lfirst", "Location list empty")<cr>)',
        \  'l' : ':call hopper#guard("llast", "Location list empty")<cr>)',
        \  'o' : ':lopen<cr>,',
        \  'q' : ':lclose<cr>,',
        \  '<c-j>' : ':call hopper#guard("lnewer")<cr>',
        \  '<c-k>' : ':call hopper#guard("lolder")<cr>',
        \  'c' : ':call cosco#commaOrSemiColon()<cr>'.g:hopper_prefix.'l',
        \  'w' : ':w<cr>',
  \}

  call hopper#create_mode(mode, 'n', '', enter_key, mappings)
endfunction


"""""""""""""
"  windows  "
"""""""""""""

function! s:load_window()
  let mode = 'window-hopper'
  let enter_key = 'w'
  let mappings = {
        \  'j' : '<c-w>j',
        \  'k' : '<c-w>k',
        \  'h' : '<c-w>h',
        \  'l' : '<c-w>l',
        \  'r' : '<c-w>r',
        \  'R' : '<c-w>R',
        \  'x' : '<c-w>x',
        \  'J' : '<c-w>-',
        \  'K' : '<c-w>+',
        \  'H' : '<c-w>>',
        \  'L' : '<c-w><',
        \  'e' : '<c-w>=',
        \  '<c-j>' : '5<c-w>-',
        \  '<c-k>' : '5<c-w>+',
        \  '<c-h>' : '5<c-w>>',
        \  '<c-l>' : '5<c-w><-',
        \}
  " rotate needs to be catched
  " needs more thinking

  call hopper#create_mode(mode, 'n', '', enter_key, mappings)
endfunction


""""""""""""""
"  exchange  "
""""""""""""""

function! s:load_exchange()
  if !exists('g:loaded_unimpaired')
    return
  end

  let mode = 'exchange'
  call submode#enter_with(mode, 'nx', '', g:hopper_prefix.'e')
  call submode#map(mode, 'n', 'r', 'j', '<Plug>unimpairedMoveDown')
  call submode#map(mode, 'n', 'r', 'k', '<Plug>unimpairedMoveUp')
  " investigate why this won't work if it's mapped to the plug
  call submode#map(mode, 'x', 'r', 'j', ']egv')
  call submode#map(mode, 'x', 'r', 'k', '[egv')
endfunction


"""""""""""""""
"  gitgutter  "
"""""""""""""""

function! s:load_gitgutter()
  if !exists('g:loaded_gitgutter')
    return
  endif

  let mode = 'gutter-hopper'
  let enter_key = 'g'
  let mappings = {
        \ 'j' : 'Next',
        \ 'k' : 'Prev',
        \ 'a' : 'Stage',
        \ 's' : 'Stage',
        \ 'u' : 'Revert',
        \ 'r' : 'Revert',
  \}

  for [k, c] in items(mappings)
    let mappings[k] = ':GitGutter'.c.'Hunk<cr>'
  endfor

  if exists('g:loaded_fugitive')
    let mappings['c'] = ':Gcommit<cr>'
  endif

  call hopper#create_mode(mode, 'n', '', enter_key, mappings)
endfunction


"""""""""""
"  speed  "
"""""""""""

function! s:load_speed()
  let mode = 'speed-hopper'
  let enter_key = 's'
  let mappings = {
        \ 'j' : '5j',
        \ 'k' : '5k',
        \ 'J' : '10j',
        \ 'K' : '10k',
        \ 'h' : '5h',
        \ 'l' : '5l',
        \ 'H' : '10h',
        \ 'L' : '10l',
  \}

  call hopper#create_mode(mode, 'nx', '', enter_key, mappings)
endfunction


""""""""""""""""""""""
"  CtrlP"            "
""""""""""""""""""""""

function! s:load_ctrlp_custom_modes()
  if !exists('g:loaded_ctrlp')
    return
  endif

  let mode = 'ctrlp'
  let enter_key = 'p'
  let mappings = {}

  let modes = {
        \ 'b': 'Buffer',
        \ 'm': 'MRU',
        \ 'r': 'RelFiles',
        \ 'i': 'Line',
  \}

  for [key, m] in items(modes)
    let mappings[key] = ':CtrlP'.m.'<cr>'
  endfor

  if exists('g:loaded_ctrlp_custom_modes')
    let cmds = ['j', 'f', 'k', 'd', 'l', 's', "'", 'a', 'h', 'g']
    let i = 0
    for cmd in cmds
      let mappings[cmd] = ':CtrlPCustomMode'.i.'<cr>'
      let i += 1
    endfor
  endif

  call hopper#create_mode(mode, 'n', '', enter_key, mappings)
endfunction


""""""""""""""""""""
"  merge-conflict  "
""""""""""""""""""""

function! s:load_merge_conflict()
  let mode = "merge"
  let enter_key = 'm'
  let mappings = {
        \  'j' : ':call search("\(<<<<\|>>>>\)")<cr>',
        \  'k' : ':call search("\(<<<<\|>>>>\)", "b")<cr>',
   \}


  call hopper#create_mode(mode, 'n', '', enter_key, mappings)
endfunction


""""""""""""""
"  yankring  "
""""""""""""""

function! s:load_yankring()
  if !exists('g:loaded_yankring')
    return
  endif

  let mode = 'yankring'
  let enter_key = 'y'
  let mappings = {
        \  'j' : ":<C-U>YRReplace '-1', P<cr>",
        \  'k' : ":<C-U>YRReplace '1', p<cr>",
        \  's' : ':YRShow<cr>',
        \  'f' : ':YRSearch<cr>',
  \}

  call hopper#create_mode(mode, 'n', '', enter_key, mappings)
endfunction


"""""""""""""""""
"  file-opener  "
"""""""""""""""""

" This is rather specific for now, but fits the author's purpose

function! s:load_file_opener()
  let mode = 'file-o'
  let enter_key = 'o'
  let mappings = {
        \ 'j' : ":call hopper#open_file(0)<cr>",
        \ 'k' : ":call hopper#open_file(1)<cr>",
        \ 'l' : ":call hopper#open_file(2)<cr>",
        \ ';' : ":call hopper#open_file(3)<cr>",
        \ 'a' : ":call hopper#open_file(4)<cr>",
        \ 's' : ":call hopper#open_file(5)<cr>",
        \ 'd' : ":call hopper#open_file(6)<cr>",
        \ 'f' : ":call hopper#open_file(7)<cr>",
        \ 'g' : ":call hopper#open_file(8)<cr>"
  \}

  call hopper#create_mode(mode, 'n', '', enter_key, mappings)
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                            helper functions                             "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! hopper#create_mode(mode_name, mode, opts, enter_key, mappings)
  call submode#enter_with(a:mode_name, a:mode, a:opts, g:hopper_prefix.a:enter_key)
  call hopper#add_mappings(a:mode_name, a:mode, a:opts, a:mappings)
endfunction

function! hopper#add_mappings(mode_name, mode, opts, mappings)
  for [key, cmd] in items(a:mappings)
    call submode#map(a:mode_name, a:mode, a:opts, key, cmd)
  endfor
endfunction

function! hopper#cycle_next(cmd)
  try | exec a:cmd.'next' | catch | exec a:cmd.'first' | endtry
endfunction

function! hopper#cycle_prev(cmd)
  try | exec a:cmd.'prev' | catch | exec a:cmd.'last' | endtry
endfunction

function! hopper#guard(cmd, ...)
  try
    exec a:cmd
  catch
    let message = a:0 == 0 ? '' : a:1
    echo message
  endtry
endfunction

function! hopper#open_file(no)
  let length = len(g:hopper_file_opener) - 1
  if a:no > length | return | endif

  let info = g:hopper_file_opener[a:no]
  let file = expand('%:p')
  let matcher = info[0]
  let files = info[1]
  if file !~ matcher | return | endif

  " Calculate files we have access to
  let windows = []
  for hor in files
    let res = []
    for vert in hor
      if vert[0] == 'source'
        call add(res, file)
      else
        let f = substitute(file, vert[0], vert[1], '')
        if file != f
          call add(res, f)
        end
      endif
    endfor
    if len(res) > 0
      call add(windows, res)
    endif
  endfor

  " Create all splits and open file
  let hor_i = 0
  for hor_splits in windows
    let vert_i = 0
    for vert_split in hor_splits
      echo vert_split
      if hor_i == 0 && vert_i == 0
        exec "e ". vert_split
      else
        exec "normal! \<C-W>" . vert_i . "l"
        exec "vsp" . vert_split
        exec "normal! \<C-W>" . vert_i . "h"
      endif
      let vert_i += 1
    endfor

    let hor_i += 1
  endfor

  " Move to top left window
  exec "normal! \<C-W>t"
endfunction


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                            public functions                             "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

function! hopper#load_movement_mode()
  let filetypes = split(&ft, '\.')
  for ft in filetypes
    if index(g:hopper_filetype_modes, ft) > -1
      call b:load_hopper_by_filetype()
      call s:define_movement_mode()
      break
    endif
  endfor
endfunction

function! hopper#load_support_modes()
  for support_mode in g:hopper_support_modes
    exec 'call s:load_'.support_mode.'()'
  endfor
endfunction
