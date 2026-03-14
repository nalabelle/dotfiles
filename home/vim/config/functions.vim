" Column display toggle
function! SetColorColumns()
  if &colorcolumn
    set colorcolumn=
  else
    set colorcolumn=80,100
  endif
endf
call SetColorColumns()

" Git blame for current line
function! GitBlameCurrentLine()
  let l:file = expand('%')
  let l:lnum = line(".")
  execute "!clear && git show $(git blame -w " . l:file . " -L " . l:lnum . "," . l:lnum . " | awk '{ print $1 }')"
endf

" Whitespace trimming
function! TrimWhitespace()
  %s/\s\+$//
endf
command! TrimWhitespace call TrimWhitespace()

" Toggle formatting
function! ToggleFormatting()
  set number!
  set list!
  set foldcolumn=0
  call SetColorColumns()
endf
