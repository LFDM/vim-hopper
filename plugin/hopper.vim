if exists('g:loaded_hopper') || &cp
  finish
endif

if !exists('g:hopper_prefix')
  finish
endif

if !exists('g:hopper_filetype_modes')
  let g:hopper_filetype_modes = [
        \'bash', 'coffee', 'javascript', 'markdown', 'python', 'ruby',
        \'snippets', 'sh', 'vim', 'xml', 'zsh'
        \]
endif

if !exists('g:hopper_support_modes')
  let g:hopper_support_modes = [
        \'buffer', 'exchange', 'gitgutter', 'location', 'quickfix',
        \'speed', 'tab', 'tag', 'yankring', 'window', 'ctrlp_custom_modes'
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

augroup hopper
  au Filetype * call hopper#load_movement_mode()
augroup END

call hopper#load_support_modes()
let g:loaded_hopper = 1

