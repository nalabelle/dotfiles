set nocompatible    " vim not vi, it's good to be explicit
filetype off        " required for vundle
set title

" Vundle Initialization
" Must come early to allow setting options later
" 2014-05-13: set rtp+=~/.vim/bundle/vundle/
set rtp+=~/.vim/bundle/Vundle.vim
call vundle#begin()

" Vundle the Vundle
Plugin 'VundleVim/Vundle.vim'

" Other Repositories

" Themes
Plugin 'xoria256.vim'

" ctrl-p for finding files
Plugin 'ctrlpvim/ctrlp.vim'

" vim-airline
" like powerline
Plugin 'vim-airline/vim-airline'
Plugin 'vim-airline/vim-airline-themes'

" vim-bufferline
" show the buffers in the statusline or commandbar
Plugin 'bling/vim-bufferline'

" vim-fugtive
" git things for vim!
Plugin 'tpope/vim-fugitive'

" vim-coffee-script
" support coffee script, comes with a lot of things
Plugin 'kchmck/vim-coffee-script'

" indent guides for visually showing indent
Plugin 'nathanaelkane/vim-indent-guides'

" racket support
Plugin 'wlangstroth/vim-racket'

" golang
Plugin 'fatih/vim-go'

" markdown
Plugin 'tpope/vim-markdown'

" session saving
Plugin 'tpope/vim-obsession'

" session helper
"Plugin 'dhruvasagar/vim-prosession'

" auto set paste
" Plugin 'ConradIrwin/vim-bracketed-paste'

" linting
Plugin 'dense-analysis/ale'

call vundle#end()

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
" set backspace=indent,eol,start


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

" set EOL chars to almost blend in
highlight NonText ctermfg=237
set number
set list
set showbreak=↪\
set listchars=tab:→…,trail:•,nbsp:⎵,extends:⟩,precedes:⟨,eol:¶

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

" Warn me when I'm over 80 cols
if exists('+colorcolumn')
  set colorcolumn=80
else
  au BufWinEnter * let w:m2=matchadd('ErrorMsg', '\%>80v.\+', -1)
endif

" Git Blame
function! GitBlameCurrentLine()
    let l:file = expand('%')
    let l:lnum = line(".")
    execute "!clear && git show $(git blame -w " . l:file . " -L " . l:lnum . "," . l:lnum . " | awk '{ print $1 }')"
endf
map \b :call GitBlameCurrentLine()<CR>

" easier split moving
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" open splits to right and bottom
set splitbelow
set splitright

" ctrlp bump file limits
let g:ctrlp_max_files=0
let g:ctrlp_max_depth=40
