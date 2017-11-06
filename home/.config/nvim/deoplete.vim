let g:deoplete#enable_at_startup = 1

let g:deoplete#ignore_sources = get(g:, 'deoplete#ignore_sources', {})
let g:deoplete#omni#input_patterns = get(g:, 'deoplete#omni#input_patterns', {})
let g:deoplete#omni_patterns = get(g:, 'deoplete#omni_patterns', {})

let g:deoplete#sources#ternjs#timeout = 3
let g:deoplete#sources#ternjs#types = 1
let g:deoplete#sources#ternjs#docs = 1

call deoplete#custom#source('_', 'min_pattern_length', 2)

let g:deoplete#sources = {}
let g:deoplete#omni#input_patterns.javascript = ''
call deoplete#custom#set('ternjs', 'mark', 'tern')
call deoplete#custom#set('ternjs', 'rank', 9999)

let g:deoplete#omni_patterns.lua = '.'

call deoplete#custom#set('clang2', 'mark', '')
let g:deoplete#ignore_sources.c = ['omni']

let g:deoplete#ignore_sources.rust = ['omni']
call deoplete#custom#set('racer', 'mark', '')

call deoplete#custom#set('_', 'matchers', ['matcher_full_fuzzy'])
let g:deoplete#ignore_sources._ = ['around']
