set nocompatible


" === Plugins ==========================================================================
call plug#begin('~/.vim/bundle')

" appearance
" Plug 'sainnhe/gruvbox-material'
Plug 'gruvbox-community/gruvbox'
Plug 'vim-airline/vim-airline'
" languages
Plug 'ap/vim-css-color'
Plug 'derekwyatt/vim-fswitch'
Plug 'docunext/closetag.vim', { 'for': ['html', 'xml'] }
Plug 'sheerun/vim-polyglot'
Plug 'vim-pandoc/vim-pandoc'
Plug 'vim-pandoc/vim-pandoc-syntax'
" commands
Plug 'machakann/vim-swap'
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
" ide
Plug 'ajh17/VimCompletesMe'
Plug 'junegunn/fzf', { 'dir': '~/src/bin/fzf', 'do': './install --all' }
Plug 'junegunn/fzf.vim'
Plug 'natebosch/vim-lsc'
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
" background
Plug 'ConradIrwin/vim-bracketed-paste'
Plug 'andymass/vim-matchup'
Plug 'christoomey/vim-tmux-navigator'
Plug 'cohama/lexima.vim'
Plug 'tpope/vim-repeat'
Plug 'wellle/targets.vim'
" other
Plug 'junegunn/goyo.vim'

call plug#end()

packadd termdebug


" === General ==========================================================================
syntax on
set number relativenumber
set tabstop=4 softtabstop=4 shiftwidth=4
set hlsearch incsearch
set ignorecase smartcase
set copyindent
set background=dark
set mouse=a
set showcmd
set nostartofline
set wildmenu wildmode=list:longest,full
set autoread
set nofoldenable
set nostartofline
set binary noendofline
set encoding=utf-8 nobomb
set noerrorbells
set list listchars=tab:\|\ ,extends:▶,precedes:◀
if exists('&breakindent')
    set breakindent
endif
set backspace=indent,eol,start
set formatoptions=croqnj
set expandtab
set splitright splitbelow
set lazyredraw
if exists('+termguicolors')
    let &t_8f="\<Esc>[38;2;%lu;%lu;%lum"
    let &t_8b="\<Esc>[48;2;%lu;%lu;%lum"
    set termguicolors
endif
set textwidth=88
set colorcolumn=+1
set completeopt=menu,menuone,noinsert,noselect
" let g:gruvbox_contrast_dark = 'black'
silent! colo gruvbox
" highlight visual selections with only a slightly lighter background
hi Visual term=none cterm=none gui=none ctermbg=239
" centralize backups, swapfiles & undo history
set backupdir=~/.vim/backups directory=~/.vim/swaps
if exists("&undodir")
    set undodir=~/.vim/undo
endif


" === Custom commands ==================================================================
let mapleader = " "

