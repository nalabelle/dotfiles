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

call ale#fix#registry#Add('toml_sort', 'TomlSort', ['toml'], 'Toml sort')

let g:ale_fixers.toml = ['toml_sort']
