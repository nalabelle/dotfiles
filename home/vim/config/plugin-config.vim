" ALE
let g:ale_completion_enabled = 1
let g:ale_completion_tsserver_remove_warnings = 1

" ALE custom fixers
function! Retab(buffer) abort
  retab
endfunction

function! AutoIndent(buffer) abort
  " Mark cursor, then go to the middle, format, then unwind the cursor stack
  exe 'normal! mc;M;mm;gg=G;`m;`c'
endfunction

call ale#fix#registry#Add('retab', 'Retab', [], 'Retabs as per vim settings')
call ale#fix#registry#Add('auto_indent', 'AutoIndent', [], 'vim auto-indent, gg=G')

let g:ale_fixers = {'*': ['retab', 'remove_trailing_lines', 'trim_whitespace']}
let g:ale_fix_on_save = 0
let g:ale_set_balloons = 1
map <Leader>af :ALEFix<CR>
map <Leader>e :ALENextWrap<CR>
set omnifunc=ale#completion#OmniFunc

" FZF
let g:fzf_buffers_jump = 1
let g:fzf_command_prefix = 'Fzf'
nnoremap f :FzfBLines<cr>
nnoremap <C-b> :FzfBuffers<cr>
nnoremap <S-f> :FzfFiles<cr>
nnoremap <C-f> :FzfGFiles<cr>

" Vista
let g:vista#renderer#enable_icon = 1
nnoremap <Leader>v :Vista!!<CR>

" Vim Maximizer
nnoremap <C-W>z :MaximizerToggle<CR>

" Indent Guides
let g:indent_guides_enable_on_vim_startup = 1

" Airline
let g:airline#extensions#tabline#enabled = 1
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
let g:airline#extensions#tabline#buffers_label = ''
let g:airline#extensions#tabline#buffer_nr_show = 1
let g:airline#extensions#tabline#buffer_nr_format = '%s:'
let g:airline_theme='bubblegum'
let g:airline_skip_empty_sections = 1
let g:airline_highlighting_cache = 1
let g:airline_mode_map = {
    \ 'c'      : 'C',
    \ 'i'      : 'I',
    \ 'n'      : 'N',
    \ 'v'      : 'V',
    \ }
if !exists('g:airline_symbols')
  let g:airline_symbols = {}
endif
let g:airline_symbols.linenr = '☰ '
let g:airline_symbols.colnr = '||'
let g:airline_symbols.maxlinenr = ''
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = 'RO'

" Color scheme
colorscheme xoria256
set background=dark
