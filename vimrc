"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Filename: .vimrc						                            "
    " Maintainer: Maximilian Q. Wang <maxlufs@gmail.com> 		        "
    " URL: https://github.com/Maxlufs/dotfiles 			                "
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Contents: 							                            "
    " 00. Custom .................. Custom Vim settings 		        "
    " 01. General ................. General Vim behavior 		        "
    " 02. Events .................. General autocmd events		        "
    " 03. Theme/Colors ............ Colors, fonts, etc. 		        "
    " 04. Vim UI .................. User interface behavior 	        "
    " 05. Text Formatting/Layout .. Text, tab, indentation related 	    "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 01. General 									                            "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" get rid of Vi compatibility mode. SET FIRST!
set nocompatible 

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 02. Events 									                            "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" filetype detection[ON] plugin[ON] indent[ON]
filetype plugin indent on 

" Automatic update .vimrc on the fly
if has("autocmd")
    autocmd bufwritepost .vimrc source $MYVIMRC
endif
   

" In Makefiles DO NOT use spaces instead of tabs
autocmd FileType make setlocal noexpandtab

" " In Ruby files, use 2 spaces instead of 4 for tabs
" autocmd FileType ruby setlocal sw=2 ts=2 sts=2

" " Enable omnicompletion (to use, hold Ctrl+X then Ctrl+O while in Insert mode.
" set ofu=syntaxcomplete#Complete

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 03. Theme/Colors 								                            "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set t_Co=256 " enable 256-color mode.
" syntax enable " enable syntax highlighting (previously syntax on).
" colorscheme wombat256mod " set colorscheme
" colorscheme wombat

" " Prettify JSON files
" autocmd BufRead,BufNewFile *.json set filetype=json
" autocmd Syntax json sou ~/.vim/syntax/json.vim
"
" " Prettify Vagrantfile
" autocmd BufRead,BufNewFile Vagrantfile set filetype=ruby
"
" " Highlight characters that go over 80 columns
" highlight OverLength ctermbg=red ctermfg=white guibg=#592929
" match OverLength /\%81v.\+/
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 04. Vim UI 									                            "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set number " show line numbers
" set cul " highlight current line
set laststatus=2 " last window always has a statusline
" set nohlsearch " Don't continue to highlight searched phrases.
set incsearch " But do highlight as you type your search.
set ignorecase " Make searches case-insensitive.
" set ruler " Always show info along bottom.
set showmatch " Show matching parenthesis

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 05. Text Font/Formatting/Layout 						                    "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set autoindent " auto-indent
set tabstop=4 " tab columns
set softtabstop=4 " how many columns when hit Tab in insert mode, unify this
set shiftwidth=4 " indent/outdent for reindent operations (<< and >>)
set shiftround " always indent/outdent to the nearest tabstop
set expandtab " use spaces instead of tabs
set smarttab " use tabs at the start of a line, spaces elsewhere
" set nowrap " don't wrap text

" When started as "evim", evim.vim will already have done these settings.
if v:progname =~? "evim"
  finish
endif

set list " show invisible chars

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

if has("vms")
  set nobackup		" do not keep a backup file, use versions instead
else
  set backup		" keep a backup file
endif
set history=500		" keep 50 lines of command line history
set ruler		" show the cursor position all the time
set showcmd		" display incomplete commands
set noswapfile

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 06. Mapping                							                    "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Leader key
" let mapleader = ","
" Don't use Ex mode, use Q for formatting
map Q gq

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif

" Toggle the undo graph from Gundo
nnoremap <F5> :GundoToggle<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 07. Plugins                							                    "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" indent-guides
" let g:indent_guides_enable_on_vim_startup = 1 "default 0
" let g:indent_guides_guide_size = 0 "default 0, equal to shiftwidth
" let g:indent_guides_start_level = 1 "default 1
" let g:indent_guides_space_guides = 1 "default 1, consider space as indent



" Latex-Suite
let g:Tex_DefaultTargetFormat = 'pdf'
let g:Tex_MultipleCompileFormats='pdf, aux'"
" OPTIONAL
let g:tex_flavor='latex'
" """""""""""""""""""""
" vim-airline 

" Pathogen
execute pathogen#infect()


" Only do this part when compiled with support for autocommands.
if has("autocmd")


  " Put these in an autocmd group, so that we can delete them easily.
  augroup vimrcEx
  au!

  " For all text files set 'textwidth' to 78 characters.
  autocmd FileType text setlocal textwidth=78

  " When editing a file, always jump to the last known cursor position.
  " Don't do it when the position is invalid or when inside an event handler
  " (happens when dropping a file on gvim).
  " Also don't do it when the mark is in the first line, that is the default
  " position when opening a file.
  autocmd BufReadPost *
    \ if line("'\"") > 1 && line("'\"") <= line("$") |
    \   exe "normal! g`\"" |
    \ endif

  augroup END

else

  "set autoindent		" always set autoindenting on

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
		  \ | wincmd p | diffthis
endif

"

"
" Load custom settings [deprecated]
" source ~/.vim/custom/color.vim
" source ~/.vim/custom/font.vim
" source ~/.vim/custom/functions.vim
" source ~/.vim/custom/mappings.vim
" source ~/.vim/custom/settings.vim
" source ~/.vim/custom/plugins.vim
"
" IMPORTANT: win32 users will need to have 'shellslash' set so that latex
" can be called correctly.
set shellslash

" IMPORTANT: grep will sometims skip displaying the file name if you
" search in a single file. This will confuse Latex-Suite. Set your grep
" program to always generate a file-name.
set grepprg=grep\ -nH\ $*


" wombat256mod settings 
colorscheme wombat256mod 
set background=dark
hi Normal ctermbg=NONE " transparent background for vim
hi NonText ctermbg=NONE " end of line and unused space 
hi SpecialKey ctermbg=NONE " eg. listchars, tabs 
