""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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
    " 06. Plugins ..................... Vim plugin configuration        "
    " 07. Mapping ..................... Key mappings                    "
    " 08. Gvim ........................ GUI vim settings                "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" TODO """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" [ ] Auto folding                                                           "
" [ ] Showmatch for quotes                                                   "
" [ ] Auto re-align on save                                                  "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 01. General                                                                "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Get rid of Vi compatibility mode. SET FIRST!
set nocompatible

set encoding=utf-8
set title " change the terminal's title to [NAME] - VIM
" Hides buffers instead of closing them.
" This means that you can have unwritten changes to a file and open a new file
" using :e, without being forced to write or undo your changes first.
" Also, undo buffers and marks are preserved while the buffer is open
set hidden

" command line history, this need to set ~/.viminfo 's owner to $USER
set history=1000
" creat <FILE>.un~ file when editting, contain undo info
set undofile
set undolevels=1000

" In many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a
endif

" if has("vms")         " vms is an OS, Open Virtual Memory System
" 	set nobackup      " do not keep a backup file, use versions instead
" else
" 	set backup        " keep a backup file
" endif
set nobackup
set noswapfile

filetype off
" Pathogen settings
execute pathogen#infect()
Helptags " call :helptags on every dir in runtimepath

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 02. Events                                                                 "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" filetype detection[ON] plugin[ON] indent[ON]
filetype plugin indent on

if has("autocmd")
    " Automatic update .vimrc on the fly
    autocmd BufWritePost .vimrc source $MYVIMRC
endif

" Save when losing focus
autocmd FocusLost * :silent! wall

" Resize splits when the window is resized
autocmd VimResized * :wincmd =

" Save and restore folds
autocmd BufWinLeave ?* mkview
autocmd BufWinEnter ?* silent loadview " ?* handles vanila vim

" Make sure Vim returns to the same line when you reopen a file.
" When editing a file, always jump to the last known cursor position.
" Don't do it when the position is invalid or when inside an event handler
" (happens when dropping a file on gvim).
" Also don't do it when the mark is in the first line, that is the default
" position when opening a file.

augroup line_return
    au!
    au BufReadPost *
        \ if line("'\"") > 0 && line("'\"") <= line("$") |
        \     execute 'normal! g`"zvzz' |
        \ endif
augroup END

" FileType events
" ===============
" In Makefiles DO NOT use spaces instead of tabs
autocmd FileType make setlocal noexpandtab

" In vimrc, expandtab to spaces
autocmd FileType vim setlocal expandtab

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
else
augroup END
endif " has("autocmd")

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
  command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
  \ | wincmd p | diffthis
endif

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 03. Theme/Colors                                                           "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set t_Co=256 " enable 256-color mode.
" syntax highlighting[ON]
syntax on
" must put this before setting colorscheme otherwise it overwrites the theme

set background=dark
" wombat256mod settings
colorscheme wombat256mod
hi Normal ctermbg=none " transparent background for vim
hi NonText ctermbg=none ctermfg=gray " end of line char and unused space
hi SpecialKey ctermbg=none ctermfg=darkgray " eg. listchars, tabs
hi VertSplit ctermbg=none ctermfg=lightgray " for fillchars, boarder btw panes
hi ColorColumn ctermbg=32 " glowing blue
hi CursorLineNr cterm=bold ctermbg=none ctermfg=11 " bold yellow
hi CursorLine ctermbg=none
hi MatchParen cterm=bold ctermbg=none ctermfg=228
match ErrorMsg '\s\+$'
" hi ctermbg=236 " dark grey

" 04. Vim UI/Layout--------------------------------------------------------{{{
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 04. Vim UI/Layout                                                          "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Main UI settings
" ================
set laststatus=2 " last window always has a statusline
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

set wildmenu " commandline popup bar
set wildmode=full " commandline popup bar style, show all choice in a line

set fillchars=fold:\ ,vert:\|
" vert = bolder character btw panes
" fold = folded chunck of code, the char in the first line
set number " show line numbers
set relativenumber " show line numbers relative to the current line

