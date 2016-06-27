runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()

set number
set ruler
set hidden
set nowrap
set ignorecase
set smartcase
set notimeout
set magic

set backupdir=~/.cache/.backup
set directory=~/.cache/.backup

set grepprg=ag\ --nogroup\ --nocolor

let g:airline_left_sep = '▶'
let g:airline_right_sep = '◀'
let g:airline_linecolumn_prefix = '␊ '
let g:airline_linecolumn_prefix = '␤ '
let g:airline_linecolumn_prefix = '¶ '
let g:airline#extensions#branch#symbol = '⎇ '
let g:airline#extensions#paste#symbol = 'ρ'
let g:airline#extensions#paste#symbol = 'Þ'
let g:airline#extensions#paste#symbol = '∥'
let g:airline#extensions#whitespace#symbol = 'Ξ'

set expandtab
set shiftwidth=2
set softtabstop=2

set textwidth=80
set colorcolumn=+1

" Use ag in CtrlP for listing files
let g:ctrlp_user_command = 'ag -Q -l --nocolor --hidden -g "" %s'

" ag is fast enough that CtrlP doesn't need to cache
let g:ctrlp_use_caching = 0

