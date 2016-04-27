autocmd BufRead,BufNewFile *.md set filetype=markdown
autocmd BufRead,BufNewFile *.tex set filetype=tex
autocmd BufRead,BufNewFile SConstruct set filetype=python
autocmd BufRead,BufNewFile SConscript set filetype=python
autocmd BufRead,BufNewFile TAG_EDITMSG set filetype=gitcommit
autocmd BufRead,BufNewFile *.tag set filetype=html

" Disable auto-commenting new lines, everywhere.  Must use a FileType hook
" because BufRead hooks execute before all the irritating builtin ones that
" add these options.
autocmd FileType * setlocal formatoptions-=ro

" Use visual linewise navigation in tex, markdown, and text files
autocmd FileType markdown EnableVisualLine
autocmd FileType text EnableVisualLine
autocmd FileType tex EnableVisualLine
