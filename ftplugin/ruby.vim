function! b:load_hopper_by_filetype()
  let file_name = expand('%')
  if file_name =~ 'spec.rb$'
    let b:hopper_pattern = '(describe|context|it|xit) '
    let b:hopper_movement_mode_name = 'rspec'
  elseif file_name == 'Rakefile' || file_name =~ '.rake$'
    let b:hopper_pattern = '(def|class|module|task|namespace) '
    let b:hopper_movement_mode_name = 'rake'
  else
    let b:hopper_pattern = '(def|class|module|task) '
    let b:hopper_movement_mode_name = 'ruby'
  endif
endfunction

