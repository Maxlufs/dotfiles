"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Filename: .vimrc                                                  "
    " Maintainer: Maximilian Q. Wang <maxlufs@gmail.com>                "
    " URL: https://github.com/Maxlufs/dotfiles.git                      "
    """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
    " Contents:                                                         "
    " 00. Researved ...................                                 "
    " 01. General ..................... General Vim behavior            "
    " 02. Events ...................... Vim autocmd events              "
    " 03. Theme/Colors ................ Colors, fonts, etc.             "
    " 04. Vim UI/Layout ............... User interface behavior         "
    " 05. Text Formatting ............. Text, tab, indentation related  "
    " 05. Mapping ..................... Key mappings                    "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""


"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 01. General                                                               "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" get rid of Vi compatibility mode. SET FIRST!
set nocompatible

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" Pathogen settings
execute pathogen#infect()
Helptags " call :helptags on every dir in runtimepath

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 02. Events                                                                "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" filetype detection[ON] plugin[ON] indent[ON]
filetype plugin indent on

" Automatic update .vimrc on the fly
if has("autocmd")
    autocmd bufwritepost .vimrc source $MYVIMRC
endif


" In Makefiles DO NOT use spaces instead of tabs
autocmd FileType make setlocal noexpandtab

" In Ruby files, use 2 spaces instead of 4 for tabs
" autocmd FileType ruby setlocal sw=2 ts=2 sts=2

" Enable omnicompletion (to use, hold Ctrl+X then Ctrl+O while in Insert mode.
" set ofu=syntaxcomplete#Complete

" " Prettify JSON files
" autocmd BufRead,BufNewFile *.json set filetype=json
" autocmd Syntax json sou ~/.vim/syntax/json.vim
"
" " Prettify Vagrantfile
" autocmd BufRead,BufNewFile Vagrantfile set filetype=ruby

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

endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
  \ | wincmd p | diffthis
endif
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 03. Theme/Colors                                                          "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set t_Co=256 " enable 256-color mode.
" syntax highlighting[ON]
syntax on
" must put this before setting colorscheme otherwise it overwrites the theme

" wombat256mod settings
set background=dark
colorscheme wombat256mod
hi Normal ctermbg=none " transparent background for vim
hi NonText ctermbg=none ctermfg=gray " end of line char and unused space
hi SpecialKey ctermbg=none ctermfg=darkgray " eg. listchars, tabs
hi VertSplit ctermbg=none ctermfg=lightgray " for fillchars, boarder btw panes
hi ColorColumn ctermbg=32 " glowing blue
hi CursorLineNr cterm=bold ctermbg=none ctermfg=11 " bold yellow
hi CursorLine ctermbg=none
hi MatchParen cterm=bold ctermbg=none ctermfg=228
" hi ctermbg=236 " dark grey
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 04. Vim UI/Layout                                                         "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set textwidth=78
set colorcolumn=+1

set number " show line numbers
set cursorline " highlight current line
set laststatus=2 " last window always has a statusline
set hlsearch
" set nohlsearch " Don't continue to highlight searched phrases.
set incsearch " But do highlight as you type your search.
set ignorecase " Make searches case-insensitive.

set showmatch " Show matching parenthesis

set fillchars=fold:\ ,vert:\|
" vert = bolder character btw panes
" fold = folded chunck of code, the char in the first line


" Highlight characters that go over 80 columns, works only for gvim
" may use if has("gui_running") to config
" highlight OverLength ctermbg=red ctermfg=white guibg=#592929
" match OverLength /\%81v.\+/
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 05. Text Font/Formatting                                                  "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" General settings
set history=500     " keep 50 lines of command line history
set wrap " wrap text

set noshowmode " use vim-airline plugin to handle this
set showcmd
set noruler    " use vim-airline plugin to handle this
" +-------------------------------------------------+
" |text in the Vim window                           |
" |~                                                |
" |~                                                |
" |-- VISUAL --                   2f     43,8   17% |
" +-------------------------------------------------+
"  ^^^^^^^^^^^^                ^^^^^^^^^ ^^^^^^^^^^^^
"   'showmode'                 'showcmd'   'ruler'

set list " show invisible chars
set listchars=eol:¬,tab:┆\ ,trail:·,extends:>,precedes:<

" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" TAB settings
set tabstop=4 " tab columns
set softtabstop=0 " how many columns when hit Tab in insert mode, unify this
set shiftwidth=4 " indent/outdent for reindent operations (<< and >>)
set shiftround " always indent/outdent to the nearest tabstop
set noexpandtab " do not use spaces instead of tabs
set smarttab " use shftwidth at the start of a line

" indentation
set autoindent " auto-indent
set copyindent
set cindent " set c-style indent
set cinoptions=(0,u0,U0
" int f(int x,
"       int y)

if has("vms")       " vms is an OS, Open Virtual Memory System
  set nobackup      " do not keep a backup file, use versions instead
else
  set backup        " keep a backup file
endif
set noswapfile

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 06. Mapping                                                               "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Leader key, default is fine
" let mapleader = ","
" Don't use Ex mode, use Q for formatting hard returns
map Q gq

" Navigation
" cursor stays at current position when inserting new lines, either <CR> or O
inoremap <CR> <CR>x<BS>
nnoremap o ox<BS>
nnoremap O Ox<BS>

nmap j gj
nmap k gk

" CTRL-U in insert mode deletes a lot.  Use CTRL-G u to first break undo,
" so that you can undo CTRL-U after inserting a line break.
inoremap <C-U> <C-G>u<C-U>


" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.

" Plugin mappings
" Toggle the undo graph from Gundo
nnoremap <F5> :GundoToggle<CR>

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 07. Plugins                                                               "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" indent-guides (deprecated)
" ==========================
" let g:indent_guides_enable_on_vim_startup = 1 "default 0
" let g:indent_guides_guide_size = 0 "default 0, equal to shiftwidth
" let g:indent_guides_start_level = 1 "default 1
" let g:indent_guides_space_guides = 1 "default 1, consider space as indent

" Latex-Suite
" ===========
let g:Tex_DefaultTargetFormat = 'pdf'
let g:Tex_MultipleCompileFormats='pdf, aux'"
" OPTIONAL
let g:tex_flavor='latex'
" IMPORTANT: win32 users will need to have 'shellslash' set so that latex can
" be called correctly.
set shellslash
" IMPORTANT: grep will sometims skip displaying the file name if you search in
" a single file. This will confuse Latex-Suite. Set your grep program to
" always generate a file-name.
set grepprg=grep\ -nH\ $*

" vim-airline
" ===========
let g:airline_powerline_fonts = 1
" use powerline bespoke fonts to print our little triangles on the bar

"
" Load custom settings (deprecated)
" source ~/.vim/custom/color.vim
" source ~/.vim/custom/font.vim
" source ~/.vim/custom/functions.vim
" source ~/.vim/custom/mappings.vim
" source ~/.vim/custom/settings.vim
" source ~/.vim/custom/plugins.vim
"
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 08. Gvim Settings                                                         "
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" if has("gui_running")
" set guifont = Ubuntu\ Mono\ derivative\ Powerline.ttf

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")
