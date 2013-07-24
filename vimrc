set nocompatible    " vim not vi, it's good to be explicit
set noexrc          " don't use local config files
set cpoptions=Be    " magic?

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

" stop littering swap everywhere
if isdirectory($HOME . '/.vim/swap') == 0
  :silent !mkdir -p ~/.vim/swap >/dev/null 2>&1
endif
set directory=~/.vim/swap

" stop littering backup everywhere
if isdirectory($HOME . '/.vim/backup') == 0
  :silent !mkdir -p ~/.vim/backup >/dev/null 2>&1
endif
set backupdir=~/.vim/backup
set backup          " make a backup file before overwriting, leave it after it's written

" stop littering undo everywhere
if exists("+undofile") " 7.3+
  if isdirectory($HOME . '/.vim/undo') == 0
    :silent !mkdir -p ~/.vim/undo > /dev/null 2>&1
  endif
  set undodir=~/.vim/undo
  set undofile
endif

set ruler           " current row and column at bottom right
set report=0        " report lines changed always
set scrolloff=5     " keep 5 lines min above and below the cursor
set showcmd         " show command in the last line of the screen
set showmatch       " when inserting a bracket, jump to the matching one (for a moment)

set incsearch       " turn on incremental search (search as you type)
set ignorecase      " ignore case in search patterns
set smartcase       " override ignorecase if the search contains uppercase
set hlsearch        " highlights searched text

set expandtab       " use spaces instead of a hard tab
set shiftround      " round indent to multiple of shiftwidth
set shiftwidth=2    " number of spaces to use for each step of indent
set softtabstop=2   " number of spaces that tab counts for when editing
set tabstop=2       " number of spaces that tab counts for in a file

" https://raw.github.com/sdball/dotfiles/master/vim/vimrc
" blocks arrow keys for forced learning
map <Left> :echo "NOPE! Use h"<cr>
map <Right> :echo "NOPE! Use l"<cr>
map <Up> :echo "NOPE! Use k"<cr>
map <Down> :echo "NOPE! Use j"<cr>

" https://raw.github.com/sdball/dotfiles/master/vim/vimrc
" highlight trailing whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" https://github.com/tpope/vim-pathogen#readme
" call pathogen#infect()
