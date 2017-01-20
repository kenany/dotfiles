let s:plugins = [
  \ ['dein.vim'],
  \ ['base16-vim'],
  \ ['ctrlp.vim'],
  \ ['deoplete.nvim', {'on_i': 1}],
  \ ['deoplete-ternjs'],
  \ ['neoinclude.vim', {'on_i': 1}],
  \ ['vim-airline'],
  \ ['vim-easymotion', {'on_map': '<Plug>(easymotion-prefix)'}],
  \ ['vim-javascript', {'on_ft': ['javascript']}],
  \ ['vim-jsx'],
  \ ]

set runtimepath+=~/.config/nvim/bundle/dein.vim

if dein#load_state(expand('~/.cache/dein'))
  call dein#begin(expand('~/.cache/dein'))

  for plugin in s:plugins
    if len(plugin) == 2
      call dein#add(expand('~/.config/nvim/bundle/' . plugin[0]), plugin[1])
    else
      call dein#add(expand('~/.config/nvim/bundle/' . plugin[0]))
    endif
  endfor

  call dein#end()
  call dein#save_state()
endif

filetype plugin indent on
syntax enable

if dein#check_install()
  call dein#install()
endif

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

" Use ripgrep since it's so fast
set grepprg=rg\ --vimgrep\ --no-heading
set grepformat=%f:%l:%c:%m,%f:%l:%m

" Double leader to activate easymotion
map <Leader><Leader> <Plug>(easymotion-prefix)

" trim trailing spaces
nnoremap <silent> <F5> :let _s=@/<Bar>:%s/\s\+$//e<Bar>:let @/=_s<Bar>:nohl<CR>

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

" Use ripgrep in CtrlP for listing files since it is fast at doing it
let g:ctrlp_user_command = 'rg --files --hidden %s'

" ripgrep is fast enough that CtrlP doesn't need to cache
let g:ctrlp_use_caching = 0

" Specify paths to python executables to save neovim the trouble of searching
" for them (use `:CheckHealth` to verify)
let g:python2_host_prog = '/usr/bin/python2'
let g:python3_host_prog = '/usr/bin/python3'

" Enable deoplete
let g:deoplete#enable_at_startup = 1

let g:deoplete#sources={}
let g:deoplete#sources._    = ['buffer', 'file']
let g:deoplete#sources.vim  = ['buffer', 'member', 'file']
let g:deoplete#sources['javascript.jsx'] = ['buffer', 'file', 'ternjs']
let g:deoplete#sources.css  = ['buffer', 'member', 'file', 'omni']
let g:deoplete#sources.html = ['buffer', 'member', 'file', 'omni']

" Be case-sensitive when an uppercase character is used.
let g:deoplete#enable_camel_case = 1

let g:tern_show_signature_in_pum = 1
let g:deoplete#sources#ternjs#tern_bin = 'tern'

let g:jsx_ext_required = 0

let g:base16_shell_path = '~/.config/base16-shell/scripts'
set background=dark
let base16colorspace=256
colorscheme base16-brewer
