" Leader key
let mapleader = "\\"

" Disable recording
nnoremap <Leader>q q
nnoremap q <NOP>

" Enforce hjkl movement
map <Left> :echo "NOPE! Use h"<cr>
map <Right> :echo "NOPE! Use l"<cr>
map <Up> :echo "NOPE! Use k"<cr>
map <Down> :echo "NOPE! Use j"<cr>

" Custom mappings
map <Leader>n :call ToggleFormatting()<CR>
map <Leader>p :set paste!<CR>
map <Leader>b :call GitBlameCurrentLine()<CR>
map <Leader>o :silent !open -jg "%"<CR>
map <Leader>m :messages<CR>
nnoremap <space> za

" Completion mapping
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

" Cursor shape
let &t_SI ="\e[6 q"  " INSERT mode - vertical bar
let &t_SR ="\e[4 q"  " REPLACE mode - underscore
let &t_EI ="\e[2 q"  " NORMAL mode - solid block
