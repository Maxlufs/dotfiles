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
    " 08. Command ..................... User-defined commands           "
    " 09. Gvim ........................ GUI vim settings                "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" TODO """""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" [ ] Auto folding                                                           "
" [ ] Folding formats                                                        "
" [ ] Plugin: detect encoding, eg. Chinese from windows                      "
" [ ] Showmatch for quotes, might not be possible...                         "
" [ ] Auto re-align on save                                                  "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                 01.General                                 "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" get rid of vi compatibility mode. set first!
set nocompatible

set encoding=utf-8

" in xterm change the terminal's title to filename full path
" in screen change the terminal's title to filename full path, but tab title
" to filename only
let &titlestring = expand("%:p")
if &term =~ "screen"
let &titlestring = expand("%:t")
	set t_ts=k
	set t_fs=\
endif
if &term =~ "screen" || &term =~ "xterm"
		set title
endif

" There is a problem of screen, on exit vim, the title won't be restored
"function! ResetTitle()
	"" disable vim's ability to set the title
	"exec "set title t_ts='' t_fs=''"

	"" and restore it to 'bash'
	"exec ":!echo -e '\033kbash\033\\'\<CR>"
"endfunction

"au VimLeave * silent call ResetTitle()

" hides buffers instead of closing them.
" this means that you can have unwritten changes to a file and open a new file
" using :e, without being forced to write or undo your changes first.
" also, undo buffers and marks are preserved while the buffer is open
set hidden

" command line history, this need to set ~/.viminfo 's owner to $user
set history=1000
" creat <file>.un~ file when editting, contain undo info
set undofile
set undolevels=1000

" mouse behavior
" ==============
" in many terminal emulators the mouse works just fine, thus enable it.
if has('mouse')
  set mouse=a       " normal+visual+insert+command-line
  set ttymouse=xterm
  set ttyfast
  set mousehide     " default on, hide mouse when type
endif

" if has("vms")         " vms is an os, open virtual memory system
" 	set nobackup      " do not keep a backup file, use versions instead
" else
" 	set backup        " keep a backup file
" endif
set nobackup
set noswapfile

filetype off

" Pathogen settings
"execute pathogen#infect()
"Helptags " call :helptags on every dir in runtimepath

" Vundle settings
"" add vundle to runtimepath
"set rtp+=~/.vim/bundle/Vundle.vim
"call vundle#begin()
"source $HOME/.vimrc_vundle
"call vundle#end()

" Plug settings
if empty(glob('~/.vim/autoload/plug.vim'))
  silent !curl -fLo ~/.vim/autoload/plug.vim --create-dirs
    \ https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
  autocmd VimEnter * PlugInstall --sync | source $MYVIMRC
endif
call plug#begin('~/.vim/plugged')
source $HOME/.vimrc_plug
call plug#end()

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                 02. Events                                 "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" filetype detection[ON] plugin[ON] indent[ON]
filetype plugin indent on

if has("autocmd")
  " Automatic update .vimrc on the fly
  " autocmd BufWritePost .vimrc source $MYVIMRC
  " \= -> 0 or 1, match vimrc whether it's hidden or not
endif

" Save (write all) when losing focus
autocmd FocusLost * :silent! wall

" Resize splits when the window is resized
autocmd VimResized * :wincmd =

"" Save and restore folds
"" use vim-scripts/restore_view plugin to handle
"autocmd BufWinLeave ?* mkview
"autocmd BufWinEnter ?* silent loadview " ?* handles vanila vim

"" Solves the problem of switching between buffers and screen moves, this
"" snippets saves the cursor position after buffer switches
"" http://vim.wikia.com/wiki/Avoid_scrolling_when_switch_buffers
"" Save current view settings on a per-window, per-buffer basis.
function! AutoSaveWinView()
    if !exists("w:SavedBufView")
        let w:SavedBufView = {}
    endif
    let w:SavedBufView[bufnr("%")] = winsaveview()
endfunction

" Restore current view settings.
function! AutoRestoreWinView()
    let buf = bufnr("%")
    if exists("w:SavedBufView") && has_key(w:SavedBufView, buf)
        let v = winsaveview()
        let atStartOfFile = v.lnum == 1 && v.col == 0
        if atStartOfFile && !&diff
            call winrestview(w:SavedBufView[buf])
        endif
        unlet w:SavedBufView[buf]
    endif
endfunction

" When switching buffers, preserve window view.
if v:version >= 700
    autocmd BufLeave * call AutoSaveWinView()
    autocmd BufEnter * call AutoRestoreWinView()
endif

"" Make sure Vim returns to the same line when you reopen a file.
"" When editing a file, always jump to the last known cursor position.
"" Don't do it when the position is invalid or when inside an event handler
"" (happens when dropping a file on gvim).
"" Also don't do it when the mark is in the first line, that is the default
"" position when opening a file.

"augroup line_return
  "au!
  "au BufReadPost *
        "\ if line("'\"") > 0 && line("'\"") <= line("$") |
        "\     execute 'normal! g`"zvzz' |
        "\ endif
"augroup END

" FileType events
" ===============

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

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                             03. Color / Theme                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if $TERM == "xterm-256color" || $TERM == "screen-256color" || $COLORTERM == "gnome-terminal"
	set t_Co=256 " enable 256-color mode.
endif
" syntax highlighting[ON]
syntax on
" must put this before setting colorscheme otherwise it overwrites the theme
" render syntax highlighting from the start of buffer, this fixes some js
" embedded html renders wrong
"autocmd BufEnter * :syntax sync fromstart
autocmd BufEnter * :syntax sync minlines=1000

set background=dark
" enable italic font
set t_ZH=[3m
set t_ZR=[23m

if &t_Co == 256
	colorscheme wombat256mod
else
	colorscheme wombat
endif

" wombat256mod settings
if g:colors_name == "wombat256mod"
	" transparentize background for vim
	hi Normal                ctermbg=none
	" end of line char and unused space
	hi NonText               ctermbg=none     ctermfg=gray
	" eg. listchars, tabs
	hi SpecialKey            ctermbg=none     ctermfg=darkgray
	" for fillchars, boarder btw panes
	hi VertSplit             ctermbg=none     ctermfg=lightgray
	" set colorcolumn color: glowing blue
	hi ColorColumn           ctermbg=32
	" transparentize background for seach results
	hi Search                ctermbg=none     ctermfg=207
	hi SignColumn            ctermbg=235
	hi GitGutterAdd          ctermbg=235      ctermfg=2
	hi GitGutterChange       ctermbg=235      ctermfg=3
	hi GitGutterDelete       ctermbg=235      ctermfg=1
	hi GitGutterChangeDelete ctermbg=235      ctermfg=13
	hi CursorLineNr          cterm=bold       ctermbg=none          ctermfg=11
	hi CursorLine            ctermbg=none
	hi MatchParen            cterm=bold       ctermbg=none ctermfg=207
	hi Visual                ctermfg=226 ctermbg=235
	hi Comment               cterm=italic
	match ErrorMsg '\s\+$' "Highlight trailing white spaces
endif
" jellybeans settings
if g:colors_name == "jellybeans"
	hi Normal                ctermbg=none
	hi NonText               ctermbg=none     ctermfg=gray
	hi SpecialKey            ctermbg=none     ctermfg=darkgray
	hi VertSplit             ctermbg=none     ctermfg=lightgray
	hi ColorColumn           ctermbg=1
	hi Search                ctermbg=none
	hi CursorLineNr          cterm=bold       ctermbg=none          ctermfg=11
	hi CursorLine            ctermbg=none
endif

"hi DiffAdd        ctermfg=NONE ctermbg=24 guifg=#f8f8f2 guibg=#13354a
"hi DiffChange     term=bold ctermbg=238 guifg=#89807d guibg=#4c4745
"hi DiffDelete     ctermfg=125 ctermbg=125 guifg=#960050 guibg=#1e0010
"hi DiffText       term=reverse cterm=bold ctermfg=0 ctermbg=202 gui=bold guifg=#ad81ff guibg=#4a7800
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                               04. UI Layout                                "
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
" vert = bolder character between panes
" fold = folded chunck of code, the char in the first line

" vim 7.4 only, show both current line number and relative line number
set number " show line numbers
set relativenumber " show line numbers relative to the current line

set cursorline " highlight current line
set scrolloff=4 " keep 4 lines off the edges of the screen when scrolling
"set sidescrolloff=5 " this only words if nowrap is set
set scrolljump=1 " jump 1 line when scroll to edge of screen, 1 line is smooth
set textwidth=78
set colorcolumn=+1 " = textwidth + 1

" Splits settings
" ===============
set splitright " open new vsp on right
" set splitbelow " open new sp below
" set diffopt+=vertical "set vertical splits for gitdiff or fugitive
" also use :Gvdiff to use vertical splits in fugitive

" Search settings
" ===============
set hlsearch " set nohlsearch " Don't continue to highlight searched phrases.
set incsearch " But do highlight as you type your search.
set ignorecase " Make searches case-insensitive.
set smartcase " ignore case if search pattern is all lowercase, sensitive otherwise
" set gdefault " omit /g in regex

" Paranthesis highlight settings
" ==============================
set showmatch " Show matching parenthesis
set matchpairs=(:),{:},[:],<:> " ,':',":"
" }}}

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                       05. Text Behavior / Formatting                       "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Whitespace settings
" ========================
set list
" extends and precedes are the chars when window squeezes and set nowrap,
" these chars indicating there's more text on the line
set listchars=eol:¬,tab:┆\ ,trail:•,extends:>,precedes:<
" nbsp:+, what's nbsp mean here?

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

" Wrap (text) settings
" ====================
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
set formatprg=par\ -rqw\ &textwidth


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
" TODO: use editorconfig settings to handle tabs
" The settings here are for defaults
autocmd FileType html setlocal tabstop=2 shiftwidth=2
autocmd FileType javascript setlocal tabstop=2 shiftwidth=2 expandtab
autocmd FileType make setlocal noexpandtab
" In vimrc, expandtab to spaces
"autocmd FileType vim setlocal expandtab
if has("autocmd")
	" Put these in an autocmd group, so that we can delete them easily.
	augroup vimrcEx
		au!
		" For all text files set 'textwidth' to 78 characters.
		autocmd FileType text setlocal textwidth=78
	augroup END
endif " has("autocmd")

" Indentation settings
" ====================
set autoindent " use indent from the previous line
set smartindent " like autoindent, also recognizes some C syntax
set copyindent
autocmd FileType c,cpp set cindent " set c-style indent
autocmd FileType c,cpp set cinoptions=(0,u0,U0
" if type '(' as the first char in a line
" int f(int x,
"       int y)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                06. Mapping                                 "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Leader key, default is fine
" let mapleader = ","
let mapleader = "\<Space>"

" g-prefix normally requirs a {motion}
" eg. by default, gu, gU, g~
" g> => >
" g< => <
" also :[range]< and :[range]> might need u/U/~ counterpart

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


" Command mode (emacs mode, copied from 'houtsnip/vim-emacscommandline')
" ======================================================================
cnoremap <C-A> <Home>
" <C-A> by default inserts all suggestions in front of the cursor, very wierd
" <C-E> <End> by default
cnoremap <C-B> <Left>
" <C-B> <Home> by default
cnoremap <C-F> <Right>
" <C-F> by default opens command window, same as q: or q/ or q?
" <C-P> <C-N> by default works great

" map <M-F> to forward word
cnoremap <Esc>f <S-Right>
cmap <M-F> <Esc>f
" map <M-B> to backward word
cnoremap <Esc>b <S-Left>
cmap <M-B> <Esc>b

cnoremap <C-D> <Del>
" <C-D> by default is command-line completion, prints suggestion in new line, use tab instead
" <C-H> <BS> by default

" <C-W> delete till last space by default, add history support
cnoremap <C-W> <C-\>e<SID>DeleteBackwardsToWhiteSpace()<CR>
function! <SID>DeleteBackwardsToWhiteSpace()
	call <SID>saveUndoHistory(getcmdline(), getcmdpos())
	let l:loc = strpart(getcmdline(), 0, getcmdpos() - 1)
	let l:roc = strpart(getcmdline(), getcmdpos() - 1)
	if (l:loc =~ '\v\S\s*$')
		let l:rem = matchstr(l:loc, '\v\S+\s*$')
	elseif (l:loc =~ '\v^\s+$')
		let @c = l:loc
		call setcmdpos(1)
		return l:roc
	else
		return getcmdline()
	endif
	let @c = l:rem
	let l:pos = getcmdpos() - strlen(l:rem)
	let l:ret = strpart(l:loc, 0, strlen(l:loc) - strlen(l:rem)) . l:roc
	call <SID>saveUndoHistory(l:ret, l:pos)
	call setcmdpos(l:pos)
	return l:ret
endfunction

" map <M-BS> to delete last word, add history support
cnoremap <Esc><BS> <C-\>e<SID>BackwardKillWord()<CR>
cmap <M-BS> <Esc><BS>
function! <SID>BackwardKillWord()
	" Do same as in-built Ctrl-W, except assign deleted text to @c
	call <SID>saveUndoHistory(getcmdline(), getcmdpos())
	let l:loc = strpart(getcmdline(), 0, getcmdpos() - 1)
	let l:roc = strpart(getcmdline(), getcmdpos() - 1)
	if (l:loc =~ '\v\w\s*$')
		let l:rem = matchstr(l:loc, '\v\w+\s*$')
	elseif (l:loc =~ '\v[^[:alnum:]_[:blank:]]\s*$')
		let l:rem = matchstr(l:loc, '\v[^[:alnum:]_[:blank:]]+\s*$')
	elseif (l:loc =~ '\v^\s+$')
		let @c = l:loc
		call setcmdpos(1)
		return l:roc
	else
		return getcmdline()
	endif
	let @c = l:rem
	let l:pos = getcmdpos() - strlen(l:rem)
	let l:ret = strpart(l:loc, 0, strlen(l:loc) - strlen(l:rem)) . l:roc
	call <SID>saveUndoHistory(l:ret, l:pos)
	call setcmdpos(l:pos)
	return l:ret
endfunction

" map <M-D> to delete next word, add history support
cnoremap <Esc>d <C-\>e<SID>KillWord()<CR>
cmap <M-D> <Esc>d
function! <SID>KillWord()
	call <SID>saveUndoHistory(getcmdline(), getcmdpos())
	let l:loc = strpart(getcmdline(), 0, getcmdpos() - 1)
	let l:roc = strpart(getcmdline(), getcmdpos() - 1)
	if (l:roc =~ '\v^\s*\w')
		let l:rem = matchstr(l:roc, '\v^\s*\w+')
	elseif (l:roc =~ '\v^\s*[^[:alnum:]_[:blank:]]')
		let l:rem = matchstr(l:roc, '\v^\s*[^[:alnum:]_[:blank:]]+')
	elseif (l:roc =~ '\v^\s+$')
		let @c = l:roc
		return l:loc
	else
		return getcmdline()
	endif
	let @c = l:rem
	let l:ret = l:loc . strpart(l:roc, strlen(l:rem))
	call <SID>saveUndoHistory(l:ret, getcmdpos())
	return l:ret
endfunction

"cnoremap <C-Z> <C-\>e<SID>ToggleExternalCommand()<CR>
"function! <SID>ToggleExternalCommand()
"let l:cmd = getcmdline()
"if ('!' == strpart(l:cmd, 0, 1))
"call setcmdpos(getcmdpos() - 1)
"return strpart(l:cmd, 1)
"else
"call setcmdpos(getcmdpos() + 1)
"return '!' . l:cmd
"endif
"endfunction

" <C-U> delete till beginning of current line by default, add history support
cnoremap <C-U> <C-\>e<SID>BackwardKillLine()<CR>
function! <SID>BackwardKillLine()
	call <SID>saveUndoHistory(getcmdline(), getcmdpos())
	let l:cmd = getcmdline()
	let l:rem = strpart(l:cmd, 0, getcmdpos() - 1)
	if ('' != l:rem)
		let @c = l:rem
	endif
	let l:ret = strpart(l:cmd, getcmdpos() - 1)
	call <SID>saveUndoHistory(l:ret, 1)
	call setcmdpos(1)
	return l:ret
endfunction

" <C-K> invokes digraphs by default, eg. print special ascii or japanese, see :dig
" map <C-K> to delete till end of current line, add history support
cnoremap <C-K> <C-\>e<SID>KillLine()<CR>
function! <SID>KillLine()
	call <SID>saveUndoHistory(getcmdline(), getcmdpos())
	let l:cmd = getcmdline()
	let l:rem = strpart(l:cmd, getcmdpos() - 1)
	if ('' != l:rem)
		let @c = l:rem
	endif
	let l:ret = strpart(l:cmd, 0, getcmdpos() - 1)
	call <SID>saveUndoHistory(l:ret, getcmdpos())
	return l:ret
endfunction

" <C-Y> by default copy modeless selection, or enter literl C-Y if none, not working?
" map <C-Y> to yank deleted text by <C-W> <M-D> <C-U> <C-K>
cnoremap <C-Y> <C-\>e<SID>Yank()<CR>
function! <SID>Yank()
	let l:cmd = getcmdline()
	call setcmdpos(getcmdpos() + strlen(@c))
	return strpart(l:cmd, 0, getcmdpos() - 1) . @c . strpart(l:cmd, getcmdpos() - 1)
endfunction

let s:oldcmdline = [ ]
function! <SID>saveUndoHistory(cmdline, cmdpos)
	if len(s:oldcmdline) == 0 || a:cmdline != s:oldcmdline[0][0]
		call insert(s:oldcmdline, [ a:cmdline, a:cmdpos ], 0)
	else
		let s:oldcmdline[0][1] = a:cmdpos
	endif
	if len(s:oldcmdline) > 100
		call remove(s:oldcmdline, 100)
	endif
endfunction

" map <C-X><C-U> to undo
cnoremap <C-_> <C-\>e<SID>Undo()<CR>
cmap <C-X><C-U> <C-_>
function! <SID>Undo()
	if len(s:oldcmdline) == 0
		return getcmdline()
	endif
	if getcmdline() == s:oldcmdline[0][0]
		call remove(s:oldcmdline, 0)
		if len(s:oldcmdline) == 0
			return getcmdline()
		endif
	endif
	let l:ret = s:oldcmdline[0][0]
	call setcmdpos(s:oldcmdline[0][1])
	call remove(s:oldcmdline, 0)
	return l:ret
endfunction

" <C-J> <NL> = <CR> by default
" <C-M> <CR> by default
" <C-I> <Tab> by default
" <C-R> registers by default, use q: in normal mode to invoke history
" TODO cnoremap <C-T> swap cursor's last 2 letters

" Search mode
" ===========
" use Perl/Python regex instead of Vim's regex
nnoremap / /\v
vnoremap / /\v
noremap <Leader>q :set hlsearch!<CR>

" Normal mode
" ===========
" swap : and ;
nnoremap ; :
nnoremap : ;
xnoremap ; :
xnoremap : ;
noremap <Leader>p :set paste!<CR>
set pastetoggle=<F10>

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

" gf = goto file, open file under cursor in current window
" CTRL-W CTRL-F, split file == :spilt gf if file exits
nnoremap <leader>gf :edit <cfile><CR>
nnoremap <leader><C-W><C-F> :split <cfile><CR>

" Buffer/Window(Splits)/Tab switching
" ================
" map vsb to vert sb

" Meta-keys are mapped as <Esc> + key, this may exit to normal mode
nnoremap h <C-W>h
nnoremap j <C-W>j
nnoremap k <C-W>k
nnoremap l <C-W>l
" Fix meta-keys that break out of Insert mode
" http://vim.wikia.com/wiki/VimTip738
" set ttimeout
" set ttimoutlen=100


" command line window, type into the window instead of using command line
" This is awkward.
" nnoremap : q:i
" nnoremap / q/i
" nnoremap ? q?i

" Plugin UI mappings
" ==================
" Toggle NERDTree/NERDTreeTabs
autocmd VimEnter * nnoremap <F2> :NERDTreeToggle<CR>
autocmd VimEnter * inoremap <F2> <Esc>:NERDTreeToggle<CR>
" <S-F2> is very problematic in console vim
"autocmd VimEnter * nnoremap <Leader><F2> :NERDTreeTabsToggle<CR>
"autocmd VimEnter * inoremap <Leader><F2> <Esc>:NERDTreeTabsToggle<CR>

" Toggle TagBar
autocmd VimEnter * nnoremap <F3> :TagbarToggle<CR>
autocmd VimEnter * inoremap <F3> <Esc>:TagbarToggle<CR>

" Toggle Gundo
autocmd VimEnter * nnoremap <F6> :GundoToggle<CR>
autocmd VimEnter * inoremap <F6> <Esc>:GundoToggle<CR>

" Toggle TComment
nnoremap <C-_> :TComment<CR>
vnoremap <C-_> :TComment<CR>

" <Space> and <Tab> mapping
" =========================
" Space mapping func, if there's drop-down list, use <Space> to expand
function! g:Space_Mapping()
	" do not expand snippets inside comments
	if IsInsideComment()
		return "\<C-R>=AutoPairsSpace()\<CR>"
	endif
	if pumvisible()

		" find last echoed message on space, not on tab, performace reason
		call s:Get_Last_Msg()

		" expand snippets only when entry is highlighted in the menu
		if match(b:lastmsg,"match") != -1
			call UltiSnips#ExpandSnippet()
			"This returns g:ulti_expand_res as well as expands the snippets
			" if nothing to expand, then go on and type space
			" if something to expand, then return empty string
			if g:ulti_expand_res == 0
				return "\<Space>"
			else
				return ""
			endif
		else
			return "\<Space>"
		endif
	else
		" when no popup menu, (ie. no char is typed)
		return "\<C-R>=AutoPairsSpace()\<CR>"
	endif
endfunction

autocmd BufEnter * inoremap <silent> <Space> <C-R>=g:Space_Mapping()<CR>

" Map <Tab>, if drop-down list, then iterate list
" If leading char is space, print spaces; if tab, print tab
function! g:Tab_Mapping()
	let line = getline('.')
	let prev_char = line[col('.')-2]
	let curr_char = line[col('.')-1]
	if pumvisible()
		" if ins-completion-menu appears, mock YCM behavior, tab = iterate
		return "\<C-N>"
		" if this is the start of a sentence, then use <tab> for indentation
	elseif strpart( getline('.'), 0, col('.')-1  ) =~ '^$'
		return "\<Tab>"
	elseif prev_char == ' '
		" if leading char is space, then print spaces
		" if leading char is tab, then print tabs (use Shift-Tab to print literal tab)
		return repeat("\<Space>", &tabstop)
	elseif curr_char =~ '["\]'')}]'
		" if current char is closing brackets, then escape out
		return "\<Esc>\<Right>a"
	elseif prev_char =~ '\S'
		" if no ins-completion-menu, and previous char is a non-whitespace char,
		" then jump to the nearest closing bracket
		" there is a bug here, is the next closing bracket is the first char
		" of line, then <Tab> won't enter insert mode
		if search('["\]'')}]','W')
			return "\<Esc>\<Right>a"
		else
			" use ominicompletion to force compelte
			" need to suppress warning without omini setup
			return "\<C-X>\<C-O>"
		endif
	else
		return "\<Tab>"
	endif
endfunction
autocmd BufEnter * inoremap <silent> <Tab> <C-R>=g:Tab_Mapping()<CR>

function! s:Get_Last_Msg()
	redir => b:messages
	silent messages
	redir END
	let b:lastmsg=get(split(b:messages, "\n"), -1, "")
	return b:lastmsg
endfunction

function! IsInsideComment()
	let syn = synIDattr(synID(line('.'),col('.')-1,1),'name')
	return syn =~? 'comment\|string\|character\|doxygen' ? 1 : 0
endfunction

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                            07. Plugin Settings                             "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" indent-guides (DEPRECATED)
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

let g:Tex_CompileRule_pdf='pdflatex -interaction=nonstopmode --shell-escape $*'
" Add --shell-escape flag to enable eps pictures

" IMPORTANT: win32 users will need to have 'shellslash' set so that latex can
" be called correctly.
set shellslash
" IMPORTANT: grep will sometims skip displaying the file name if you search in
" a single file. This will confuse Latex-Suite. Set your grep program to
" always generate a file-name.
set grepprg=grep\ -nH\ $*

" Javascript syntax
let b:javascript_fold = 1
let javascript_ignore_javaScriptdoc = 1
"au FileType javascript call JavaScriptFold()

" JsBeautify
" ==========
" -C comma first, -t use tab
autocmd FileType javascript nnoremap <buffer> <Leader>ff :%!js-beautify -j -s 2 -q -C -f -<CR>
" autocmd FileType javascript nnoremap <buffer> <Leader>ff :%!js-beautify -j -s 2 -q -C -f -<CR>
" remove all empty lines in html files using -m 0 flag
autocmd FileType html nnoremap <buffer> <Leader>ff :%!js-beautify --type=html -m 0 -q -f -<CR>
autocmd FileType scss,css nnoremap <buffer> <Leader>ff :%!js-beautify --type=css -q -f -<CR>

" this one not working correctly
autocmd FileType javascript vnoremap <buffer> <Leader>ff :!js-beautify -j -q -f -<CR>
" autocmd FileType javascript vnoremap <buffer> <Leader>ff :!js-beautify -j -q -f -<CR>

" vim-prettier
" ==========
"g:prettier#config#print_width=60
autocmd FileType javascript nnoremap <buffer> <Leader>ff :Prettier<CR>
autocmd FileType javascript vnoremap <buffer> <Leader>ff :Prettier<CR>

" easytags (DEPRECATED, use tagbar instead)
" ========
" " Use jsctags for javascript tag generation
" let g:easytags_languages = {
" \   'javascript': {
" \       'cmd': '/usr/local/bin/jsctags',
" \       'args': [],
" \       'fileoutput_opt': '-f',
" \       'stdout_opt': '-f-',
" \       'recurse_flag': '-R'
" \   }
" \}
" " Seperate tags for different files
" let g:easytags_dynamic_files = 2
" " Disable auto highlight, the flash of color change can be confusing
" let g:easytags_auto_highlight = 0

" NERDTree
" ========
let NERDTreeShowLineNumbers = 1
let g:NERDTreeWinPos = "right"
" responsive width given current window width and number column width
" and by default counting gitgutter width as well
let restwidth = &columns - (&textwidth + &numberwidth + 1 + 1)
if restwidth > 31 || restwidth < 0
	let g:NERDTreeWinSize=31
else
	let g:NERDTreeWinSize = restwidth - 1
endif
" TODO:
" resize NERDTreeWinSize on split resize, current setup needs to restart vim
" TODO:
" resize NERDTreeWinSize on git gutter column shows/hides, current setup needs
" to restart vim

" TagBar
" ======
let g:tagbar_width = 30 " default 40
" Zoom to the longest currently visible tag instead of maximum width
let g:tagbar_zoomwidth = 0 " default 1
" Sort by order in the source file by default, sort by name on demand
let g:tagbar_sort = 0 " default 1
" Remove help line and spaces between groups
let g:tagbar_compact = 1
" Use smaller icons
let g:tagbar_iconchars = ['▸', '▾']
" Auto open tagbar when opening a supported file with `$vim file_name`
"autocmd VimEnter * nested :call tagbar#autoopen(1)
" Auto open tagbar when opening a file with :e
" use ?*.* here to suppress wierd tabbar trailing characters
"autocmd FileType * nested :call tagbar#autoopen(0)
"autocmd BufEnter * nested :call tagbar#autoopen(0)

" bbye
nnoremap <Leader>q :Bdelete<CR>
nnoremap <Leader>qa :bufdo :Bdelete<CR>

" CamelCaseMotion mapping
" =======================
"map <silent> W <Plug>CamelCaseMotion_w
"map <silent> B <Plug>CamelCaseMotion_b
"map <silent> E <Plug>CamelCaseMotion_e
"sunmap W
"sunmap B
"sunmap E
"omap <silent> iW <Plug>CamelCaseMotion_iw
"xmap <silent> iW <Plug>CamelCaseMotion_iw

" easymotion
" ==========
"map <Leader> <Plug>(easymotion-prefix)
" map s and t to normal, visual+select, operant mode
map s <Plug>(easymotion-s2)
omap s <Plug>(easymotion-sl)
" map t and f for operant and visual mode, very handy for d/v/c + t/f
nmap t <Plug>(easymotion-bd-tl)
vmap t <Plug>(easymotion-bd-t)
omap t <Plug>(easymotion-bd-tl)
nmap f <Plug>(easymotion-bd-fl)
vmap f <Plug>(easymotion-bd-f)
omap f <Plug>(easymotion-bd-fl)
map  / <Plug>(easymotion-sn)
omap / <Plug>(easymotion-tn)
"noremap  <expr> n @/!='' ? 'n' : '<Plug>(easymotion-next)'
"map  N <Plug>(easymotion-prev)
" move inside the same line
nmap w <Plug>(easymotion-lineforward)
nmap b <Plug>(easymotion-linebackward)
nmap W <Plug>(easymotion-s)
" use <Leader>s to map sl2 is kinda redundant since s2 is already pretty specific

let g:EasyMotion_startofline = 0 " keep cursor colum when JK motion
let g:EasyMotion_smartcase = 1
let g:EasyMotion_use_smartsign_us = 1 " US layout
" symbols and numerals. 1 will match 1 and !; ! matches ! only. Default: 0.
let g:EasyMotion_keys='asdfjklqwertzxcvbyuiopnm;hg'
"let g:EasyMotion_do_shade = 1 " default 1
" use space to auto jump to the nearest option
let g:EasyMotion_space_jump_first = 1
" customize prompt
"let g:EasyMotion_prompt = '{n}>>> '

" vim-indexed-search
" ==================
let g:indexed_search_colors  = 0 " msg no color. default: 1
let g:indexed_search_shortmess = 1 " shorter msg. default : 0
let g:indexed_search_numbered_only = 1 " do not show 'first'|'last'. default: 0
let g:indexed_search_dont_move = 1 " stay on the word under curosr. *N or #N. default: 0

" vim-airline
" ===========
" airline composition:
" a(mode) b(branch) c(filename) gutter ---------- x(tagbar,filetype) y(encoding) z(line number) warning(whitespace)

" use powerline fonts to print out little triangles on the bar
let g:airline_powerline_fonts = 1

" airline-ctrlp settings
" configure which mode colors should ctrlp window use (takes effect only if
" the active airline theme doesn't define ctrlp colors)
"let g:airline#extensions#ctrlp#color_template = 'insert' (default)
"let g:airline#extensions#ctrlp#color_template = 'normal'
"let g:airline#extensions#ctrlp#color_template = 'visual'
"let g:airline#extensions#ctrlp#color_template = 'replace'

" configure whether to show the previous and next modes (mru, buffer, etc...)
" this way it's more clear
let g:airline#extensions#ctrlp#show_adjacent_modes = 0

" airline-hunks settings (enabled by default)
" vim-gitgutter | vim-signify | changesPlugin
" enable/disable showing only non-zero hunks
let g:airline#extensions#hunks#non_zero_only = 1 " default 0
" set hunk count symbols. >
"let g:airline#extensions#hunks#hunk_symbols = ['+', '~', '-']

" airline-tabline settings, use tab line to display all buffers
let g:airline#extensions#tabline#enabled = 1 " defualt 0

" enable/disable displaying buffers with a single tab
" if disable, then all buffers will cluster within one tab if there's only one
let g:airline#extensions#tabline#show_buffers = 1 " default 1

" enable/disable displaying tab number in tabs mode.
let g:airline#extensions#tabline#show_tab_nr = 1 "default 1
" configure how numbers are calculated in tab mode.
let g:airline#extensions#tabline#tab_nr_type = 0 " # of splits (default)
" for vim, keep low number of tabs, so it should be easy to find which is the
" nth tab.
"let g:airline#extensions#tabline#tab_nr_type = 1 " tab index

" enable/disable displaying index of the buffer.
"When enabled, numbers will be displayed in the tabline and mappings will be
"exposed to allow you to select a buffer directly.  Up to 9 mappings will be
"exposed.

let g:airline#extensions#tabline#buffer_idx_mode = 1
nmap <Esc>1 <Plug>AirlineSelectTab1
nmap <M-1> <Esc>1
nmap <Esc>2 <Plug>AirlineSelectTab2
nmap <M-2> <Esc>2
nmap <Esc>3 <Plug>AirlineSelectTab3
nmap <M-3> <Esc>3
nmap <Esc>4 <Plug>AirlineSelectTab4
nmap <M-4> <Esc>4
nmap <Esc>5 <Plug>AirlineSelectTab5
nmap <M-5> <Esc>5
nmap <Esc>6 <Plug>AirlineSelectTab6
nmap <M-6> <Esc>6
nmap <Esc>7 <Plug>AirlineSelectTab7
nmap <M-7> <Esc>7
nmap <Esc>8 <Plug>AirlineSelectTab8
nmap <M-8> <Esc>8
nmap <Esc>9 <Plug>AirlineSelectTab9
nmap <M-9> <Esc>9
" Note: Mappings will be ignored within a NERDTree buffer.

" The `unique_tail_improved` - another algorithm, that will smartly uniquify
" buffers names with similar filename, suppressing common parts of paths.
let g:airline#extensions#tabline#formatter = 'unique_tail_improved'

"* configure whether close button should be shown, and its symbol
"let g:airline#extensions#tabline#show_close_button = 1
let g:airline#extensions#tabline#close_symbol = '✖ ' " default X

" CtrlP
" =====
" window location, order bottome to top, window size
let g:ctrlp_match_window = 'bottom,order:btt,min:1,max:5,results:20'
" show hidden files
"let g:ctrlp_show_hidden = 1 "default 0
let g:ctrlp_max_files = 5000 " default 10000

" FZF
" ===
function! BufList()
  redir => ls
  silent ls
  redir END
  return split(ls, '\n')
endfunction

function! BufOpen(e)
  execute 'buffer '. matchstr(a:e, '^[ 0-9]*')
endfunction

nnoremap <silent> <Leader><Enter> :call fzf#run({
\   'source':      reverse(BufList()),
\   'sink':        function('BufOpen'),
\   'options':     '+m',
\   'tmux_height': '10%'
\ })<CR>

" Auto-Pairs
" ==========
" disable auto center line, very confusing
" When g:AutoPairsMapCR is on, center current line after return if the line is
" at the bottom 1/3 of the window.
let g:AutoPairsCenterLine = 0 " default 1
" disable <Space> mapping, use custom <Space> mapping
" Map <space> to insert a space after the opening character and before the
" closing one.  execute 'inoremap <buffer> <silent> <Space>
" <C-R>=AutoPairsSpace()<CR>'
let g:AutoPairsMapSpace = 0 " default 1
" turn on flymode, use AutoPairsBackInsert(Default Key: <M-b>) to jump back and insert closed pair.
" let g:AutoPairsFlyMode = 1 " default 0
" use tab to escape out parenthesis, use <C-J> to force escape
let g:AutoPairsShortcutJump = "<C-J>"


" Ultisnips
" =========
let g:UltiSnipsExpandTrigger = "<F12>"
" this invokes quickfix to list all choices in insert mode
" let g:UltiSnipsListSnippets="<Leader>ls" "default <C-Tab>"
" <c-tab> only works in Gvim, cuz <c-tab> won't be sent into the terminal
" <tab> is rendered as Ctrl-I, so <c-tab> is rendered as Ctrl-Ctrl-I. which is impossible
let g:UltiSnipsJumpForwardTrigger = "<Tab>"
let g:UltiSnipsJumpBackwardTrigger = "<C-K>"
" ${VISUAL} mode of UltiSnips. Trying to put everything in register " into
" UltiSnips_SaveLastVisualSelection()
" xnoremap x :call UltiSnips#SaveLastVisualSelection()<CR>gvx
" xnoremap d :call UltiSnips#SaveLastVisualSelection()<CR>gvd
" xnoremap s :call UltiSnips#SaveLastVisualSelection()<CR>gvs

let g:UltiSnipsEditSplit = 'vertical'
autocmd BufEnter *.rails UltiSnipsAddFiletypes rails.ruby
" Priority rails -> ruby -> all

" :call UltisnipsEdit will open the following dir, which contains private snippets
" Do not use "snippets" for name, this is reserved for snipMate
let g:UltiSnipsSnippetsDir = "~/.vim/snippets/UltiSnips"
let g:UltiSnipsSnippetDirectories=["snippets/UltiSnips"]

" YouCompleteMe(YCM)
" ==================
" Unmap <Tab> from iterating drop-down list, use custom mapping for <Tab>
let g:ycm_key_list_select_completion = ['<Down>'] "deafult += <Tab>
" start completion with only 1 char, somewhat buggy when pressing backspace
let g:ycm_min_num_of_chars_for_completion = 1 "default 2
" min #char of popup entry, do not show single letter suggestions
let g:ycm_min_num_identifier_candidate_chars = 2 "default 0

let g:ycm_global_ycm_extra_conf = '~/.vim/bundle/youcompleteme/cpp/ycm/.ycm_extra_conf.py'
" YCM will show the completion menu inside comments
let g:ycm_complete_in_comments = 1 "default 0
" Make YCM's identifier completer seed its identifier database with the
" keywords of the programming language you're writing.
" let g:ycm_seed_identifiers_with_syntax = 1 "default 0

" Set trigger for semantic completion, mostly use vim omicomplete function
let g:ycm_semantic_triggers =  {
			\   'c' : ['->', '.'],
			\   'objc' : ['->', '.'],
			\   'ocaml' : ['.', '#'],
			\   'cpp,objcpp' : ['->', '.', '::'],
			\   'perl' : ['->'],
			\   'php' : ['->', '::'],
			\   'cs,java,javascript,d,python,perl6,scala,vb,elixir,go' : ['.'],
			\   'vim' : ['re![_a-zA-Z]+[_\w]*\.'],
			\   'ruby' : ['.', '::'],
			\   'lua' : ['.', ':'],
			\   'erlang' : [':'],
			\   'html' : ['</'],
			\   'css' : [':',': ','; ','!'],
			\   'scss' : [':',': ','; ','!'],
			\ }

" Syntastic
" =========
" Check syntax on both loading and saving buffers
let g:syntastic_check_on_open = 0
" " Run all checkers combined one by one, and label checker id to errors.
let g:syntastic_aggregate_errors = 1 " default 0
" shows which checkers generates errors in the aggregated list
" let g:syntastic_id_checkers = 1 " default 1

" Use :sign interface (the panel left to line numbers) to mark syntax errors
let g:syntastic_enable_signs = 1 "default 1
" Syntax and style errors
let g:syntastic_error_symbol = '>>' " default '>>'
" let g:syntastic_style_error_symbol = '✗'
let g:syntastic_warning_symbol = '>>' " default '>>'
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
let g:syntastic_javascript_checkers = ['eslint']
"let g:syntastic_javascript_checkers = ['jshint'] " default none
" syntastics by default adds loads of flags for jslint, which turns off most
" of the syntactical errors, such as missing spaces between letter and (
let g:syntastic_javascript_jslint_args = ""

" Misc settings
" =============
" restore original view and colorscheme settings etc. from DFM
autocmd! User GoyoLeave
autocmd  User GoyoLeave nested source $MYVIMRC | silent loadview
let g:calendar_google_calendar = 1
let g:hardtime_default_on = 1
"let g:hardtime_showmsg = 1
let g:hardtime_allow_different_key = 1
let g:hardtime_maxcount = 2
let g:hardtime_ignore_buffer_patterns = [ "NERD.*" ]
" The quickfix window cannot be added to the ignore buffers array to have hardtime ignore it set
let g:hardtime_ignore_quickfix = 1


 "let g:niji_matching_filetypes = ['lisp', 'ruby', 'python', 'javascript']
 "let g:niji_use_legacy_colours = 1

" Custom settings (DEPRECATED)
" ============================
" source ~/.vim/custom/color.vim
" source ~/.vim/custom/font.vim
" source ~/.vim/custom/functions.vim
" source ~/.vim/custom/mappings.vim
" source ~/.vim/custom/settings.vim
" source ~/.vim/custom/plugins.vim

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                                08. Commands                                "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
command! Wsudo :w !sudo tee > /dev/null %

" Convenient command to see the difference between the current buffer and the
" file it was loaded from, thus the changes you made.
" Only define it when not defined already.
if !exists(":DiffOrig")
	command DiffOrig vert new | set bt=nofile | r ++edit # | 0d_ | diffthis
				\ | wincmd p | diffthis
endif

" redirect pager to a scratch split
function! s:Redir(cmd)
let output = ""
redir =>> output
silent exe a:cmd
redir END
return output
endfunction

"A command to open a scratch buffer.
function! s:Scratch()
split Scratch
setlocal buftype=nofile
setlocal bufhidden=wipe
setlocal noswapfile
setlocal nobuflisted
return bufnr("%")
endfunction

"Put the output of acommand into a scratch buffer.
function! s:Pager(command)
let output = s:Redir(a:command)
call s:Scratch()
"normal gg
call append(1, split(output, "\n"))
normal dd
endfunction

command! -nargs=+ -complete=command Pager :call <SID>Pager(<q-args>)

""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
"                             09. Gvim Settings                              "
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
if has("gui_running")
	set t_Co=256 " enable 256-color mode.
	set guifont=Ubuntu\ Mono\ derivative\ Powerline\ 12
	" Disable menu alt keys, so that vim can map <M-KEY>
	set winaltkeys=no

	if g:colors_name == "wombat256mod"
		hi NonText guifg=gray
	endif
endif

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")
" hi Overlength
" may use if has("gui_running") to config
" highlight OverLength ctermbg=red ctermfg=white guibg=#592929
" match OverLength /\%81v.\+/
"
" Add another config file to enable project specific settings.
" It seems add another .vimrc still works.
"set secure
"set exrc
