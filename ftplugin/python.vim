function! b:load_hopper_by_filetype()
  let b:hopper_pattern = '(def|class) .*:'
  let b:hopper_movement_mode_name = 'python'
endfunction
