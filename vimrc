set nocompatible


" === Plugins ==========================================================================
call plug#begin('~/.vim/bundle')

" appearance
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
Plug 'arp242/jumpy.vim'
Plug 'bronson/vim-visual-star-search'
Plug 'machakann/vim-swap'
Plug 'michaeljsmith/vim-indent-object'
Plug 'ojroques/vim-oscyank', { 'branch': 'main' }
Plug 'tpope/vim-commentary'
Plug 'tpope/vim-surround'
" ide
Plug 'ajh17/VimCompletesMe'
Plug 'junegunn/fzf', { 'dir': '~/src/bin/fzf', 'do': './install --bin' }
Plug 'junegunn/fzf.vim'
Plug 'autozimu/LanguageClient-neovim', { 'branch': 'next', 'do': 'bash install.sh' }
Plug 'scrooloose/nerdtree', { 'on': 'NERDTreeToggle' }
" background
Plug 'andymass/vim-matchup'
Plug 'christoomey/vim-tmux-navigator'
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
set ttymouse=sgr
set showcmd
set nostartofline
set wildmenu wildmode=list:longest,full
set autoread
set nofoldenable
set binary noendofline
set encoding=utf-8 nobomb
set noerrorbells
set laststatus=2  " (needed by airline)
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
    set termguicolors
endif
set textwidth=88
set colorcolumn=+1
set completeopt=menu,menuone,noinsert,noselect
set shortmess+=F
silent! colo gruvbox
" highlight visual selections with only a slightly lighter background
" TODO #bug: gruvbox hard-coded
hi Visual term=none cterm=none gui=none ctermbg=239 guibg=#3c3836
" centralize backups, swapfiles & undo history
set backupdir=$XDG_STATE_HOME/vim/backups directory=$XDG_STATE_HOME/vim/swaps
if exists("&undodir")
    set undofile
    set undodir=$XDG_STATE_HOME/vim/undo
endif
set viminfofile=$XDG_STATE_HOME/vim/viminfo
" set switchbuf+=usetab,newtab  " testing out, mostly for quickfix window (lsc 'FindReferences')
set nrformats-=octal
set sidescrolloff=5
let &t_ut=''


" === Custom commands ==================================================================
nnoremap <space> <nop>
let mapleader = " "
let maplocalleader = "  "