set cursorline " highlight current line
set scrolloff=4 " keep 4 lines off the edges of the screen when scrolling
set textwidth=78
set colorcolumn=+1 " = textwidth + 1

" Search settings
" ===============
set hlsearch " set nohlsearch " Don't continue to highlight searched phrases.
set incsearch " But do highlight as you type your search.
set ignorecase " Make searches case-insensitive.
set smartcase " ignore case if search pattern is all lowercase, sensitive otherwise
" set gdefault " omit /g in regex

" Paranthesis settings
" ====================
set showmatch " Show matching parenthesis
set matchpairs=(:),{:},[:],<:> " ,':',":"
" }}}

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 05. Text Font/Formatting                                                   "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Whitespace settings
" ========================
set list
" extends and precedes are the chars when window squeezes and set nowrap,
" these chars indicating there's more text on the line
set listchars=eol:¬,tab:┆\ ,trail:·,extends:>,precedes:<

function! <SID>StripTrailingWhitespaces()
    " Preparation: save last search, and cursor position.
    let _s=@/
    let l = line(".")
    let c = col(".")
    " Do the business:
    %s/\s\+$//e
    " Clean up: restore previous search history, and cursor position
    let @/=_s
    call cursor(l, c)
endfunction

autocmd BufWritePre * :call <SID>StripTrailingWhitespaces()

" Wrap settings
" =============
set wrap

" " Soft wrapping text settings
" set wrap " vim by default breaks a new line within a word
" set linebreak " use linebreak to disable breaking within a word
" " However, linebreak won't work if set wrap is off or set list is on
" " In short: set wrap linebreak nolist
" " If set nonumber, then showbreak can be used to indicate wrapped lines
" set showbreak=…

" Hard wrapping text settings (use gq and gw, see mapping section)
" There's 2 options to configure hard wrapping, textwidth(tw) and
" wrapmargin(wm)
" 1. textwidth when set to 0, use max{screen width, 79}
"    textwidth is set in the UI section.
" set textwidth=78
" 2. wrapmargin is to solve the screen width less than 80, but it only works
"    when 'set textwidth=0'. the final wrapping width = screen width -
"    wrapmargin, regardless of how big the screen is. wrapmargin is used to
"    compensate the width if 'set number' is on.
" set wrapmargin=5

" When formatoptions = empty, it does not autoformat at all until gq or gw
" 'a': autoformat when inserting text
" 'n': recognize numbered lists
" '1': don't end lines with 1-letter words
" When 'a' is on, better turn off 'r', and 'o', otherwise pressing <CR> or 'o'
" or 'O' will always re-format paragraph, which means you can't insert newline
" normaly. However, leave the 'c' flag on, this only happens for recognized
" comments.
" When 'a' is on, also turn 'w' on,so that a non-white char ends a paragraph.
" see ':help fo-table'
set formatoptions=tcqn1 "aw, this messes with gq and gw..not good

" use par to outsource formating when using gq
" -r: handle empty lines to format as well, repeat chars in bodiless lines
" -q: handle nested indentation and quotations
" -e: remove superflous empty lines
" -w: width, default to 72. if given w/o a number, w = 79
set formatprg=par\ -rqw\ 78


" allow backspacing over everything in insert mode
set backspace=indent,eol,start

" TAB settings
" ============
set tabstop=4 " tab = 4 columns
set softtabstop=0 " how many columns when hit Tab in insert mode, 0 uses tabstop
set shiftwidth=4 " indent/outdent for reindent operations (<< and >>)
set shiftround " always indent/outdent to the nearest tabstop, (multiples of 4)
set noexpandtab " do not use spaces instead of tabs
set smarttab " use shftwidth at the start of a line

