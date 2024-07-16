"Install vim-plug
if empty(glob('~/.vim/autoload/plug.vim'))
  silent execute
    \ '!curl -fLo ~/.vim/autoload/plug.vim '
    \ . '--create-dirs '
    \ . 'https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif

"Update plugins
autocmd VimEnter * if len(filter(values(g:plugs), '!isdirectory(v:val.dir)'))
  \| PlugInstall --sync | source $MYVIMRC
\| endif

if has("win32")
  " make windows path operators reasonable
  set shellslash
  call plug#begin('~/scoop/apps/vim/current/vimfiles/bundle/')
else
  call plug#begin('~/.vim/bundle')
endif

" Other Repositories

" Themes
Plug 'vim-scripts/xoria256.vim'

Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'

" vim-maximizer - Allows a quick maximize pane toggle
Plug 'szw/vim-maximizer'

" vim-win - Helpful shortcuts for window changes, including resize
Plug 'dstein64/vim-win'

" Helps with deleting buffers
Plug 'bit101/bufkill'

" vim-bufferline - show the buffers in the statusline or commandbar
Plug 'bling/vim-bufferline'

" vim-fugtive - git things for vim!
Plug 'tpope/vim-fugitive'

" indent guides for visually showing indent
Plug 'nathanaelkane/vim-indent-guides'

" calculate folds on save, not while typing
Plug 'Konfekt/FastFold'

" for easytags
Plug 'xolox/vim-misc'
" Adds ctags
Plug 'xolox/vim-easytags'

" Displays details from LSP
Plug 'liuchengxu/vista.vim'

" auto set paste
" Plug 'ConradIrwin/vim-bracketed-paste'
"
"" Make Vim recognize xterm escape sequences for Page and Arrow
" keys, combined with any modifiers such as Shift, Control, and Alt.
" See http://unix.stackexchange.com/questions/29907/how-to-get-vim-to-work-with-tmux-properly
" Page keys http://sourceforge.net/p/tmux/tmux-code/ci/master/tree/FAQ
" Arrow keys http://unix.stackexchange.com/a/34723
"
Plug 'nacitar/terminalkeys.vim'

" linting
Plug 'dense-analysis/ale'

" searching
Plug 'junegunn/fzf', { 'do': { -> fzf#install() } }
Plug 'junegunn/fzf.vim'

" NERDTree
Plug 'preservim/nerdtree'

"languages
Plug 'cespare/vim-toml', { 'branch': 'main' }
Plug 'derekwyatt/vim-scala'
Plug 'fatih/vim-go'
Plug 'tpope/vim-markdown'
Plug 'wlangstroth/vim-racket'
Plug 'wfxr/protobuf.vim'
Plug 'Glench/Vim-Jinja2-Syntax'

" Automates Autocomplete
Plug 'lifepillar/vim-mucomplete'

" Markdown Previews
Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}

" HCL
"Plug 'jvirtanen/vim-hcl'
Plug 'hashivim/vim-terraform'
Plug 'earthly/earthly.vim', { 'branch': 'main' }

" Deps for vim-addon-nix + that
Plug 'tomtom/tlib_vim'
Plug 'MarcWeber/vim-addon-mw-utils'
Plug 'MarcWeber/vim-addon-actions'
Plug 'MarcWeber/vim-addon-completion'
Plug 'MarcWeber/vim-addon-goto-thing-at-cursor'
Plug 'MarcWeber/vim-addon-errorformats'
Plug 'MarcWeber/vim-addon-nix'

"if executable('node') && executable('yarn')
"  Plug 'neoclide/coc.nvim', {'branch': 'release'}
"  if executable('javac') && executable('scala')
"    Plug 'scalameta/coc-metals', {'do': 'yarn install --frozen-lockfile'}
"  endif
"  Plug 'fannheyward/coc-pyright'
"  let g:coc_start_at_startup = v:false
"endif

call plug#end()
