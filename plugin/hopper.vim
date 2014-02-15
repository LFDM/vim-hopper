if exists('g:loaded_hopper') || &cp
  finish
endif

if !exists('g:hopper_prefix')
  let g:hopper_prefix = '<esc>'
endif

if !exists('g:hopper_filetype_modes')
  let g:hopper_filetype_modes = [
        \'bash', 'markdown', 'python', 'ruby', 'snippets',
        \'sh', 'vim', 'xml', 'zsh'
        \]
endif

if !exists('g:hopper_support_modes')
  let g:hopper_support_modes = [
        \'buffer', 'exchange', 'gitgutter', 'location', 'quickfix',
        \'speed', 'tab', 'tag', 'yankring'
        \]
endif

if !exists('g:hopper_center_on_jump')
  let g:hopper_center_on_jump = 1
endif

if !exists('g:submode_timeoutlen')
  let g:submode_timeoutlen = 100000
endif

if !exists('g:submode_keep_leaving_key')
  let g:submode_keep_leaving_key = 1
endif

function! hopper#load_movement_mode()
  let filetypes = split(&ft, '\.')
  for ft in filetypes
    if index(g:hopper_filetype_modes, ft) > -1
      call b:load_hopper_by_filetype()
      call hopper#define_movement_mode()
      break
    endif
  endfor
endfunction

function! hopper#load_support_modes()
  for support_mode in g:hopper_support_modes
    exec 'call hopper#load_'.support_mode.'()'
  endfor
endfunction

au Filetype * call hopper#load_movement_mode()
call hopper#load_support_modes()

let g:loaded_hopper = 1

