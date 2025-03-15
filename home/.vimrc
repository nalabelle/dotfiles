set nocompatible    " vim not vi, it's good to be explicit
if has("multi_byte")
  set encoding=utf-8

  if &termencoding == ""
    let &termencoding = &encoding  " Use internal encoding for terminal if not specified
  endif

  if exists("+printencoding") && (&printencoding == "")
    let &printencoding = &encoding  " Use internal encoding for printing if not specified
  endif

  set fileencodings-=ucs-bom
  set fileencodings-=utf-8
  if(&fileencodings == "") && (&encoding != "utf-8")
    let &fileencodings = &encoding  " Use internal encoding as default file encoding if not set
  endif
  set fileencodings^=ucs-bom,utf-8  " Prioritize UTF-8 with BOM when detecting file encoding

else
  echoerr "no unicode!"  " Error if multi-byte support is not available
endif
set title           " Show filename in the window title bar


source ~/.vim/plug.vim

set noexrc          " Don't use local .exrc, .vimrc, or .gvimrc files (security feature)
" http://vimdoc.sourceforge.net/htmldoc/options.html#'cpoptions'
set cpoptions=Ben    " Set compatibility options: B=backslashes in mappings, e=<CR> in mappings, n=column used for 'number'

" Color scheme settings
set background=dark  " Use dark background for color schemes

" Enable syntax highlighting
syntax on           " Turns on color syntax highlighting

" Enable filetype detection and related features
filetype plugin indent on  " Load filetype-specific plugins and indent files

" Modeline settings (special comments in files that set vim options)
set modeline        " Enable modelines (vim settings embedded in files)
set modelines=5     " Check first and last 5 lines of files for modelines

" Backspace behavior configuration
set backspace=indent,eol,start  " Allow backspacing over autoindent, line breaks, and start of insert


" Disable annoying error notifications
set noerrorbells    " Turn off audible error bells
set novisualbell    " Turn off visual error bells (screen flashing)

" Centralize swap files instead of creating them in the current directory
if isdirectory($HOME . '/.vim/swap') == 0
  :silent !mkdir -p ~/.vim/swap >/dev/null 2>&1  " Create swap directory if it doesn't exist
endif
set directory=~/.vim/swap,$TEMP  " Store swap files in ~/.vim/swap, fallback to $TEMP

" Centralize backup files
if isdirectory($HOME . '/.vim/backup') == 0
  :silent !mkdir -p ~/.vim/backup >/dev/null 2>&1  " Create backup directory if it doesn't exist
endif
set backupdir=~/.vim/backup,$TEMP  " Store backup files in ~/.vim/backup, fallback to $TEMP
set backup          " Create backup files before overwriting, keep them after writing

" Persistent undo history (available in Vim 7.3+)
if exists("+undofile") " 7.3+
  if isdirectory($HOME . '/.vim/undo') == 0
    :silent !mkdir -p ~/.vim/undo > /dev/null 2>&1  " Create undo directory if it doesn't exist
  endif
  set undodir=~/.vim/undo,$TEMP  " Store undo files in ~/.vim/undo, fallback to $TEMP
  set undofile        " Save undo history to a file when exiting a buffer
endif

" Interface and display settings
set ruler           " Show cursor position (line,column) in the status line
set report=0        " Always report the number of lines changed by a command
set scrolloff=5     " Keep at least 5 lines visible above/below cursor when scrolling
set showcmd         " Show partial command in the last line of the screen
set showmatch       " Briefly jump to matching bracket when inserting one

" Search behavior settings
set incsearch       " Incremental search - show matches while typing
set ignorecase      " Case-insensitive searching
set smartcase       " Override ignorecase when search pattern has uppercase
set hlsearch        " Highlight all matches of the search pattern

" Tab and indentation settings
set expandtab       " Use spaces instead of tab characters
set shiftround      " Round indentation to multiple of shiftwidth when using > and <
set shiftwidth=2    " Number of spaces for each indentation level (used by >>, <<)
set softtabstop=2   " Number of spaces a Tab counts for when editing (inserting/deleting)
set tabstop=2       " Number of spaces a Tab character displays as in the file

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
set linebreak
let &showbreak = '↪️  '
set listchars=tab:→…,trail:•,nbsp:␣,extends:⟩,precedes:⟨,eol:¶

" Status line configuration
set laststatus=2    " Always show status line (0=never, 1=if multiple windows, 2=always)
" Don't show mode in the command bar (often redundant with status line plugins)
set noshowmode


" Quick escape from insert mode (reduces delay when pressing Esc)
if ! has('gui_running')
  set ttimeoutlen=10   " Time in ms to wait for a key code sequence to complete
  augroup FastEscape
    autocmd!
    au InsertEnter * set timeoutlen=0    " No timeout for mappings in insert mode
    au InsertLeave * set timeoutlen=1000 " Normal timeout in normal mode
  augroup END
endif

" Sign column for displaying diagnostics/errors
set signcolumn=yes   " Always show the sign column (for git/linting indicators)

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
  set foldcolumn=0
  call SetColorColumns()
endf

map <Leader>o :silent !open -jg "%"<CR>
map <Leader>m :messages<CR>

" Remap recorder
nnoremap <Leader>q q
nnoremap q <NOP>

" https://raw.github.com/sdball/dotfiles/master/vim/vimrc
" blocks arrow keys for forced learning
map <Left> :echo "NOPE! Use h"<cr>
map <Right> :echo "NOPE! Use l"<cr>
map <Up> :echo "NOPE! Use k"<cr>
map <Down> :echo "NOPE! Use j"<cr>

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

" Split window behavior
set splitbelow      " New horizontal splits appear below current window
set splitright      " New vertical splits appear to the right of current window


" Cursor shape settings for different modes (works in compatible terminals)

"  1 -> blinking block
"  2 -> solid block
"  3 -> blinking underscore
"  4 -> solid underscore
"  5 -> blinking vertical bar
"  6 -> solid vertical bar

" Mode-specific cursor shapes
let &t_SI ="\e[6 q" " SI = INSERT mode - vertical bar
let &t_SR ="\e[4 q" " SR = REPLACE mode - underscore
let &t_EI ="\e[2 q" " EI = NORMAL mode - solid block
"set t_RB= t_RF= t_RV= t_u7=

au VimEnter * silent !echo -e "\e[2 q"

" Folds
" note: set foldcolumn=X to see the folds
set foldmethod=indent
set foldlevel=99
set foldlevelstart=99
let g:fastfold_minlines = 0
let g:fastfold_savehook = 1
set foldcolumn=7

set completeopt=menuone,noinsert,preview
set shortmess+=c " Shut off completion messages

"selecting an autocomplete option should not insert a newline
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"

if has("autocmd")
  " drop into the last buffer to avoid E173 "more files to edit" on :q
  autocmd QuitPre * blast
endif


let g:mkdp_filetypes = ['markdown', 'page']

" bufkill
nnoremap <Leader>D :KillBuffer<CR>

" Toggle fold
nnoremap <space> za

" Don't use mouse
set mouse=
set ttymouse=
