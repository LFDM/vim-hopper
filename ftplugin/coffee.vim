function! b:load_hopper_by_filetype()
  let file_name = expand('%')
  if file_name =~ 'spec.coffee$'
    let b:hopper_pattern = '(describe|it|fit|xit|fdescribe)'
    let b:hopper_movement_mode_name = 'jasm'
  endif
endfunction


