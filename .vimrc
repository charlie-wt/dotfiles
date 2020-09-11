set nocompatible


" === Plugins ==================================================================
call plug#begin('~/.vim/bundle')

" appearance
Plug 'gruvbox-community/gruvbox'
Plug 'vim-airline/vim-airline'
" languages
Plug 'docunext/closetag.vim', { 'for': ['html', 'xml'] }
Plug 'derekwyatt/vim-fswitch'
Plug 'sheerun/vim-polyglot'
Plug 'ap/vim-css-color'
Plug 'vim-pandoc/vim-pandoc-syntax'
Plug 'vim-pandoc/vim-pandoc'
" commands
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
Plug 'machakann/vim-swap'
" ide
Plug 'junegunn/fzf', { 'dir': '~/src/fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
Plug 'w0rp/ale', { 'on': 'ALEToggleBuffer' }
Plug 'junegunn/goyo.vim'
Plug 'natebosch/vim-lsc'
Plug 'ajh17/VimCompletesMe'
" background
Plug 'ConradIrwin/vim-bracketed-paste'
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
" highlight search results incrementally as they're typed
set hlsearch incsearch
" ignore case in searches unless we type a capital letter
set ignorecase smartcase
" copy indentation level from previous line
set copyindent
" colours
set termguicolors
set background=dark
silent! colo gruvbox
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
" don't reset cursor to start of line when moving
set nostartofline
" don't add newlines to the end of files
set binary noendofline
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
set listchars=tab:\|\ ,extends:▶,precedes:◀
" start continuations of broken lines on current indent level
if exists('&breakindent')
    set breakindent
endif
" allow backspacing over everything
set backspace=indent,eol,start
" formatting options, for gq
set formatoptions=croqnj
" prefer spaces over tabs by default
set expandtab
" don't redraw the screen in the middle of executing a macro -- improves speed
set lazyredraw
" true colours
if exists('+termguicolors')
    let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
    set termguicolors
endif
" highlight visual selections with only a slightly lighter background
hi Visual term=none cterm=none gui=none ctermbg=239
" Default text width
set textwidth=88
" Highlight the column after the maximum text width
set colorcolumn=+1
" config for autocompletion
set completeopt=menu,menuone,noinsert,noselect


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
" leader+cd: set current directory (all windows) to directory of current file
nnoremap <silent> <leader>cd :cd %:p:h<cr>
" :Diff to view a diff of unsaved changes
command Diff execute 'w !git diff --no-index % -'
" leader+s: replace all instances of the keyword under the cursor.
nnoremap <leader>s :%s/\<<c-r><c-w>\>//g<left><left>
" leader+w: strip trailing whitespace
nnoremap <silent> <leader>w :let _s=@/<bar>:%s/\s\+$//e<bar>:let @/=_s<bar><cr>
" fzf, for finding files
noremap <leader>f :Files<cr>
noremap <leader>r :Rg<cr>
" repeat the last macro
nnoremap Q @@
" make j & k move by wrapped lines, unless given a count -- aka. 10j still
" goes down 10 'true' lines
nnoremap <expr> k (v:count == 0 ? 'gk' : 'k')
nnoremap <expr> j (v:count == 0 ? 'gj' : 'j')
" F3 to toggle NERDTree
noremap <silent> <F3> :NERDTreeToggle<CR>
" F8 to toggle tagbar - NOTE: tagbar needs universal ctags (or exuberant ctags)
noremap <silent> <F8> :TagbarToggle<CR>

" == Functions
" F2 to toggle ALE -- even if it's not initially loaded
function ToggleALE()
    if !exists(':ALEToggleBuffer')
        exec ':ALEToggle'
        exec ':ALEEnable'
        exec ':ALEToggleBuffer'
    endif
    exec ':ALEToggleBuffer'
endfunction
noremap <silent> <F2> :call ToggleALE()<cr>

" <leader>t__: insert TODO comments above the current line, with tags defined
" by __. NOTE: relies on the commentary plugin
function Todo(tag)
    exec "normal OTODO #".a:tag
    exec "normal \<Plug>CommentaryLine"
endfunction

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
noremap <silent> <leader>er :call ToggleLocList()<cr>

" if in a markdown or tex file, open the corresponding pdf easily
function OpenPDF()
    " if our file's called '.md' or '.tex', look for '.pdf' -- not eg. '.md.pdf'
    let pdfname = '.pdf'
    if expand('%:t') !~ '^\.[^\.]\+$'
        let pdfname = expand('%:p:r') . '.pdf'
    endif
    " check the pdf file exists
    if !filereadable(pdfname)
        echo 'PDF ' . pdfname . ' not found'
        return
    endif
    " open the pdf, as unobstructively as possible
    exec ':silent !gio open ' . pdfname . ' > /dev/null &'
    exec ':redraw!'
endfunction

function TodoTick()
    let line = getline('.')
    let pos = col('.')
    if line =~ '.*\[ \].*'
        s/\[ \]/[x]/
    elseif line =~ '.*\[x\].*'
        s/\[x\]/[ ]/
    endif
    exec 'normal ' . pos . '|'
endfunction
noremap <silent> <leader>x :call TodoTick()<cr>

" custom function for styling folds
function! CustomFoldText()
    " adapted from https://dhruvasagar.com/2013/03/28/vim-better-foldtext
    let indent = repeat(' '.indent(v:foldstart))
    let line = ' ' . substitute(getline(v:foldstart), '^\s*"\?\s*\|\s*"\?\s*{{' . '{\d*\s*', '', 'g') . ' '
    let lines_count = v:foldend - v:foldstart + 1
    " let lines_count_text = '| ' . printf("%10s", lines_count . ' lines') . ' |'
    let lines_count_text = '-' . printf("%10s", lines_count . ' lines') . ' '
    let foldchar = matchstr(&fillchars, 'fold:\zs.')
    let foldtextstart = strpart('+' . repeat(foldchar, v:foldlevel*2) . line, 0, (winwidth(0)*2)/3)
    let foldtextend = lines_count_text . repeat(foldchar, 8)
    let foldtextlength = strlen(substitute(foldtextstart . foldtextend, '.', 'x', 'g')) + &foldcolumn
    return indent . foldtextstart . repeat(foldchar, winwidth(0)-foldtextlength) . foldtextend
endfunction
set foldtext=CustomFoldText()

" == Disabled commands
" K -> run a program to look up keyword under the cursor
" nnoremap K <nop>
" Ctrl+Z -> background the vim process
nnoremap <C-z> <nop>
" Ctrl+\ -> evaluate expression, replace the whole command line with the result
"           (I currently use this as my tmux prefix)
nnoremap <C-\> <nop>


" === Autocommands =============================================================
" apparently it's faster to group all your autocommands together in a group,
" that clears itself before adding its commands.
augroup my_autocmds
    au!

    " temporarily clear search highlighting when in insert mode.
    au insertenter * :set nohlsearch
    au insertleave * :set hlsearch

    " highlight trailing whitespace
    au bufenter * :match ErrorMsg '\s\+$'
    au winenter * :match ErrorMsg '\s\+$'

    " quickly add TODO comments (see Todo function above)
    au vimenter * nnoremap <leader>tbg :call Todo("bug")<CR>
    au vimenter * nnoremap <leader>tcl :call Todo("cleanup")<CR>
    au vimenter * nnoremap <leader>tcr :call Todo("correctness")<CR>
    au vimenter * nnoremap <leader>tdc :call Todo("documentation")<CR>
    au vimenter * nnoremap <leader>ten :call Todo("enhancement")<CR>
    au vimenter * nnoremap <leader>tft :call Todo("feature")<CR>
    au vimenter * nnoremap <leader>tfn :call Todo("finish")<CR>
    au vimenter * nnoremap <leader>trf :call Todo("refactor")<CR>
    au vimenter * nnoremap <leader>trm :call Todo("remove")<CR>
    au vimenter * nnoremap <leader>tsp :call Todo("speed")<CR>
    au vimenter * nnoremap <leader>ttm :call Todo("temp")<CR>
    au vimenter * nnoremap <leader>tts :call Todo("test")<CR>
    au vimenter * nnoremap <leader>tvf :call Todo("verify")<CR>

    " set some filetypes
    au bufenter *.p8 set filetype=lua
    au winenter *.p8 set filetype=lua

    " filetype-specific options
    au filetype cpp setlocal tw=88 cc=+1 noet cinoptions=(0,u0,U0 comments^=:///
    au filetype typescript setlocal sw=2 sts=2 et
    au filetype haskell setlocal ts=4 sw=4 sts=4 et
    au filetype qmake setlocal commentstring=#%s

    " filetype-specific maps
    " fswitch  for switching between header/source files
    au filetype cpp noremap <silent> <leader>of :FSHere<cr>
    au filetype cpp noremap <silent> <leader>ol :FSSplitRight<cr>
    " F5 to 'compile' certain files (markdown, latex) TODO use :make
    au FileType markdown noremap <F5> :!mdpdf "%" & disown<CR><CR>
    au FileType tex noremap <F5> :!xelatex "%"<CR><CR>
    " F6 to turn markdown into beamer slides (instead of normal latex doc)
    au FileType markdown noremap <F6> :!mdsl "%" & disown<CR><CR>
    " F7 to turn markdown into report
    au FileType markdown noremap <F7> :!mdrep "%"<CR><CR>
    " leader+o to open the corresponding pdf to this file
    au filetype markdown,tex,latex,pandoc noremap <silent> <leader>o :call OpenPDF()<cr>

    " extra syntax highlighting
    " normal aliases to primitive numeric types
    au Syntax c,cpp syn keyword cType u8 u16 u32 u64 s8 s16 s32 s64 f32 f64
augroup END


" === Plugin config ============================================================
" airline
set laststatus=2
" let g:airline_powerline_fonts=1
" let g:crystalline_theme = 'gruvbox'

" vim-pandoc
let g:pandoc#modules#disabled = ["folding"]

" ale
let g:ale_enabled=1
let g:ale_python_pylint_executable='pylint3'
let g:ale_lint_on_enter=0
let g:ale_lint_on_save=0
let g:ale_lint_on_filetype_changed=0
let g:ale_sign_error='✘'
let g:ale_sign_warning='⚠'
let g:ale_echo_msg_format='[%linter%] %s'
let g:ale_c_parse_makefile=1
let g:ale_cpp_cppcheck_options = '--enable=style --language=c++'
let g:ale_cpp_gcc_options = '--std=c++17' " TODO set based on makefile
let g:ale_sign_column_always = 1

" goyo
let g:goyo_width = 81

" vim-lsc
let g:lsc_server_commands = {
\  'cpp': {
\    'command': 'ccls',
\    'log_level': -1,
\    'suppress_stderr': v:true,
\  }
\}
let g:lsc_auto_map = {
 \  'GoToDefinition': 'gd',
 \  'FindReferences': 'gr',
 \  'Rename': 'gR',
 \  'ShowHover': 'K',
 \  'FindCodeActions': 'ga',
 \  'Completion': 'omnifunc',
 \}
let g:lsc_enable_autocomplete  = v:true
let g:lsc_enable_diagnostics   = v:false
let g:lsc_reference_highlights = v:false
let g:lsc_trace_level          = 'off'
