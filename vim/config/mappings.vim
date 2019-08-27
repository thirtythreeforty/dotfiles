" Ctrl-J and Ctrl-K insert blank lines, remaining in command mode
nnoremap <silent><C-j> :set paste<CR>m`o<Esc>``:set nopaste<CR>
nnoremap <silent><C-k> :set paste<CR>m`O<Esc>``:set nopaste<CR>

" insert one character
function! RepeatChar(char, count)
	return repeat(a:char, a:count)
endfunction
nnoremap <silent>\ :<C-U>exec "normal i".RepeatChar(nr2char(getchar()), v:count1)<CR>
nnoremap <silent><C-\> :<C-U>exec "normal a".RepeatChar(nr2char(getchar()), v:count1)<CR>

" Keep selection after (un)indent
vnoremap > >gv
vnoremap < <gv

" Re-highlight paste, using same mode as last visual
nnoremap <silent><expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]'

" Disable Ex mode, replace it with Execute Lines in Vimscript
function! ExecRange(line1, line2)
	exec substitute(join(getline(a:line1, a:line2), "\n"), '\n\s*\\', ' ', 'g')
	echom string(a:line2 - a:line1 + 1) . "L executed"
endfunction
command! -range ExecRange call ExecRange(<line1>, <line2>)

nnoremap Q :ExecRange<CR>
vnoremap Q :ExecRange<CR>

" Make Y yank to end of line (as suggested by Vim help)
noremap Y y$

" Force quit with qq (easier to type)
cnoreabbrev qq q!
cnoreabbrev qqq qall!

" I mistype this often enough
cnoreabbrev ww w

" Reload in DOS line ending mode
cnoreabbrev edos e ++ff=dos
cnoreabbrev eunix e ++ff=unix

" Unhighlight with <Leader>/
nnoremap <silent> <Leader>/ :noh<CR>

" Toggle recent buffer with <Leader>-Tab
nnoremap <silent> <Leader><Tab> :b#<CR>

" Switch windows with <leader>w, like in Spacemacs
nnoremap <leader>w <C-w>

" Delete previous word with Ctrl-Backspace
imap <C-BS> <C-W>
imap <C-_> <C-W>

" Unindent with Shift-Tab
imap <S-Tab> <C-D>

" <Delete> with <Alt-Backspace>
imap <M-BS> <Del>

" Hitting Space is much easier than hitting Shift-;
nnoremap <Space> :

" Often I want to add a semicolon to the end of a word
nnoremap <silent> <leader>; :let b:wv = winsaveview()<CR>:normal A;<CR>:call winrestview(b:wv)<CR>

" In visual mode, . repeats on each selected line
vnoremap . :norm.<CR>;
