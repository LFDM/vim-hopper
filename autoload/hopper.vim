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
  call submode#enter_with(mode, 'n', '', g:hopper_prefix.'b', '<nop>')
  call submode#map(mode, 'n', '', 'j', ':bnext<cr>')
  call submode#map(mode, 'n', '', 'k', ':bprev<cr>')
  call submode#map(mode, 'n', '', 'w', ':w<cr>')
  call submode#map(mode, 'n', '', 'x', ':w<cr>:bd<cr>')
  call submode#map(mode, 'n', '', 'q', ':bd<cr>')
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
  let mode = 'speedjumping'
  call submode#enter_with(mode, 'nx', '', g:hopper_prefix.'s', '<nop>')
  call submode#map(mode, 'nx', '', 'j', '5j')
  call submode#map(mode, 'nx', '', 'k', '5k')
  call submode#map(mode, 'nx', '', 'J', '10j')
  call submode#map(mode, 'nx', '', 'K', '10k')
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
