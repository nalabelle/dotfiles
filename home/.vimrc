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
set title

source ~/.vim/plug.vim

set noexrc          " don't use local config files
" http://vimdoc.sourceforge.net/htmldoc/options.html#'cpoptions'
set cpoptions=Ben

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
set linebreak
let &showbreak = '↪️  '
set listchars=tab:→…,trail:•,nbsp:␣,extends:⟩,precedes:⟨,eol:¶

" Always display status line
set laststatus=2
" Don't show mode in the command bar
set noshowmode


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
  set foldcolumn=0
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

" Folds
" note: set foldcolumn=X to see the folds
set foldmethod=indent
set foldlevel=99
set foldlevelstart=99
let g:fastfold_minlines = 0
let g:fastfold_savehook = 1
set foldcolumn=7

" ALE fixers
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

"set completeopt+=longest
set completeopt+=menuone
set completeopt+=noinsert
set completeopt+=noselect

let g:mucomplete#enable_auto_at_startup = 1
let g:mucomplete#tab_when_no_results = 1

"selecting an autocomplete option should not insert a newline
inoremap <expr> <CR> pumvisible() ? "\<C-y>" : "\<C-g>u\<CR>"
" typeahead
inoremap <expr> <C-n> pumvisible() ? '<C-n>' :
  \ '<C-n><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'
inoremap <expr> <M-,> pumvisible() ? '<C-n>' :
  \ '<C-x><C-o><C-n><C-p><C-r>=pumvisible() ? "\<lt>Down>" : ""<CR>'

if exists("+omnifunc")
  set omnifunc=syntaxcomplete#Complete
endif

if has("autocmd")
  " drop into the last buffer to avoid E173 "more files to edit" on :q
  autocmd QuitPre * blast
endif

" vim-go
let g:go_code_completion_enabled = 0

" NERDTree
nnoremap <c-t> :NERDTreeToggle<cr>
nnoremap <c-f> :NERDTreeFind<cr>

" Fzf
let g:fzf_buffers_jump = 1
let g:fzf_command_prefix = 'Fzf'
nnoremap <tab> :FzfBuffer<cr>
nnoremap <leader>e :FzfFiles<cr>
nnoremap <leader>E :FzfGFiles<cr>
nnoremap <leader>/ :FzfBLines<cr>

" vim-bufferline
" :help bufferline
let g:bufferline_echo = 0
" bufferline aligns to the right in airline, so you want to pin your current
" buffer to the right for it to be usable with many open buffers
let g:bufferline_fixed_index = -2
let g:bufferline_rotate = 1

" Airline
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
let g:airline_symbols.branch = ''
let g:airline_symbols.readonly = 'RO'

let g:mkdp_filetypes = ['markdown', 'page']
