set nocompatible
      
if has("multi_byte")
  set encoding=utf-8
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
else
  echoerr "no unicode!"
endif

" File handling
set modeline
set modelines=5
set backspace=indent,eol,start
set backup
set undofile
set swapfile

" XDG Base Directory Specification compliance
" Use XDG_CACHE_HOME for vim temporary files
if empty($XDG_CACHE_HOME)
  let $XDG_CACHE_HOME = $HOME . '/.cache'
endif

" Set directories for swap, backup, and undo files
set directory=$XDG_CACHE_HOME/vim/swap//
set backupdir=$XDG_CACHE_HOME/vim/backup//
set undodir=$XDG_CACHE_HOME/vim/undo//

" Create directories if they don't exist
if !isdirectory($XDG_CACHE_HOME . '/vim/swap')
  call mkdir($XDG_CACHE_HOME . '/vim/swap', 'p')
endif
if !isdirectory($XDG_CACHE_HOME . '/vim/backup')
  call mkdir($XDG_CACHE_HOME . '/vim/backup', 'p')
endif
if !isdirectory($XDG_CACHE_HOME . '/vim/undo')
  call mkdir($XDG_CACHE_HOME . '/vim/undo', 'p')
endif

" Interface
set title
set noexrc
set cpoptions=Ben
set noerrorbells
set novisualbell
set ruler
set report=0
set scrolloff=5
set showcmd
set showmatch

" Search
set incsearch
set ignorecase
set smartcase
set hlsearch

" Tabs and spacing
set expandtab
set shiftround
set shiftwidth=2
set softtabstop=2
set tabstop=2

" Display settings
set number
set list
set linebreak
let &showbreak = '↪️  '
set listchars=tab:→…,trail:•,nbsp:␣,extends:⟩,precedes:⟨,eol:¶
set laststatus=2
set noshowmode

" Terminal settings
if ! has('gui_running')
  set ttimeoutlen=10
endif

" Sign column
set signcolumn=yes

" Splits
set splitbelow
set splitright

" Folds
set foldmethod=indent
set foldlevel=99
set foldlevelstart=99
set foldcolumn=7

" Completion
set completeopt=menuone,noinsert,preview
set shortmess+=c

" Mouse
set mouse=
set ttymouse=
