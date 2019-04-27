set nocompatible


" === Plugins ==================================================================
call plug#begin('~/.vim/bundle')

" appearance
Plug 'morhetz/gruvbox'
Plug 'romainl/Apprentice', { 'branch': 'fancylines-and-neovim' }
Plug 'NLKNguyen/papercolor-theme'
Plug 'junegunn/seoul256.vim'
Plug 'chriskempson/base16-vim'
Plug 'jacoborus/tender.vim'
Plug 'fcpg/vim-fahrenheit'
Plug 'cocopon/iceberg.vim'
Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
" languages
Plug 'sheerun/vim-polyglot'
Plug 'tmhedberg/SimpylFold', { 'for': 'python' }
Plug 'ap/vim-css-color'
Plug 'vim-pandoc/vim-pandoc-syntax'
Plug 'vim-pandoc/vim-pandoc'
" commands
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-speeddating'
" ide
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'majutsushi/tagbar'
Plug 'w0rp/ale', { 'on': 'ALEToggleBuffer' }
" background
" Plug 'vim-scripts/Smart-Tabs'
Plug 'docunext/closetag.vim', { 'for': ['html', 'xml'] }
Plug 'ConradIrwin/vim-bracketed-paste'
Plug 'tpope/vim-sleuth'
Plug 'tpope/vim-repeat'
Plug 'andymass/vim-matchup'
Plug 'wellle/targets.vim'
Plug 'christoomey/vim-tmux-navigator'

call plug#end()


" === General ==================================================================
" syntax highlighting
syntax on
" line numbers - hybrid mode (current line absolute, all others relative)
set number relativenumber
" tab size
set tabstop=4
set softtabstop=4
set shiftwidth=4
" highlight search results
set hls
" highlight first search result as it is typed
set is
" temporarily clear search highlighting when in insert mode.
autocmd InsertEnter * :set nohlsearch
autocmd InsertLeave * :set hlsearch
" ignore case in searches unless we type a capital letter
set ignorecase
set smartcase
" highlight trailing whitespace
autocmd BufEnter * match ErrorMsg '\s\+$'
autocmd WinEnter * match ErrorMsg '\s\+$'
" copy indentation level from previous line
set copyindent
" colours
set termguicolors
set background=dark
colo gruvbox
" full mouse support
set mouse=a
" show command as it's being typed
set showcmd
" don't reset cursor to start of line when moving
set nosol
" tab completion opens all options in a list
set wildmenu
set wildmode=list:longest,full
" reload files edited outside of vim
set autoread
" don't fold by default
set nofoldenable
" don't add newlines to the end of files
set binary
set noeol
" set character encoding - utf-8 without BOM (Byte Order Marker)
set encoding=utf-8 nobomb
" centralize backups, swapfiles & undo history
set backupdir=~/.vim/backups
set directory=~/.vim/swaps
if exists("&undodir")
	set undodir=~/.vim/undo
