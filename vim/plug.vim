" ale
if !empty(glob('~/.vim/bundle/ale'))
  let g:ale_completion_enabled = 1

  " ALE fixers
  function! Retab(buffer) abort
    retab
  endfunction

  function! AutoIndent(buffer) abort
    " Mark cursor, then go to the middle, format, then unwind the cursor stack
    exe 'normal! mc;M;mm;gg=G;`m;`c'
  endfunction


  let g:ale_fixers = {'*': ['retab', 'remove_trailing_lines', 'trim_whitespace']}
  let g:ale_fix_on_save = 0
  let g:ale_set_balloons = 1

  map <Leader>af :ALEFix<CR>

  set omnifunc=ale#completion#OmniFunc
endif

if !empty(glob('~/.vim/bundle/vim-mucomplete'))
  let g:mucomplete#enable_auto_at_startup = 1
  let g:mucomplete#buffer_relative_paths = 1
  let g:mucomplete#no_mappings = 1
  let g:MUcompleteNotify = 3

  imap <unique> <c-j> <plug>(MUcompleteCycFwd)
  imap <expr> <right> mucomplete#extend_fwd("\<right>")
endif

" vim-polyglot
if !empty(glob('~/.vim/bundle/vim-polyglot'))
  let g:polyglot_disabled = ['markdown']
endif

" markdown-preview
if !empty(glob('~/.vim/bundle/markdown-preview.nvim'))
  nmap <Leader>v <Plug>MarkdownPreviewToggle
endif

if !empty(glob('~/.vim/bundle/vim-markdown'))
  " Source: https://codeinthehole.com/tips/writing-markdown-in-vim/
  " Enable folding.
  let g:vim_markdown_folding_disabled = 0

  " Fold heading in with the contents.
  let g:vim_markdown_folding_style_pythonic = 1

  " Don't use the shipped key bindings.
  let g:vim_markdown_no_default_key_mappings = 1

  " Autoshrink TOCs.
  let g:vim_markdown_toc_autofit = 1

  " Indentation for new lists. We don't insert bullets as it doesn't play
  " nicely with `gq` formatting. It relies on a hack of treating bullets
  " as comment characters.
  " See https://github.com/plasticboy/vim-markdown/issues/232
  let g:vim_markdown_new_list_item_indent = 0
  let g:vim_markdown_auto_insert_bullets = 0

  " Filetype names and aliases for fenced code blocks.
  let g:vim_markdown_fenced_languages = ['php', 'py=python', 'js=javascript', 'bash=sh', 'viml=vim']

  " Highlight front matter (useful for Hugo posts).
  let g:vim_markdown_toml_frontmatter = 1
  let g:vim_markdown_json_frontmatter = 1
  let g:vim_markdown_frontmatter = 1

  " Format strike-through text (wrapped in `~~`).
  let g:vim_markdown_strikethrough = 1

  let g:vim_markdown_folding_level = 2
endif



if !empty(glob('~/.vim/bundle/vimspector'))
  " https://github.com/puremourning/vimspector/blob/master/README.md#visual-studio--vscode
  " :help vimspector-visual-studio-vscode
  let g:vimspector_enable_mappings = 'VISUAL_STUDIO'
endif

" vim-maximizer
if !empty(glob('~/.vim/bundle/vim-maximizer'))
  nnoremap <C-W>z :MaximizerToggle<CR>
endif

if !empty(glob('~/.vim/bundle/vim-indent-guides'))
  " Visual Indent from vim-indent-guides
  let indent_guides_enable_on_vim_startup = 1
endif

" Airline
if !empty(glob('~/.vim/bundle/vim-airline'))
  let g:airline#extensions#tabline#enabled = 1
  let g:airline#extensions#tabline#formatter = 'unique_tail_improved'
  "let g:airline#extensions#tabline#current_first = 1

  let g:airline#extensions#tabline#buffers_label = ''
  let g:airline#extensions#tabline#buffer_nr_show = 1
  let g:airline#extensions#tabline#buffer_nr_format = '%s:'

  "let g:airline_section_c = 'TEST%t'

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
endif


if !empty(glob('~/.vim/bundle/vim-gutentags'))
  set statusline+=%{gutentags#statusline()}
  let g:gutentags_cache_dir='.tags'
endif

if !empty(glob('~/.vim/bundle/vista.vim'))
  let g:vista#renderer#enable_icon = 1
  nnoremap <Leader>v :Vista!!<CR>
endif



" Plugin loading

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
"Plug 'baskerville/bubblegum'

Plug 'vim-airline/vim-airline'
  Plug 'vim-airline/vim-airline-themes'

" vim-maximizer - Allows a quick maximize pane toggle
Plug 'szw/vim-maximizer'

" vim-win - Helpful shortcuts for window changes, including resize
Plug 'dstein64/vim-win'

" Helps with deleting buffers
Plug 'bit101/bufkill'

" vim-fugtive - git things for vim!
Plug 'tpope/vim-fugitive'

" indent guides for visually showing indent
Plug 'preservim/vim-indent-guides'

" calculate folds on save, not while typing
Plug 'Konfekt/FastFold'

" generate tags
Plug 'ludovicchabant/vim-gutentags'

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
Plug 'sheerun/vim-polyglot'
Plug 'godlygeek/tabular'
Plug 'preservim/vim-markdown'
Plug 'cespare/vim-toml', { 'branch': 'main' }
Plug 'derekwyatt/vim-scala'
Plug 'fatih/vim-go'
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

Plug 'LucHermitte/lh-vim-lib'
Plug 'LucHermitte/local_vimrc'

"if executable('node') && executable('yarn')
"  Plug 'neoclide/coc.nvim', {'branch': 'release'}
"  if executable('javac') && executable('scala')
"    Plug 'scalameta/coc-metals', {'do': 'yarn install --frozen-lockfile'}
"  endif
"  Plug 'fannheyward/coc-pyright'
"  let g:coc_start_at_startup = v:false
"endif
"
Plug 'puremourning/vimspector'

" Svelte
Plug 'othree/html5.vim'
Plug 'pangloss/vim-javascript'
Plug 'evanleck/vim-svelte', {'branch': 'main'}

call plug#end()


" Requires plugins to be loaded

" ale
if !empty(glob('~/.vim/bundle/ale'))
  call ale#fix#registry#Add('retab', 'Retab', [], 'Retabs as per vim settings')
  call ale#fix#registry#Add('auto_indent', 'AutoIndent', [], 'vim auto-indent, gg=G')
endif


if !empty(glob('~/.vim/bundle/vim-mucomplete')) && !empty(glob('~/.vim/bundle/vim-airline'))
  function MUcompleteMethod()
    if !pumvisible()
      return ''
    endif
    let mucomplete_method = get(g:mucomplete#msg#short_methods,
      \        get(g:, 'mucomplete_current_method', ''), '')
    if mucomplete_method != ''
      return printf('[%s]', mucomplete_method)
    else
      return ''
    endif
  endfunction
  function! MUcompleteStatus(...)
    call airline#extensions#prepend_to_section('x', '%{MUcompleteMethod()} ')
  endfunction

  call airline#add_statusline_func('MUcompleteStatus')
endif

if !empty(glob('~/.vim/bundle/xoria256.vim'))
  colo xoria256
  set background=dark " could be light too...
endif

" if !empty(glob('~/.vim/bundle/bubblegum'))
"   colo bubblegum-256-dark
" endif


