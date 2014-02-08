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
    call b:hopper_go_to_special_end
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

function! hopper#define_movement_mode()
  let mode_name = b:hopper_movement_mode_name.'-hopper'
  call submode#enter_with(mode_name, 'n', '', g:hopper_prefix.'j', ':call hopper#next()<cr>' )
  call submode#enter_with(mode_name, 'n', '', g:hopper_prefix.'k', ':call hopper#prev()<cr>')
  call submode#map(mode_name, 'n', '', 'j', ':call hopper#next()<cr>')
  call submode#map(mode_name, 'n', '', 'k', ':call hopper#prev()<cr>')
  call submode#map(mode_name, 'n', '', 'h', ':call hopper#prev_outer()<cr>')
  call submode#map(mode_name, 'n', '', 'l', ':call hopper#next_inner()<cr>')
  call submode#map(mode_name, 'n', '', 'J', ':call hopper#next_with_same_indentation()<cr>')
  call submode#map(mode_name, 'n', '', 'K', ':call hopper#prev_with_same_indentation()<cr>')
  call submode#map(mode_name, 'n', '', 'b', ':call hopper#go_to_last_hop()<cr>')
  call submode#map(mode_name, 'n', '', 'f', ':call hopper#go_to_last_hop()<cr>')

  if g:loaded_matchit
    call submode#map(mode_name, 'n', '', 'e', ':call hopper#go_to_end()<cr>')
  endif
endfunction

function! hopper#load_gitgutter()
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
  call submode#enter_with(mode, 'nv', '', g:hopper_prefix.'s', '<nop>')
  call submode#map(mode, 'nv', '', 'j', '5j')
  call submode#map(mode, 'nv', '', 'k', '5k')
  call submode#map(mode, 'nv', '', 'J', '10j')
  call submode#map(mode, 'nv', '', 'K', '10k')
endfunction
