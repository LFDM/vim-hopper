function! hopper#search(direction)
  call search('\v^(\s*\zs)'.b:hopper_pattern, a:direction)
endfunction

function! hopper#next()
  call hopper#search('')
endfunction

function! hopper#prev()
  call hopper#search('b')
endfunction

function! hopper#load_ruby()
  let file_name = expand('%')
  if file_name =~ 'spec.rb$'
    let b:hopper_pattern = '(describe|context|it) .* (do|\{)'
    call hopper#define_movement_mode('rspec')
  else
    let b:hopper_pattern = '(def|class|module)'
    call hopper#define_movement_mode('ruby')
  endif
endfunction

let g:hopper_prefix = '<esc>'

function! hopper#define_movement_mode(name)
  let mode_name = a:name.'-hopper'
  call submode#enter_with(mode_name, 'n', '', g:hopper_prefix.'j', ':call hopper#next()<cr>' )
  call submode#enter_with(mode_name, 'n', '', g:hopper_prefix.'k', ':call hopper#prev()<cr>')
  call submode#map(mode_name, 'n', '', 'j', ':call hopper#next()<cr>')
  call submode#map(mode_name, 'n', '', 'k', ':call hopper#prev()<cr>')
endfunction

au Filetype ruby call hopper#load_ruby()