endif
" don't create backups for temp files
set backupskip=/tmp/*,/private/tmp/*
" disable error bells
set noerrorbells
" fix for bg col changing when scrolling
if &term =~ '256color'
	set t_ut=
endif
" whitespace characters
set list
set lcs=tab:\|\ ,extends:▶,precedes:◀
" start continuations of broken lines on current indent level
if exists('&breakindent')
	set breakindent
endif
" formatting options, for gq
set formatoptions=croqnj


" === Custom commands ==========================================================
let mapleader = " "

" == Basic maps
" clear search highlighting with \
nnoremap \ :noh<cr>:<backspace>
" Ctrl+HJKL to go between splits
nnoremap <c-j> <c-w>j
nnoremap <c-k> <c-w>k
nnoremap <c-h> <c-w>h
nnoremap <c-l> <c-w>l
" H/L to go to start/end of line
noremap H ^
noremap L $
" swap ; and :
noremap : ;
noremap ; :
" Y yanks to end of line, consistent with D & C
nnoremap Y y$
" an easier-to-reach way of moving to the previous tabpage
noremap gy gT

" == New commands
" system clipboard access with Ctrl+C/P:
if has("clipboard")
	" if vim has system clipboard support, use it
	vnoremap <c-c> "+y
	noremap <c-p> "+p
else
	" otherwise, use the (external) xsel package (can only copy whole lines)
	vnoremap <c-c> :w !xsel -i -b<cr><cr>
	noremap <c-p> :r !xsel -o -b<cr><cr>
endif
" leader+gd: set current directory (all windows) to directory of current file
nnoremap <leader>gd :cd %:p:h<cr>:<backspace>
" :Diff to view a diff of unsaved changes
command Diff execute 'w !git diff --no-index % -'
" leader+s: replace all instances of the keyword under the cursor.
nnoremap <leader>s :%s/\<<c-r><c-w>\>//g<left><left>
" leader+w: strip trailing whitespace
nnoremap <leader>w :let _s=@/<bar>:%s/\s\+$//e<bar>:let @/=_s<bar><cr>

" == Function keys
" F2 to toggle ALE
noremap <silent> <F2> :ALEToggleBuffer<CR>
" F3 to toggle NERDTree
noremap <silent> <F3> :NERDTreeToggle<CR>
" F5 to 'compile' certain files (markdown, latex) TODO use :make
au FileType markdown noremap <F5> :!mdpdf "%" & disown<CR><CR>
au FileType tex noremap <F5> :!xelatex "%"<CR><CR>
" F6 to turn markdown into beamer slides (instead of normal latex doc)
au FileType markdown noremap <F6> :!mdsl "%" & disown<CR><CR>
" F7 to turn markdown into report
au FileType markdown noremap <F7> :!mdrep "%"<CR><CR>
" F8 to toggle tagbar - NOTE: tagbar needs universal ctags (or exuberant ctags)
noremap <silent> <F8> :TagbarToggle<CR>

" == Functions
" leader+t_ commands to add todo comments with various tags above the current
" line.
function Todo(tag)
	exec "normal O"
	exec "normal CTODO #".a:tag
	exec "normal \<Plug>CommentaryLine"
endfunction
autocmd VimEnter * nnoremap <leader>tbg :call Todo("bug")<CR>
autocmd VimEnter * nnoremap <leader>tcl :call Todo("cleanup")<CR>
autocmd VimEnter * nnoremap <leader>tcr :call Todo("correctness")<CR>
autocmd VimEnter * nnoremap <leader>tdc :call Todo("documentation")<CR>
autocmd VimEnter * nnoremap <leader>ten :call Todo("enhancement")<CR>
autocmd VimEnter * nnoremap <leader>tft :call Todo("feature")<CR>
autocmd VimEnter * nnoremap <leader>tfn :call Todo("finish")<CR>
autocmd VimEnter * nnoremap <leader>trf :call Todo("refactor")<CR>
autocmd VimEnter * nnoremap <leader>trm :call Todo("remove")<CR>
autocmd VimEnter * nnoremap <leader>tsp :call Todo("speed")<CR>
autocmd VimEnter * nnoremap <leader>ttm :call Todo("temp")<CR>
autocmd VimEnter * nnoremap <leader>tts :call Todo("test")<CR>
autocmd VimEnter * nnoremap <leader>tvf :call Todo("verify")<CR>

" toggle the location list
function! ToggleLocList()
	" 'close' the location list, then see of the number of windows changed.
	try
		let old_last_winnr = winnr('$')
		lclose
		if old_last_winnr == winnr('$')
			lopen
		endif
	catch
	endtry
endfunction
command Errors :call ToggleLocList()
noremap <silent> <leader>er :call ToggleLocList()<CR>

" if in a markdown or tex file, open the corresponding pdf easily
function OpenPDF()
	let pdfname = expand('%:p:r') . '.pdf'
	if !filereadable(pdfname)
		echo 'PDF ' . pdfname . ' not found'
		return
	endif
	exec ':silent !gio open ' . pdfname . ' > /dev/null &'
	exec ':redraw!'
endfunction
au filetype markdown,tex,latex,pandoc noremap <silent> <leader>o :call OpenPDF()<cr>

" == Disabled commands
" Q -> Ex mode
nnoremap Q <nop>
" K -> run a program to lookup keyword under the cursor
nnoremap K <nop>
" Ctrl+Z -> background the vim process
nnoremap <C-z> <nop>
" Ctrl+\ -> evaluate expression, replace the whole command line with the result
"           (I currently use this as my tmux prefix)
nnoremap <C-\> <nop>


" === Filetypes ================================================================
" c++
au filetype cpp set tw=88 cc=+1
" prose
au filetype markdown,tex,latex,pandoc noremap j gj
au filetype markdown,tex,latex,pandoc noremap k gk
au filetype markdown,tex,latex,pandoc noremap 0 g0
au filetype markdown,tex,latex,pandoc noremap H g^
au filetype markdown,tex,latex,pandoc noremap L g$
au filetype markdown,tex,latex set norelativenumber
" typescript
au FileType typescript setlocal sw=2 sts=2 et


" === Plugin config ============================================================
" airline
set laststatus=2
let g:airline_powerline_fonts=1

" ale
let g:ale_enabled=1
let g:ale_python_pylint_executable='pylint3'
" a bug in ubuntu 18.04's vim version hides the cursor on lines with messages if
" this (below) is set to 1 (default). however, since I have ale disabled on
" start I only really 'drop in' to use it if I want to look at messages, so
" better to have than not.
" let g:ale_echo_cursor=0
let g:ale_lint_on_enter=0
let g:ale_lint_on_save=0
let g:ale_lint_on_filetype_changed=0
let g:ale_sign_error='✘'
let g:ale_sign_warning='⚠'
let g:ale_echo_msg_format='[%linter%] %s'
let g:ale_c_parse_makefile=1

" == Other
" manually set indentation stuff for typescript, since polyglot doesn't do it.