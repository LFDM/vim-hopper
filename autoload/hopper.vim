"""""""""""""""""""""
"  Movement hopper  "
"""""""""""""""""""""

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

function! hopper#map_movement_key(mode, key, move)
  call submode#map(a:mode, 'n', '', a:key, ':call hopper#'.a:move.'()<cr>')
endfunction

function! hopper#map_movement_enter_key(mode, key, move)
  call submode#enter_with(a:mode, 'n', 'b', g:hopper_prefix.a:key, ':call hopper#'.a:move.'()<cr>')
endfunction

function! hopper#define_movement_mode()
  let mode_name = b:hopper_movement_mode_name.'-hopper'
  call hopper#map_movement_enter_key(mode_name, 'j', 'next')
  call hopper#map_movement_enter_key(mode_name, 'k', 'prev')
  call hopper#map_movement_key(mode_name, 'j', 'next')
  call hopper#map_movement_key(mode_name, 'k', 'prev')
  call hopper#map_movement_key(mode_name, 'h', 'prev_outer')
  call hopper#map_movement_key(mode_name, 'l', 'next_inner')
  call hopper#map_movement_key(mode_name, 'J', 'next_with_same_indentation')
  call hopper#map_movement_key(mode_name, 'K', 'prev_with_same_indentation')
  call hopper#map_movement_key(mode_name, 'b', 'go_to_last_hop')
  call hopper#map_movement_key(mode_name, 'f', 'go_to_last_hop')

  if exists('g:loaded_matchit')
    call hopper#map_movement_key(mode_name, 'e', 'go_to_end')
  endif
endfunction


"""""""""""""""""""""
"  Support hoppers  "
"""""""""""""""""""""

function! hopper#load_exchange()
  if !exists('g:loaded_unimpaired')
    return
  end

  let mode = 'exchange'
  call submode#enter_with(mode, 'nx', '', g:hopper_prefix.'e', '<nop>')
  call submode#map(mode, 'n', 'r', 'j', '<Plug>unimpairedMoveDown')
  call submode#map(mode, 'n', 'r', 'k', '<Plug>unimpairedMoveUp')
  " investigate why this won't work if it's mapped to the plug
  call submode#map(mode, 'x', 'r', 'j', ']egv')
  call submode#map(mode, 'x', 'r', 'k', '[egv')
endfunction

function! hopper#load_buffer()
  let mode = 'buffer-hopper'
  let mappings = {
        \  'j' : ':bnext<cr>',
        \  'k' : ':bprev<cr>',
        \  'h' : ':bfirst<cr>',
        \  'l' : ':blast<cr>',
        \  'w' : ':w<cr>',
        \  'x' : ':w<cr>:bd<cr>',
        \  'q' : ':bd<cr>',
        \}

  if exists('g:loaded_ctrlp')
    " it probably would be helpful to enter the submode afterwards again
    " or probably not because that buffer should be where you want to go
    " anyway
    let mappings['f'] = ':CtrlPBuffer<cr>'
  endif

  call hopper#create_mode(mode, 'b', 'n', '', mappings)
endfunction

function! hopper#load_tab()
  let mode = 'tab-hopper'
  call submode#enter_with(mode, 'n', '', g:hopper_prefix.'tb', '<nop>')
  call submode#map(mode, 'n', '', 'j', ':tabnext<cr>')
  call submode#map(mode, 'n', '', 'k', ':tabprev<cr>')
  call submode#map(mode, 'n', '', 'h', ':tabfirst<cr>')
  call submode#map(mode, 'n', '', 'l', ':tablast<cr>')
  call submode#map(mode, 'n', '', 'n', ':tabnew<cr>')
  call submode#map(mode, 'n', '', 'c', ':tabclose<cr>')
endfunction

function! hopper#load_tag()
  let mode = 'tag-hopper'
  call submode#enter_with(mode, 'n', '', g:hopper_prefix.'t', '<nop>')
  call submode#map(mode, 'n', '', 'j', ':call hopper#next_tag()<cr>')
  call submode#map(mode, 'n', '', 'k', ':call hopper#prev_tag()<cr>')
  call submode#map(mode, 'n', '', 'h', ':tfirst<cr>')
  call submode#map(mode, 'n', '', 'l', ':tlast<cr>')
  call submode#map(mode, 'n', '', 'f', '<c-]>')
endfunction

function! hopper#next_tag()
  try | tnext | catch | tfirst | endtry
endfunction

function! hopper#prev_tag()
  try | tprev | catch | tlast | endtry
endfunction

function! hopper#load_gitgutter()
  if !exists('g:loaded_gitgutter')
    return
  endif

  let mode = 'gitgutter'
  call submode#enter_with(mode, 'n', '', g:hopper_prefix.'g', '<nop>')

  let gitgutter_map = {
        \ 'j' : 'Next',
        \ 'k' : 'Prev',
        \ 'a' : 'Stage',
        \ 's' : 'Stage',
        \ 'u' : 'Revert',
        \ 'r' : 'Revert',
  \}

  for [k, c] in items(gitgutter_map)
    call submode#map(mode, 'n', '', k, ':GitGutter'.c.'Hunk<cr>')
  endfor

  if exists('g:loaded_fugitive')
    call submode#map(mode, 'n', '', 'c', ':Gcommit<cr>')
  endif
endfunction

function! hopper#load_speed()
  let mode = 'speed-hooper'
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

function! hopper#load_yankring()
  if !exists('g:loaded_yankring')
    return
  endif

  let mode = 'yankring'
  call submode#enter_with(mode, 'n', '', g:hopper_prefix.'y', '<nop>')
  call submode#map(mode, 'n', '', 'j', ":<C-U>YRReplace '-1', P<cr>")
  call submode#map(mode, 'n', '', 'k', ":<C-U>YRReplace '1', p<cr>")
  call submode#map(mode, 'n', '', 's', ':YRShow<cr>')
  call submode#map(mode, 'n', '', 'f', ':YRSearch<cr>')
endfunction

function! hopper#create_mode(mode_name, enter_key, mode, opts, mappings)
  call submode#enter_with(a:mode_name, a:mode, a:opts, g:hopper_prefix.a:enter_key, '<nop>')
  call hopper#add_mappings(a:mode_name, a:mode, a:opts, a:mappings)
endfunction

function! hopper#add_mappings(mode_name, mode, opts, mappings)
  for [key, cmd] in items(a:mappings)
    call submode#map(a:mode_name, a:mode, a:opts, key, cmd)
  endfor
endfunction
