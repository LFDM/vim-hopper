function! hopper#search(direction)
  call search(b:hopper_pattern, a:direction)
  normal! ^
endfunction

function! hopper#next()
  call hopper#search('')
endfunction

function! hopper#prev()
  call hopper#search('b')
endfunction

function! hopper#load_ruby()
  let b:hopper_pattern = '\v^\s*(def|class|module)'
  call hopper#defineMode('ruby')
endfunction

let g:hopper_prefix = '<esc>'

function! hopper#defineMode(name)
  let mode_name = a:name.'hopper'
  call submode#enter_with(mode_name, 'n', '', g:hopper_prefix.'j', ':call hopper#next()<cr>' )
  call submode#enter_with(mode_name, 'n', '', g:hopper_prefix.'k', ':call hopper#prev()<cr>')
  call submode#map(mode_name, 'n', '', 'j', ':call hopper#next()<cr>')
  call submode#map(mode_name, 'n', '', 'k', ':call hopper#prev()<cr>')
endfunction

au Filetype ruby call hopper#load_ruby()
