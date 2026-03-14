" Enable spell checking
setlocal spell
setlocal spelllang=en

function! MarkdownLintFix(buffer) abort
  return {
        \ 'command': 'markdownlint --fix %t',
        \ 'read_temporary_file': 1,
        \}
endfunction

execute ale#fix#registry#Add('markdownlintfix', 'MarkdownLintFix', ['markdown'], 'mdlintfix')

let b:ale_fixers = ['prettier', 'markdownlintfix']
let b:ale_javascript_prettier_options = '--prose-wrap always'
