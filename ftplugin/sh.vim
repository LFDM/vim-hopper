function! b:load_hopper_by_filetype()
  let b:hopper_pattern = '\w+\s?\(\)\s*(\{\s*|\{.*\}\s*)$'
  let b:hopper_movement_mode_name = 'sh'
endfunction