" == Basic maps & commands
" better [[ / ]] behaviour -- make them work when using k&r-style curly brackets.
" TODO #finish: make these robust (eg. [[ when on a base-level {, either when outside a
"               block)
" nnoremap [[ 99[{
" nnoremap ]] 99[{%][%
" clear search highlighting
nnoremap \ :noh<cr>:<backspace>
" go to start/end of line
noremap H ^
noremap L $
" Y yanks to end of line, consistent with D & C
nnoremap Y y$
" easier-to-reach way of moving to the previous tabpage
noremap gy gT
" don't make { and } add to the jumplist
nnoremap <silent> } :<c-u>execute 'keepjumps norm! ' . v:count1 . '}'<cr>
nnoremap <silent> { :<c-u>execute 'keepjumps norm! ' . v:count1 . '{'<cr>
" easier saving & quitting
nnoremap <silent> <leader>j :update<cr>
nnoremap <silent> <leader>k :q<cr>
nnoremap <silent> <leader>l :x<cr>
" easy way to update the diff if in vimdiff mode
nnoremap du :diffupdate<cr>
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
" set current directory (all windows) to directory of current file
nnoremap <silent> <leader>cd :cd %:p:h<cr>
" quickly view a diff of unsaved changes
command! Diff execute 'w !git diff --no-index % -'
" for if you copy something in written in windows, adding an extra empty line for every
" real one
command! UnWindows execute ':g/^/+d'
" replace all instances of the keyword under the cursor.
nnoremap <leader>s :%s/\<<c-r><c-w>\>//g<left><left>
" strip trailing whitespace
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
" reload vimrc easily
" * extra :! is needed as for some reason sourcing the vimrc creates a ghost edit
noremap <silent> <leader>v :source $MYVIMRC<cr>:e!<cr>

" == Functions
" insert TODO comments above the current line, with tags defined by a:tag. NOTE: relies
" on the commentary plugin
function! Todo(tag)
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
function! OpenPDF()
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
    exec ':silent !gio open "' . pdfname . '" > /dev/null &'
    exec ':redraw!'
endfunction

function! TodoTick()
    let line = getline('.')
    let pos = col('.')
    if line =~ '.*\[[ ~]\].*'
        s/\[[ ~]\]/[x]/
    elseif line =~ '.*\[x\].*'
        s/\[x\]/[ ]/
    endif
    exec 'normal ' . pos . '|'
endfunction
noremap <silent> <leader>x :call TodoTick()<cr>

function! RenameFile()
    let old_name = expand('%')
    let new_name = input('New file name: ', expand('%'), 'file')
    if new_name != '' && new_name != old_name
        let old_alt = expand('#')
        exec ':saveas ' . new_name
        let @# = old_alt
        exec ':bd ' . bufnr(old_name)
        exec ':silent !rm ' . old_name
        redraw!
    endif
endfunction
map <leader>n :call RenameFile()<cr>

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


" === Autocommands =====================================================================
" apparently it's faster to group all your autocommands together in a group,
" that clears itself before adding its commands.
augroup my_autocmds
    au!

    " temporarily clear search highlighting when in insert mode.
    au insertenter * :set nohlsearch
    au insertleave * :set hlsearch

    " highlight trailing whitespace
    " -- some filetypes, like my python one, already highlight trailing whitespace and
    " -- this extra match messes that up
    let ft_blacklist = ['python']
    au vimenter * if index(ft_blacklist, &ft) < 0 | :match ErrorMsg '\s\+$'
    au bufenter * if index(ft_blacklist, &ft) < 0 | :match ErrorMsg '\s\+$'
    au winenter * if index(ft_blacklist, &ft) < 0 | :match ErrorMsg '\s\+$'

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
    au bufenter,winenter *.p8 setlocal filetype=lua
    au bufenter,winenter *.cls setlocal filetype=tex commentstring=\%\ %s

    " filetype-specific options
    au filetype cpp setlocal noet cinoptions=(0,u0,U0 comments^=:///
    au filetype haskell setlocal ts=4 sw=4 sts=4 et
    au filetype markdown,pandoc setlocal ts=4 sts=4 sw=4 et
    au filetype qmake setlocal commentstring=#%s
    au filetype typescript setlocal sw=2 sts=2 et

    " filetype-specific maps
    " fswitch  for switching between header/source files
    au filetype cpp,glsl noremap <silent> <leader>of :FSHere<cr>
    au filetype cpp,glsl noremap <silent> <leader>ol :FSSplitRight<cr>
    " 'compile' certain files (markdown, latex) TODO use :make
    au filetype markdown,pandoc noremap <f5> :!mdpdf "%" & disown<cr><cr>
    au filetype tex noremap <f5> :!xelatex "%"<cr><cr>
    " turn markdown into beamer slides (instead of normal latex doc)
    au filetype markdown,pandoc noremap <f6> :!mdsl "%" & disown<cr><cr>
    " turn markdown into report
    au filetype markdown,pandoc noremap <f7> :!mdrep "%"<cr><cr>
    " leader+o to open the corresponding pdf to this file
    au filetype markdown,tex,latex,pandoc noremap <silent> <leader>o :call OpenPDF()<cr>

    " vim-fswitch for shaders
    au bufenter,winenter *.vert let b:fswitchdst = 'frag'
    au bufenter,winenter *.vert let b:fswitchlocs = './'
    au bufenter,winenter *.frag let b:fswitchdst = 'vert'
    au bufenter,winenter *.frag let b:fswitchlocs = './'

    " extra syntax highlighting
    " normal aliases to primitive numeric types
    au syntax c,cpp syn keyword cType u8 u16 u32 u64 s8 s16 s32 s64 f32 f64
augroup END


" === Plugin config ====================================================================
" airline
set laststatus=2

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
let g:ale_cpp_cppcheck_options = '--enable=all --language=c++ --std=c++17 --force'
let g:ale_cpp_gcc_options = '--std=c++17 -Wall -Wextra -Wpedantic' " TODO set based on makefile
let g:ale_sign_column_always = 1

" goyo
let g:goyo_width = 89

" vim-tmux-navigator
let g:tmux_navigator_disable_when_zoomed = 1

" vim-lsc
let g:lsc_server_commands = {
\  'cpp': {
\    'command': 'ccls',
\    'log_level': -1,
\    'suppress_stderr': v:true,
\  },
\  'rust': {
\    'command': 'rls',
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

