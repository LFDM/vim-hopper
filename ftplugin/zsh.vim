function! b:load_hopper_by_filetype()
  let b:hopper_pattern = '(function .*|\w+\s?(\(\))? )(\{\s*|\{.*\}\s*)$'
  let b:hopper_movement_mode_name = 'zsh'
endfunction
