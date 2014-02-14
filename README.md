# vim-hopper

Simplistic vim plugin to keep repetitive movement motions centralized on
the home row.


#### Concept

Space on the keyboard is valuable, there is only a limited amount of
keys available for custom mappings. Particulary movement commands tend
to be called more than once in a row - when such a command is triggered
by two-or-more-key combo it quickly gets cumbersome.

vim-hopper temporarily enpowers your home-row keys with more complex
commands to allow you to move around more efficiently.

This is done through submodes, provided by the vim-submode plugin, which
you have to install in order to get vim-hopper running. (check `:h
submode` for more information)

All submodes are triggered through the combination of the
`hopper_prefix` and one additional key.
The prefix defaults to `<esc>` (for those who have remapped their
`caps-lock` key probably a good choice) and can be customized through the variable `g:hopper_prefix`

#### Filetype specific hopper

TODO

#### Support hoppers

Most of these hoppers are wrappers around other plugins - they are only
initiated when the respective plugin is installed.

TODO


#### TODO

- Enable visual mode for the movement hoppers
