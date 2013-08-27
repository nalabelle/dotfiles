set nocompatible    " vim not vi, it's good to be explicit
filetype off        " required for vundle

" Vundle Initialization
" Must come early to allow setting options later
set rtp+=~/.vim/bundle/vundle/
call vundle#rc()

" Vundle the Vundle
" required
Bundle 'gmarik/vundle'

" Other Repositories

" Themes
"Bundle 'jonathanfilip/vim-lucius'
"Bundle 'darkspectrum'
"Bundle 'wombat256'
"Bundle 'wombat256mod'
"Bundle 'junegunn/seoul256.vim'
"Bundle 'baskerville/bubblegum'
"Bundle 'w0ng/vim-hybrid'
Bundle 'xoria256.vim'

" vim-airline
" like powerline
Bundle 'bling/vim-airline'

" vim-bufferline
" show the buffers in the statusline or commandbar
Bundle 'bling/vim-bufferline'

" vim-fugtive
" git things for vim!
Bundle 'tpope/vim-fugitive'

" vim-coffee-script
" support coffee script, comes with a lot of things
Bundle 'kchmck/vim-coffee-script'

" indent guides for visually showing indent
Bundle 'nathanaelkane/vim-indent-guides.git'

set noexrc          " don't use local config files
set cpoptions=Be    " magic?

" color options
colo xoria256
set background=dark " could be light too...

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

" Tab Formatting
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

" Make Vim recognize xterm escape sequences for Page and Arrow
" keys, combined with any modifiers such as Shift, Control, and Alt.
" See http://unix.stackexchange.com/questions/29907/how-to-get-vim-to-work-with-tmux-properly
if &term =~ '^screen'
  " Page keys http://sourceforge.net/p/tmux/tmux-code/ci/master/tree/FAQ
  execute "set t_kP=\e[5;*~"
  execute "set t_kN=\e[6;*~"

  " Arrow keys http://unix.stackexchange.com/a/34723
  execute "set <xUp>=\e[1;*A"
  execute "set <xDown>=\e[1;*B"
  execute "set <xRight>=\e[1;*C"
  execute "set <xLeft>=\e[1;*D"
endif

" Always display status line
set laststatus=2
" Don't show mode in the command bar
set noshowmode

" Airline customization
let g:airline_theme='bubblegum'

" Bufferline shows the buffers
let g:bufferline_echo = 0

" Leave insert mode immediately
if ! has('gui_running')
    set ttimeoutlen=10
    augroup FastEscape
        autocmd!
        au InsertEnter * set timeoutlen=0
        au InsertLeave * set timeoutlen=1000
    augroup END
endif

" Visual Indent from vim-indent-guides
let indent_guides_enable_on_vim_startup = 1
