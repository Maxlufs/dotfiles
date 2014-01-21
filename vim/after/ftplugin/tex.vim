call IMAP('`w', '\omega', 'tex')

" Here do not use inoremap, because IMAP_JumpForward itself is a mapping to
" another function called IMAP_Jumpfunc
imap <C-J> <Plug>IMAP_JumpForward
imap <C-K> <Plug>IMAP_JumpBack
