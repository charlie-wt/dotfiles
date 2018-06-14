set nocompatible
" == Plugins
call plug#begin('~/.vim/bundle')

Plug 'scrooloose/nerdtree'
Plug 'vim-airline/vim-airline'
Plug 'morhetz/gruvbox'
Plug 'vim-scripts/Smart-Tabs'
Plug 'sheerun/vim-polyglot'
Plug 'tmhedberg/SimpylFold'
Plug 'docunext/closetag.vim'
Plug 'ConradIrwin/vim-bracketed-paste'
Plug 'tpope/vim-sleuth'
Plug 'ap/vim-css-color'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'tpope/vim-speeddating'
Plug 'tpope/vim-repeat'
Plug 'andymass/vim-matchup'
Plug 'majutsushi/tagbar'
Plug 'vim-scripts/aj.vim'
Plug 'vim-pandoc/vim-pandoc-syntax'
Plug 'vim-pandoc/vim-pandoc'
Plug 'wellle/targets.vim'

call plug#end()


" == General
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
" ignore case in searches unless we type a capital letter
set ignorecase
set smartcase
" Highlight trailing whitespace
" match ErrorMsg '\s\+$'
" highlight ExtraWhitespace ctermbg=red guibg=red
match ErrorMsg /\s\+$/
autocmd BufWinEnter * match ErrorMsg /\s\+$/
autocmd InsertEnter * match ErrorMsg /\s\+\%#\@<!$/
autocmd InsertLeave * match ErrorMsg /\s\+$/
autocmd BufWinLeave * call clearmatches()
" Copy indentation level from previous line
set copyindent
" Colour scheme
set background=dark
colorscheme gruvbox
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
" Fix for bg col changing when scrolling
if &term =~ '256color'
	set t_ut=
endif


" == Whitespace characters
set list
set lcs=tab:\|\ ,extends:▶,precedes:◀


" == Custom commands
" clear search highlighting with \
" NOTE - setting this to <esc> will cause using the mouse to input a bunch of
" random commands.
nnoremap \ :noh<CR>:<backspace>
" also clear search highlighting by going into insert mode.
autocmd InsertEnter * :set nohlsearch
autocmd InsertLeave * :set hlsearch
" Ctrl+HJKL to go between splits
nnoremap <C-j> <C-w>j
nnoremap <C-k> <C-w>k
nnoremap <C-h> <C-w>h
nnoremap <C-l> <C-w>l
" H/L to go to start/end of line
nnoremap H ^
nnoremap L $
vnoremap H ^
vnoremap L $
" if editing prose, j/k navigate screen-lines, not file-lines
" TODO: is this good? lose the ability to utilise relative line numbers
au FileType markdown,tex,latex noremap j gj
au FileType markdown,tex,latex noremap k gk
au FileType markdown,tex,latex set norelativenumber
" Y yanks to end of line, consistent with D & C
nnoremap Y y$
" copy/paste from system clipboard (NOTE: needs xsel package installed)
vnoremap <C-c> :w !xsel -i -b<CR><CR>
noremap <C-p> :r !xsel -o -b<CR><CR>
" F8 to toggle tagbar - NOTE: tagbar needs universal ctags (or exuberant ctags)
noremap <F8> :TagbarToggle<CR>
" F3 to toggle NERDTree
noremap <F3> :NERDTreeToggle<CR>
" F5 to 'compile' certain files (markdown, latex)
au FileType markdown noremap <F5> :!mdpdf "%" & disown<CR><CR>
au FileType tex noremap <F5> :!xelatex "%"<CR><CR>
" F6 to turn markdown into beamer slides (instead of normal latex doc)
au FileType markdown noremap <F6> :!mdsl "%" & disown<CR><CR>
" F7 to turn markdown into report
" au FileType markdown noremap <F7> :!mdrep "%" & disown<CR><CR>
au FileType markdown noremap <F7> :!mdrep "%"<CR><CR>

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


" == Plugin config
" airline
set laststatus=2
let g:airline_powerline_fonts=1

" Automatic NERDTree - only in ~/Programming/...
" autocmd VimEnter ~/Programming/* NERDTree
" autocmd BufEnter ~/Programming/* NERDTreeMirror
" autocmd VimEnter ~/Programming/* wincmd w

" == Other
" manually set indentation stuff for typescript, since polyglot doesn't do it.
au FileType typescript setlocal sw=2 sts=2 et
