if exists('g:loaded_hopper') || &cp || !exists('g:hopper_prefix')
  finish
endif

let s:defaults = {
        \'hopper_filetype_modes':  [
        \  'bash', 'coffee', 'javascript', 'markdown', 'python', 'ruby',
        \  'snippets', 'sh', 'vim', 'xml', 'zsh'
        \],
        \'hopper_support_modes': [
        \  'buffer', 'exchange', 'file_opener',  'gitgutter', 'location',
        \  'merge_conflict', 'quickfix', 'speed', 'tab', 'tag', 'yankring',
        \  'window', 'ctrlp_custom_modes'
        \],
        \'hopper_file_opener': [],
        \'hopper_center_on_jump': 1,
        \'submode_timeoutlen': 10000,
        \'submode_keep_leaving_key': 1
\}

for def in items(s:defaults)
  if !exists('g:' . def[0])
    let g:{def[0]} = def[1]
  endif
endfor

augroup hopper
  au Filetype * call hopper#load_movement_mode()
augroup END


call hopper#load_support_modes()
let g:loaded_hopper = 1
