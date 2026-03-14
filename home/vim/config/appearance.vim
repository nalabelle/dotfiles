" Colors and syntax
set background=dark
syntax on
filetype plugin indent on

" Highlighting
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
highlight NonText ctermfg=237 guifg=#3a3a3a
highlight ColorColumn ctermbg=233 guibg=#121212

" Color scheme
colorscheme xoria256
