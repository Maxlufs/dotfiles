call IMAP('`w', '\omega', 'tex')

" Here do not use inoremap, because IMAP_JumpForward itself is a mapping to
" another function called IMAP_Jumpfunc
autocmd FileType tex imap <C-J> <Plug>IMAP_JumpForward
autocmd FileType tex imap <C-K> <Plug>IMAP_JumpBack
