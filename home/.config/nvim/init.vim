runtime bundle/vim-pathogen/autoload/pathogen.vim
call pathogen#infect()

" Display line numbers
set number

" Show line and column numbers for cursor's position
set ruler

" Do not wrap long lines
set nowrap

" Lowercase searches will be case-insensitive but searches containing an
" uppercase character will be case-sensitive
set ignorecase
set smartcase

set backupdir=~/.cache/.backup
set directory=~/.cache/.backup

" Use `ag` instead of `grep` since it is much faster
set grepprg=ag\ --nogroup\ --nocolor

" Configure airline 
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

" Use `ag` in CtrlP for listing files since it is fast at doing it
let g:ctrlp_user_command = 'ag -Q -l --nocolor --hidden -g "" %s'

" `ag` is fast enough that CtrlP doesn't need to cache
let g:ctrlp_use_caching = 0

" Specify paths to python executables to save neovim the trouble of searching
" for them (use `:CheckHealth` to verify)
let g:python2_host_prog = '/usr/bin/python2'
let g:python3_host_prog = '/usr/bin/python3'

" Enable deoplete
let g:deoplete#enable_at_startup = 1

" Be case-sensitive when an uppercase character is used.
let g:deoplete#enable_camel_case = 1

autocmd FileType javascript setlocal omnifunc=tern#Complete

let g:tern_show_signature_in_pum = 1
let g:deoplete#sources#ternjs#tern_bin = 'tern'

let g:base16_shell_path = '~/.config/base16-shell/scripts'
set background=dark
let base16colorspace=256
colorscheme base16-brewer
