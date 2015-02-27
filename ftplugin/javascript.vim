function! b:load_hopper_by_filetype()
  let file_name = expand('%')
  if file_name =~ 'spec.js$'
    let b:hopper_pattern = '(describe|it|fit|xit|fdescribe)'
    let b:hopper_movement_mode_name = 'jasm'
  else
    let b:hopper_pattern = '(\s*|\= )function'
    let b:hopper_movement_mode_name = 'js'
  endif
endfunction

function! b:hop_to_special_end()
  normal! f{
  normal %
endfunction



