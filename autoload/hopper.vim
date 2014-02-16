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

function! hopper#add_movement_mappings(mode, mappings)
  for [key, cmd] in items(a:mappings)
    call hopper#map_movement_key(a:mode, key, cmd)
  endfor
endfunction

function! hopper#map_movement_key(mode, key, move)
  call submode#map(a:mode, 'n', '', a:key, ':call hopper#'.a:move.'()<cr>')
endfunction

function! hopper#map_movement_enter_key(mode, key, move)
  call submode#enter_with(a:mode, 'n', 'b', g:hopper_prefix.a:key, ':call hopper#'.a:move.'()<cr>')
endfunction

function! hopper#define_movement_mode()
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

  call hopper#map_movement_enter_key(mode_name, 'j', 'next')
  call hopper#map_movement_enter_key(mode_name, 'k', 'prev')
  call hopper#add_movement_mappings(mode_name, mappings)
endfunction



"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                             Support hoppers                             "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""
"  buffer  "
""""""""""""

function! hopper#load_buffer()
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

function! hopper#load_tab()
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

function! hopper#load_tag()
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

function! hopper#load_quickfix()
  let mode = 'qf-hopper'
  let enter_key = 'q'
  let mappings = {
        \  'j' : ':call hopper#cycle_next("c")<cr>',
        \  'k' : ':call hopper#cycle_prev("c")<cr>',
        \  'J' : ':call hopper#guard("cnfile", "Last file reached")<cr>',
        \  'K' : ':call hopper#guard("cpfile", "First file reached")<cr>',
        \  'h' : ':cfirst<cr>',
        \  'l' : ':clast<cr>',
        \  '<c-j>' : ':call hopper#guard("cnewer")<cr>',
        \  '<c-k>' : ':call hopper#guard("colder")<cr>',
  \}

  call hopper#create_mode(mode, 'n', '', enter_key, mappings)
endfunction


""""""""""""""
"  location  "
""""""""""""""

function! hopper#load_location()
  let mode = 'loc-hopper'
  let enter_key = 'l'
  let mappings = {
        \  'j' : ':call hopper#cycle_next("l")<cr>',
        \  'k' : ':call hopper#cycle_prev("l")<cr>',
        \  'J' : ':call hopper#guard("lnfile", "Last file reached")<cr>',
        \  'K' : ':call hopper#guard("lpfile", "First file reached")<cr>',
        \  'h' : ':lfirst<cr>',
        \  'l' : ':llast<cr>',
        \  '<c-j>' : ':call hopper#guard("lnewer")<cr>',
        \  '<c-k>' : ':call hopper#guard("lolder")<cr>',
  \}

  call hopper#create_mode(mode, 'n', '', enter_key, mappings)
endfunction


"""""""""""""
"  windows  "
"""""""""""""

function! hopper#load_window()
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

function! hopper#load_exchange()
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

function! hopper#load_gitgutter()
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

function! hopper#load_speed()
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


""""""""""""""
"  yankring  "
""""""""""""""

function! hopper#load_yankring()
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
