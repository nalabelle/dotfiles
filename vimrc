" vim not vi
set nocompatible

" magic?
set noexrc
set cpoptions=Be

" color options
colo desert
set background=dark

" syntax highlighting
syntax on

" trigger filetype detection things
filetype plugin indent on

" allow backspacing over autoindent, linebreaks, and start of insert
set backspace=indent,eol,start

" make sure error bells stay off
set noerrorbells    
set novisualbell

set backup          " make a backup file before overwriting, leave it after it's written
set incsearch       " turn on incremental search (search as you type)
set ruler           " current row and column at bottom right
set report=0        " report lines changed always
set scrolloff=5     " keep 5 lines min above and below the cursor
set showcmd         " show command in the last line of the screen
set showmatch       " when inserting a bracket, jump to the matching one (for a moment)
set ignorecase      " ignore case in search patterns
set smartcase       " override ignorecase if the search contains uppercase

set expandtab       " use spaces instead of a hard tab
set shiftround      " round indent to multiple of shiftwidth
set shiftwidth=2    " number of spaces to use for each step of indent
set softtabstop=2   " number of spaces that tab counts for when editing
set tabstop=2       " number of spaces that tab counts for in a file

" https://github.com/tpope/vim-pathogen#readme
call pathogen#infect()

