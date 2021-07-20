set nocompatible    " vim not vi, it's good to be explicit
if has("multi_byte")
  if &termencoding == ""
    let &termencoding = &encoding
  endif

  if exists("+printencoding") && (&printencoding == "")
    let &printencoding = &encoding
  endif

  set fileencodings-=ucs-bom
  set fileencodings-=utf-8
  if(&fileencodings == "") && (&encoding != "utf-8")
    let &fileencodings = &encoding
  endif
  set fileencodings^=ucs-bom,utf-8

  set encoding=utf-8
  setglobal fileencoding=utf-8
else
  echoerr "no unicode!"
endif
filetype off        " required for vundle
set title

" make windows path operators reasonable
if has("win32")
  set shellslash
  set rtp+=~/scoop/apps/vim/current/vimfiles/bundle/Vundle.vim
  call vundle#begin('~/scoop/apps/vim/current/vimfiles/bundle/')
else
  set rtp+=~/.vim/bundle/Vundle.vim
  call vundle#begin()
endif


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
"
"" Make Vim recognize xterm escape sequences for Page and Arrow
" keys, combined with any modifiers such as Shift, Control, and Alt.
" See http://unix.stackexchange.com/questions/29907/how-to-get-vim-to-work-with-tmux-properly
" Page keys http://sourceforge.net/p/tmux/tmux-code/ci/master/tree/FAQ
" Arrow keys http://unix.stackexchange.com/a/34723
"
Plugin 'nacitar/terminalkeys.vim'

" linting
Plugin 'dense-analysis/ale'

Plugin 'cespare/vim-toml'

" NERDTree
Plugin 'preservim/nerdtree'

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
set backspace=indent,eol,start


" make sure error bells stay off
set noerrorbells
set novisualbell

" stop littering swap everywhere
if isdirectory($HOME . '/.vim/swap') == 0
  :silent !mkdir -p ~/.vim/swap >/dev/null 2>&1
endif
set directory=~/.vim/swap,$TEMP

" stop littering backup everywhere
if isdirectory($HOME . '/.vim/backup') == 0
  :silent !mkdir -p ~/.vim/backup >/dev/null 2>&1
endif
set backupdir=~/.vim/backup,$TEMP
set backup          " make a backup file before overwriting, leave it after it's written

" stop littering undo everywhere
if exists("+undofile") " 7.3+
  if isdirectory($HOME . '/.vim/undo') == 0
    :silent !mkdir -p ~/.vim/undo > /dev/null 2>&1
  endif
  set undodir=~/.vim/undo,$TEMP
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
" highlight trailing whitespace
highlight ExtraWhitespace ctermbg=red guibg=red
match ExtraWhitespace /\s\+$/
autocmd BufWinEnter * match ExtraWhitespace /\s\+$/
autocmd InsertEnter * match ExtraWhitespace /\s\+\%#\@<!$/
autocmd InsertLeave * match ExtraWhitespace /\s\+$/
autocmd BufWinLeave * call clearmatches()

" set EOL chars to almost blend in
highlight NonText ctermfg=237 guifg=#3a3a3a

" set ColorColumns to _near_ bg
highlight ColorColumn ctermbg=233 guibg=#121212

set number
set list
set showbreak=↪️
set listchars=tab:→…,trail:•,nbsp:␣,extends:⟩,precedes:⟨,eol:¶

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
function! SetColorColumns()
  if &colorcolumn
    set colorcolumn=
  else
    set colorcolumn=80,100
  endif
endf
call SetColorColumns()

" Git Blame
function! GitBlameCurrentLine()
  let l:file = expand('%')
  let l:lnum = line(".")
  execute "!clear && git show $(git blame -w " . l:file . " -L " . l:lnum . "," . l:lnum . " | awk '{ print $1 }')"
endf

function! ToggleFormatting()
  set number!
  set list!
  call SetColorColumns()
endf

map <Leader>o :silent !open -jg "%"<CR>
map <Leader>f :ALEFix<CR>
map <Leader>m :messages<CR>

" https://raw.github.com/sdball/dotfiles/master/vim/vimrc
" blocks arrow keys for forced learning
map <Left> :echo "NOPE! Use h"<cr>
map <Right> :echo "NOPE! Use l"<cr>
map <Up> :echo "NOPE! Use k"<cr>
map <Down> :echo "NOPE! Use j"<cr>

" easier split moving
nnoremap <C-J> <C-W><C-J>
nnoremap <C-K> <C-W><C-K>
nnoremap <C-L> <C-W><C-L>
nnoremap <C-H> <C-W><C-H>

" hide and show numbers/non-printing chars
map <Leader>n :call ToggleFormatting()<CR>
" enter and exit print mod
map <Leader>p :set paste!<CR>
" remove whitespace at end of lines
function! TrimWhitespace()
  %s/\s\+$//
endf
command! TrimWhitespace call TrimWhitespace()

map <Leader>b :call GitBlameCurrentLine()<CR>

" open splits to right and bottom
set splitbelow
set splitright

" ctrlp bump file limits
let g:ctrlp_max_files=0
let g:ctrlp_max_depth=40

"Cursor settings:

"  1 -> blinking block
"  2 -> solid block
"  3 -> blinking underscore
"  4 -> solid underscore
"  5 -> blinking vertical bar
"  6 -> solid vertical bar
"
""Mode Settings

let &t_SI ="\e[6 q" "SI = INSERT mode
let &t_SR ="\e[4 q" "SR = REPLACE mode
let &t_EI ="\e[2 q" "EI = NORMAL mode (ELSE)
"set t_RB= t_RF= t_RV= t_u7=
au VimEnter * silent !echo -e "\e[2 q"

if has('gui_running')
  " Make shift-insert work like in Xterm
  map <S-Insert> <MiddleMouse>
  map! <S-Insert> <MiddleMouse>

  " Only do this for Vim version 5.0 and later.
  if version >= 500

    " Switch on syntax highlighting if it wasn't on yet.
    if !exists("syntax_on")
      syntax on
    endif

    " For Win32 version, have "K" lookup the keyword in a help file
    "if has("win32")
    "  let winhelpfile='windows.hlp'
    "  map K :execute "!start winhlp32 -k <cword> " . winhelpfile <CR>
    "endif

    "set enc=utf-8
    set guifont=Fira_Code_Retina:h11:cDEFAULT:qCLEARTYPE

  endif
endif

" ALE fixers
function! Retab(buffer) abort
  retab
endfunction

function! AutoIndent(buffer) abort
  " Mark cursor, then go to the middle, format, then unwind the cursor stack
  exe 'normal! mc;M;mm;gg=G;`m;`c'
endfunction

call ale#Set('toml_sort_executable', 'toml-sort')
function! TomlSort(buffer) abort
  let l:executable = ale#Var(a:buffer, 'toml_sort_executable')
  let l:filename = ale#Escape(bufname(a:buffer))
  let l:exec_args = ' --all'

  let l:result = {
        \   'command': ale#Escape(l:executable) . l:exec_args
        \}

  return l:result
endfunction

call ale#fix#registry#Add('retab', 'Retab', [], 'Retabs as per vim settings')
call ale#fix#registry#Add('auto_indent', 'AutoIndent', [], 'vim auto-indent, gg=G')
call ale#fix#registry#Add('toml_sort', 'TomlSort', ['toml'], 'Toml sort')

let g:ale_fixers = {'*': ['retab', 'remove_trailing_lines', 'trim_whitespace']}
let g:ale_fixers.python = ['isort', 'black']
let g:ale_fixers.toml = ['toml_sort']
let g:ale_fix_on_save = 0