" == Basic maps & commands
" better [[ / ]] behaviour -- make them work when using k&r-style curly brackets.
" TODO #finish: make these robust (eg. [[ when on a base-level {, either when outside a
"               block). prob easiest to do via [m etc., with an `if` for 'class' case
" nnoremap [[ 99[{
" nnoremap ]] 99[{%][%
" clear search highlighting & any messages in command line
nnoremap \ :noh<cr>:<backspace>
" go to start/end of line
noremap H ^
noremap L $
" Y yanks to end of line, consistent with D & C
nnoremap Y y$
" easier-to-reach way of switching tabs
noremap gy gT
" don't make { and } add to the jumplist
nnoremap <silent> } :<c-u>execute 'keepjumps norm! ' . v:count1 . '}'<cr>
nnoremap <silent> { :<c-u>execute 'keepjumps norm! ' . v:count1 . '{'<cr>
" easier saving & quitting
nnoremap <silent> <leader>j :silent update<cr>
nnoremap <silent> <leader>k :silent q<cr>
nnoremap <silent> <leader>l :silent x<cr>
nnoremap <silent> <leader>K :silent qa<cr>
nnoremap <silent> <leader>L :silent xa<cr>
nnoremap <silent> <leader>J :silent tabc<cr>
" easy way to update the diff if in vimdiff mode
nnoremap du :diffupdate<cr>
" set current directory (all windows) to directory of current file
nnoremap <silent> <leader>cd :cd %:p:h<cr>
" quickly view a diff of unsaved changes
command! Unsaved execute 'w !git diff --no-index % -'
nnoremap <leader>u :Unsaved<cr>
" for if you copy something in written in windows, adding an extra empty line for every
" real one
command! UnWindows execute ':g/^/+d'
" replace all instances of the keyword under the cursor.
nnoremap <leader>s :%s/\<<c-r><c-w>\>//g<left><left>
nnoremap <leader>S :%s/<c-r><c-a>//g<left><left>
" strip trailing whitespace
nnoremap <silent> <leader>w :let _s=@/ <bar> :%s/\s\+$//e <bar> :let @/=_s<cr>
" fzf, for finding files & text
noremap <leader>f :Files<cr>
noremap <leader>r :Rg<cr>
" alternate to :Rg, that doesn't match on filename (but still prints it)
command! -bang -nargs=* RgContents call fzf#vim#grep("rg --column --line-number --no-heading --color=always --smart-case ".shellescape(<q-args>), 1, {'options': '--delimiter : --nth 4..'}, <bang>0)
noremap <leader>R :RgContents<cr>
" repeat the last macro
nnoremap Q @@
" make j & k move by wrapped lines, unless given a count -- aka. 10j still goes down 10
" 'true' lines
nnoremap <expr> k (v:count == 0 ? 'gk' : 'k')
nnoremap <expr> j (v:count == 0 ? 'gj' : 'j')
vnoremap <expr> k (v:count == 0 ? 'gk' : 'k')
vnoremap <expr> j (v:count == 0 ? 'gj' : 'j')
" toggle NERDTree
noremap <silent> <f3> :NERDTreeToggle<cr>
" reload vimrc easily
" * extra :e! is needed as for some reason sourcing the vimrc adds an empty unsaved edit
noremap <silent> <leader>v :source $MYVIMRC<cr>:e!<cr>

" == Functions
" system clipboard access with Ctrl+C/P:
" NOTE: this is a function executed below in a `vimenter` autocmd, because otherwise it
" would run before plugins had loaded so we wouldn't be able to check for vim-oscyank
function! SetupSystemClipboard()
    if exists('g:loaded_oscyank')
        " use osc 52 escape code (only supported in some terminals)
        vnoremap <c-c> :OSCYankVisual<cr>:<backspace>
    elseif has("clipboard")
        " use built-in system clipboard support
        vnoremap <c-c> "+y
        noremap <c-p> "+p
    elseif executable("xsel") && system("xsel") !~ 'Can''t open display'
        " use the (external) xsel package (can only copy whole lines)
        vnoremap <c-c> :w !xsel -i -b<cr><cr>
        noremap <c-p> :r !xsel -o -b<cr><cr>
    else
        " <c-u> removes the automatically added '<,'> that'd make the `echo` error
        vnoremap <c-c> :<c-u>echo 'no known system clipboard access'<cr>
    endif
endfunction

" insert TODO comments above the current line, with tags defined by a:tag. NOTE: relies
" on the commentary plugin
function! Todo(tag)
    exec "normal O"
    exec "normal ccTODO #".a:tag
    Commentary
    exec "normal $F#El"
endfunction

nnoremap <leader>tbg :call Todo("bug")<cr>
nnoremap <leader>tcl :call Todo("cleanup")<cr>
nnoremap <leader>tcr :call Todo("correctness")<cr>
nnoremap <leader>tdc :call Todo("documentation")<cr>
nnoremap <leader>ten :call Todo("enhancement")<cr>
nnoremap <leader>tft :call Todo("feature")<cr>
nnoremap <leader>tfn :call Todo("finish")<cr>
nnoremap <leader>trf :call Todo("refactor")<cr>
nnoremap <leader>trb :call Todo("robustness")<cr>
nnoremap <leader>trm :call Todo("remove")<cr>
nnoremap <leader>tsp :call Todo("speed")<cr>
nnoremap <leader>ttm :call Todo("temp")<cr>
nnoremap <leader>tts :call Todo("test")<cr>
nnoremap <leader>tvf :call Todo("verify")<cr>

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
command! Errors :call ToggleLocList()
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
    redraw!
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

" custom function to style folds
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

" custom function to style the tab line
" TODO #bug: gruvbox hard-coded
hi TabLineNr ctermfg=214 ctermbg=237 guifg=#fabd2f guibg=#3c3836 cterm=bold
hi TabLineModified ctermfg=109 ctermbg=237 guifg=#83a598 guibg=#3c3836 cterm=bold
function! Tabline()
    let s = ''
    for i in range(tabpagenr('$'))
        let tab = i + 1
        let winnr = tabpagewinnr(tab)
        let buflist = tabpagebuflist(tab)
        let bufnr = buflist[winnr - 1]
        let bufname = bufname(bufnr)
        let bufmodified = getbufvar(bufnr, "&mod") ? '+' : ''
        let tabbodycol = (tab == tabpagenr() ? '%#TabLineSel#' : '%#TabLine#')

        let s .= tabbodycol
        let s .= '['
        let s .= '%' . tab . 'T'
        let s .= '%#TabLineNr#' .  tab
        let s .= '%#TabLineModified#' . bufmodified . ' '
        let s .= tabbodycol
        let s .= (bufname != '' ? fnamemodify(bufname, ':t') : '[No Name] ')

        let s .= '] '
    endfor

    let s .= '%#TabLineFill#'
    let s .= '%=%999XX'
    return s
endfunction
set tabline=%!Tabline()

" TODO #cleanup: separate (into a plugin?)
function! ToPrevLoc()
    " TODO #cleanup: want(ed) to move back to the previous file in the jumplist that
    " isn't the current one. prob best to do by parsing the jumplist directly; however,
    " :jumps has a 'file/text' column, which has the either text of the line to jump to
    " (if it's in the current file), or the name of the file to jump to. could just look
    " for when that column has a valid filename, but you could have a case (unlikely)
    " where the text of the line to jump to in the current file also happens to be a
    " valid filename. you do get row & column numbers too so you could check that if the
    " file/text is a valid filename, it's not also the contents of that row/col in the
    " current file, but that only makes a clash less likely.
    "
    " can't use `:e #` since consecutive uses of `ToPrevLoc()` would give incorrect
    " results.
    "
    " getjumplist() from patch 8.0.1497 might make this easier.
    "
    " actually, sometimes you *do* want to move back to the previous jump in the same
    " file: eg. `FindReferences -> go to a result in current file -> Shunt*`. you'd
    " want a window at the location of the reference to be shunted, but for the revealed
    " 'underneath' position to be where you ran `FindReferences` from, which is in the
    " same file. maybe the best heuristic is to do ^o until *something* changes, since
    " the most annoying case is where there's a kind of 'ghost' jump at the top of the
    " list, so doing ^o does nothing.

    " TODO #enhancement: use winsaveview()/winloadview() to keep the viewport the same?
    "
    " not sure if we can do that simply -- the state we want will be from the place
    " we've already moved from once we call Shunt. could continuously record window
    " states, but bleh
    "
    " maybe should just record continuously, since it'd be nice to store viewport info
    " with the jumplist in general, to improve ^o & ^i.

    " TODO #enhancement: this also gets rid of undo history.
    "
    " maybe the answer is just to make it persistent, with `set undofile undodir`
    :execute "normal! \<c-o>"
endfunction
function! ToPrevFile()
    let l:current_file = expand('%:p')
    let l:new_file = l:current_file

    " keep jumping back until the current filename changes
    while l:new_file == l:current_file
        :call ToPrevLoc()
        let l:new_file = expand('%:p')
        if match(execute(':jumps', 'silent!'), 'file/text\n>') != -1
            " reached the end of the jumplist
            break
        end
    endwhile
endfunction

" TODO #finish: add an option, for whether to focus on the shunted or underlying window?
function! ShuntRight()
    vsplit
    if &splitright
        execute "normal! \<c-w>h"
    endif
    call ToPrevLoc()
endfunction

function! ShuntLeft()
    vsplit
    if !&splitright
        execute "normal! \<c-w>l"
    endif
    call ToPrevLoc()
endfunction

function! ShuntDown()
    split
    if &splitbelow
        execute "normal! \<c-w>k"
    endif
    call ToPrevLoc()
endfunction

function! ShuntUp()
    split
    if !&splitbelow
        execute "normal! \<c-w>j"
    endif
    call ToPrevLoc()
endfunction

function! ShuntTab()
    let l:p = getpos('.')
    let l:curr_win = win_getid()

    tabedit %

    call setpos('.', [0, l:p[1], l:p[2], l:p[3]])
    call win_gotoid(l:curr_win)

    call ToPrevLoc()
endfunction

nnoremap <leader><c-o> :call ToPrevFile()<cr>
nnoremap <leader><c-h> :call ShuntLeft()<cr>
nnoremap <leader><c-l> :call ShuntRight()<cr>
nnoremap <leader><c-j> :call ShuntDown()<cr>
nnoremap <leader><c-k> :call ShuntUp()<cr>
nnoremap <leader><c-t> :call ShuntTab()<cr>

" == Disabled commands
" Ctrl+Z -> background the vim process
nnoremap <c-z> <nop>
" Ctrl+\ -> evaluate expression, replace the whole command line with the result
"           (i currently use this as my tmux prefix)
nnoremap <c-\> <nop>


" === Autocommands =====================================================================
" apparently it's faster to group all your autocommands together in a group,
" that clears itself before adding its commands.
augroup my_autocmds
    au!

    " set some filetypes
    au vimenter,bufenter,winenter ~/notes/* setlocal filetype=pandoc
    au vimenter,bufenter,winenter *.p8 setlocal filetype=lua
    au vimenter,bufenter,winenter *.cls setlocal filetype=tex commentstring=\%\ %s
    au vimenter,bufenter,winenter *.inc setlocal filetype=cpp
    au vimenter,bufenter,winenter *.gdb setlocal filetype=gdb

    " TODO #test: keep the viewport when reloading a file
    " https://stackoverflow.com/a/4255960
    au filechangedshell     * let b:wpos = winsaveview()
    au filechangedshellpost * if(exists('b:wpos')) | call winrestview(b:wpos) | endif

    " temporarily clear search highlighting when in insert mode.
    au insertenter * :set nohlsearch
    au insertleave * :set hlsearch

    " highlight trailing whitespace
    " (note: some syntax plugins try to do this too, so remember to disable it for them)
    au vimenter,bufenter,winenter * :match ErrorMsg '\s\+$'

    " filetype-specific options
    " TODO #temp: only set in graphcore.vim
    " au filetype cpp setlocal noet cinoptions=(0,u0,U0 comments^=:///
    au filetype haskell setlocal ts=4 sw=4 sts=4 et
    au filetype markdown,pandoc setlocal ts=4 sts=4 sw=4 et spellcapcheck=
    au filetype qmake setlocal commentstring=#%s
    au filetype typescript setlocal sw=2 sts=2 et
    au filetype log setlocal cursorline

    " filetype-specific maps
    " fswitch for switching between header/source files
    au filetype cpp,glsl noremap <silent> <leader>of :FSHere<cr>
    au filetype cpp,glsl noremap <silent> <leader>oh :FSSplitLeft<cr>
    au filetype cpp,glsl noremap <silent> <leader>ol :FSSplitRight<cr>
    au filetype cpp,glsl noremap <silent> <leader>ok :FSSplitAbove<cr>
    au filetype cpp,glsl noremap <silent> <leader>oj :FSSplitBelow<cr>
    au filetype cpp,glsl noremap <silent> <leader>ot :FSTab<cr>
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

    " set up ability to copy to the system clipboard
    au vimenter * call SetupSystemClipboard()
augroup end


" === Plugin config ====================================================================
" vim-pandoc
let g:pandoc#modules#disabled = ["folding"]
let g:pandoc#keyboard#display_motions = 0  " this messes with my j & k maps

" goyo
let g:goyo_width = 89

" vim-tmux-navigator
let g:tmux_navigator_disable_when_zoomed = 1

" LanguageClient-neovim
function! s:on_lsp_buffer_enabled() abort
    if has_key(g:LanguageClient_serverCommands, &filetype)
        echo 'hello world'

        set formatexpr=LanguageClient#textDocument_rangeFormatting_sync()
        nmap <buffer> gd <plug>(lcn-definition)
        " nmap <buffer> gs <plug>(lcn-document-symbol-search)
        " nmap <buffer> gS <plug>(lcn-workspace-symbol-search)
        nmap <buffer> gr <plug>(lcn-references)
        nmap <buffer> gI <plug>(lcn-implementation)
        nmap <buffer> gR <plug>(lcn-rename)
        nmap <buffer> <c-n> <plug>(lcn-diagnostics-next)
        nmap <buffer> <c-p> <plug>(lcn-diagnostics-previous)
        " nmap <buffer> gm <plug>(lcn-signature-help)
        nmap <buffer> K <plug>(lcn-hover)
    endif
endfunction
" call s:on_lsp_buffer_enabled()

augroup lsp_install
    au!
    " call s:on_lsp_buffer_enabled only for languages that has the server registered.
    au filetype * call s:on_lsp_buffer_enabled()
"     au User LanguageClientStarted call s:on_lsp_buffer_enabled()
augroup END

let g:LanguageClient_serverCommands = {
\  'cpp': [ 'clangd', '--limit-references=0', '--background-index' ],
\  'python': [ 'pylsp' ],
\}


" i already highlight trailing whitespace, & this messes it up
" (for the 'vim-python/python-syntax' plugin used by vim-polyglot)
let g:python_highlight_space_errors = v:false

" vim-oscyank
let g:oscyank_silent = v:true
let g:oscyank_term = 'default'


" === Local config =====================================================================
" `personal{-local}` is a symlink to `dotfiles/{local/}vim`
runtime! personal/**/*.vim
runtime! personal-local/**/*.vim