" Indentation settings
" ====================
set autoindent " auto-indent
set copyindent
set cindent " set c-style indent
set cinoptions=(0,u0,U0
" int f(int x,
"       int y)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 06. Mapping                                                                "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Leader key, default is fine
" let mapleader = ","

" Insert mode
" ===========
" imitating shell operations
inoremap <C-A> <Esc>^i
inoremap <C-E> <End>
inoremap <C-B> <Left>
inoremap <C-F> <Right>
" <C-H> backspace <BS>
" <C-D> default del indent, use <C-H> instead
inoremap <C-D> <Del>
inoremap <C-K> <Esc>l<S-C>
" <C-W> delete last word
" <C-U> delete till begining of current line
" Use <C-G>+u to first break undo, so the insertion consists of more than a
" single modification. Use u to undo.
inoremap <C-U> <C-G>u<C-U>
inoremap <C-W> <C-G>u<C-W>
" <C-I> <Tab>
" <C-J> <NL> different from <CR>
" <C-M> <CR>
" <C-R> registers
" <C-E> insert char which is below the cursor..this is stupid
" <C-Y> insert char which is above the cursor..this is stupid

" Command mode
" ============
" <C-B> <Home> by default
cnoremap <C-A> <Home>
" <C-E> <End> by default
cnoremap <C-B> <Left>
cnoremap <C-F> <Right>
cnoremap <C-D> <Del>
" <C-D> by default is command-line completion
" <C-H> <BS>
" <C-W> delete last word
" <C-U> delete till beginning of current line
" cnoremap <C-K> delete till end of current line
" <C-J> <NL> = <CR>
" <C-M> <CR>
" <C-I> <Tab>
" <C-R> registers
" cnoremap <C-T> swap cursor's last 2 letters

" Search mode
" ===========
" use Perl/Python regex instead of Vim's regex
nnoremap / /\v
vnoremap / /\v

" Normal mode
" ===========
" swap : and ;
nnoremap ; :
nnoremap : ;
xnoremap ; :
xnoremap : ;

" UI panels
" =========
" Disabling default <F1> to invoke help, use :h instead
map <F1> <Nop>
imap <F1> <Nop>


" Don't use Ex mode, use Q for formatting hard wrapping
" gq moves cursor to the last line, eg. gqip (gq in paragraph)
" gw keeps cursor at the same place eg. gwip
" gq uses external format program if there is one, gw uses vim internal format
" Vim's internal formatting uses a greedy algorithm
" nnoremap Q gq
" nnoremap gw <Esc>set formatoptions-=w<CR>gw<Esc>set formatoptions+=w<CR>

" Navigation
" ==========
" cursor stays at current indentation when inserting new lines, either <CR> or O
" This is overridden by Smart-tabs
inoremap <CR> <CR>x<BS>
nnoremap o ox<BS>
nnoremap O Ox<BS>

noremap j gj
noremap k gk
noremap gj j
noremap gk k

" Quick navigation to home/end of line
noremap H ^
noremap L $
vnoremap L g_

" select the last changed or pasted text
nnoremap <expr> gp '`[' . strpart(getregtype(), 0, 1) . '`]<BS>'
" nnoremap <expr> gp '`[' . getregtype()[0] . '`]'

" Splits switching
" ================
" Meta-keys are mapped as <Esc> + key, this may exit to normal mode
nnoremap h <C-W>h
nnoremap j <C-W>j
nnoremap k <C-W>k
nnoremap l <C-W>l
" Fix meta-keys that break out of Insert mode
" http://vim.wikia.com/wiki/VimTip738


" command line window, type into the window instead of using command line
" This is awkward.
" nnoremap : q:i
" nnoremap / q/i
" nnoremap ? q?i

" Plugin mappings
" ===============
" Toggle Gundo
autocmd VimEnter * nnoremap <F6> :GundoToggle<CR>
autocmd VimEnter * inoremap <F6> <Esc>:GundoToggle<CR>

" Toggle NERDTree
autocmd VimEnter * nnoremap <F3> :NERDTreeToggle<CR>

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 07. Plugins                                                                "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
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


" Ultisnips
" =========
let g:UltiSnipsExpandTrigger="<space>"
let g:UltiSnipsListSnippets="<Leader>ls" "this invokes quickfix to list all choices
" <c-tab> only works in Gvim, cuz <c-tab> won't be sent into the terminal
" <tab> is rendered as Ctrl-I, so <c-tab> is rendered as Ctrl-Ctrl-I. which is impossible
let g:UltiSnipsJumpForwardTrigger="<c-j>"
let g:UltiSnipsJumpBackwardTrigger="<c-k>"
" ${VISUAL} mode of UltiSnips. Trying to put everything in register " into
" UltiSnips_SaveLastVisualSelection()
xnoremap x :call UltiSnips_SaveLastVisualSelection()<CR>gvx
xnoremap d :call UltiSnips_SaveLastVisualSelection()<CR>gvd
xnoremap s :call UltiSnips_SaveLastVisualSelection()<CR>gvs

let g:UltiSnipsEditSplit = 'vertical'
autocmd BufEnter *.rails UltiSnipsAddFiletypes rails.ruby
" Priority rails -> ruby -> all

" :call UltisnipsEdit will open the following dir
let g:UltiSnipsSnippetsDir="~/.vim/snippets"
" Default snippets, do not use Ultisnips' snippets
let g:UltiSnipsSnippetDirectories=["snippets"]

" Space mapping func, if there's drop-down list, use <Space> to expand
function! g:Space_Mapping()
    call UltiSnips_ExpandSnippet() "This returns g:ulti_expand_res
    if g:ulti_expand_res == 0
        return "\<Space>"
    else
        return ""
    endif
endfunction

autocmd BufEnter * inoremap <silent> <Space> <C-R>=g:Space_Mapping()<CR>

" YouCompleteMe(YCM)
" ==================
" Unmap <Tab> from iterating drop-down list
let g:ycm_key_list_select_completion = ['<TAB>', '<Down>'] "deafult += <TAB>

" Map <Tab>, if drop-down list, then <C-N>, else use smart tabs
" autocmd BufEnter * inoremap <expr> <Tab> pumvisible() ? "\<C-n>" : "\<C-R>=<SNR>38_InsertSmartTab()\<CR>"

" Do not make YCM register the default syntastic check for c, cpp, objc,objcpp
" let g:ycm_register_as_syntastic_checker = 0 " default 1
let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/youcompleteme/cpp/ycm/.ycm_extra_conf.py'

" Syntastic
" =========
" Check syntax on both loading and saving buffers
let g:syntastic_check_on_open = 1
" " Run all checkers combined one by one, and label checker id to errors.
" let g:syntastic_aggregate_errors = 1 " default 1
" let g:syntastic_id_checkers = 1 " default 1
" Use :sign interface (the panel left to line numbers) to mark syntax errors
let g:syntastic_enable_signs = 1 "default 1
" Syntax and style errors
let g:syntastic_error_symbol = '✗' " default '>>'
" let g:syntastic_style_error_symbol = '✗'
let g:syntastic_warning_symbol = '⚠' " default '>>'
" let g:syntastic_style_warning_symbol = '⚠'
" Display error msg in ballon when mouse hovers, need vim +ballon_eval
" let g:syntastic_enable_balloons = 1 " default 1
" Update location-list when run checkers, by default use :Errors
let g:syntastic_always_populate_loc_list = 1 " default 0
" " Auto jump to the first detected error when saving or opening a file
" let g:syntastic_auto_jump = 1 " default 0
" Error window auto open when errors detected, and auto close when no errors
let g:syntastic_auto_loc_list = 1 " deafault 2
" " Height of location-list
" let g:syntastic_loc_list_height = 5 " default 10
" " Never check these ignore files
" let g: syntastic_ignore_files
" let g:syntastic_c_checkers = ['gcc'] " default 'ycm' is fine
" let g:syntastic_haskell_checkers = ['ghc-mod','hlint'] " default have both
" use cabal install ghc-mod

" Custom settings (deprecated)
" ============================
" source ~/.vim/custom/color.vim
" source ~/.vim/custom/font.vim
" source ~/.vim/custom/functions.vim
" source ~/.vim/custom/mappings.vim
" source ~/.vim/custom/settings.vim
" source ~/.vim/custom/plugins.vim

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" 08. Gvim Settings                                                          "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("gui_running")
    set guifont=Ubuntu\ Mono\ derivative\ Powerline\ 12
endif

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")
" hi Overlength
" may use if has("gui_running") to config
" highlight OverLength ctermbg=red ctermfg=white guibg=#592929
" match OverLength /\%81v.\+/
