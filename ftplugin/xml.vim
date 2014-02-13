function! b:load_hopper_by_filetype()
  let b:hopper_pattern = '\<(/|!)@!'
  let b:hopper_movement_mode_name = 'xml'
endfunction

function! b:hop_to_special_end()
  " when matchit is on < it will jump to >,
  " when it's on the first char of the tag itself,
  " it goes to the end
  if '<' == getline('.')[col('.') - 1]
    normal! l
  endif
  normal %
endfunction
