# === Start ============================================================================
# if there's an automatically generated bashrc with stuff in it
if [ -f ~/dotfiles/bashrc.auto ]; then
    . ~/dotfiles/bashrc.auto
fi

# === Aliases ==========================================================================
alias l='ls -GF'
alias la='ls -AGF'
alias ll='ls -lhAGF'
alias c=clear
alias cl='c && l'
alias cll='c && ll'
alias xcl='xclip -sel clip'
alias v=vim
alias g=git
alias gs='git status'

alias qm='qmake -spec linux-g++ CONFIG+=debug CONFIG+=qml_debug'
alias tma="tmux attach -t"
# there's already a fd on ubuntu
alias fd='fdfind'
# rg in c(++) code only
alias rgc="rg -g '*.{c,cpp,cc,C,cxx,h,hpp,hh,H,hxx}'"
# quick name for ranger (and when it exits, bash gets put into what ranger's directory was)
alias ra='ranger --choosedir=$HOME/.local/share/ranger/current_dir; cd "$(cat $HOME/.local/share/ranger/current_dir)"'
alias rf=rifle
# python 2 :'(((
alias python='/usr/bin/env python3'
alias pip='/usr/bin/env pip3'
# ssh tries to inherit my weird custom TERM, so need to stop it from doing that.
#alias ssh='TERM=xterm ssh'
# update flatpaks
alias fpu='flatpak update -y && flatpak uninstall --unused -y'

# quickly list tagged todo comments as made by the corresponding vimrc functions
alias todos='grep -EInr "\s*(#|//|/\*|\"|<!--)\sTODO\s*#"'

# === Functions ========================================================================
mkcd () { mkdir -p "$@" && cd "$@"; }

# move 'up' so many directories instead of using several cd ../../, etc.
up () { cd $(eval printf '../'%.0s {1..$1}); }

# make a note
note () {
    case $1 in
        *.md) vim "+set nospell" "+Goyo" "$1"                 ;;
        "")   vim "+set filetype=pandoc nospell" "+Goyo"      ;;
        *)    vim "+set filetype=pandoc nospell" "+Goyo" "$1" ;;
    esac
}

# easy way to extract archives
extract () {
    [ ! -f "$1" ] && echo "'$1' is not a valid file!" && return 1

    case "$1" in
        *.tar.bz2)   tar xvjf "$1"    ;;
        *.tar.gz)    tar xvzf "$1"    ;;
        *.bz2)       bunzip2 "$1"     ;;
        *.rar)       unrar x "$1"     ;;
        *.gz)        gunzip "$1"      ;;
        *.tar)       tar xvf "$1"     ;;
        *.tbz2)      tar xvjf "$1"    ;;
        *.tgz)       tar xvzf "$1"    ;;
        *.zip)       unzip "$1"       ;;
        *.Z)         uncompress "$1"  ;;
        *.7z)        7z x "$1"        ;;
        *)           echo "don't know how to extract '$1'..." ;;
    esac
}

# quick way to do simple compilations & run, for small bits of (normally) test code.
mkrn () {
    case ${1##*.} in
       C)   g++ -Wall -g -std=c++17 -o ${1%.*} "$1" && ./${1%.*} ;;
       c)   gcc -Wall -g            -o ${1%.*} "$1" && ./${1%.*} ;;
       cc)  g++ -Wall -g -std=c++17 -o ${1%.*} "$1" && ./${1%.*} ;;
       cpp) g++ -Wall -g -std=c++17 -o ${1%.*} "$1" && ./${1%.*} ;;
       cxx) g++ -Wall -g -std=c++17 -o ${1%.*} "$1" && ./${1%.*} ;;
       hs)  ghc --make ${1%.*} && ./${1%.*}        ;;
       js)  node "$1"                              ;;
       py)  python "$1"                            ;;
       rs)  rustc "$1" && ./${1%.*}                ;;
       *)   [[ -f "Cargo.toml" ]] && cargo run || echo "unknown filetype '${1##*.}'." ;;
    esac
}

# get size of current directory (and size of constituent directories).
# by default also lists the top 25 constituent directories. can give it a number
# argument to list that many directories, or 'all', to list every constituent directory.
size () {
    [ $# -ge 1 ] && size=$1 || size=25

    if [ $size == "all" ] ; then
        du -ahd1 | sort -hr
    else
        du -ahd1 | sort -hr | head -n $((size+1))
    fi
}

# === Environment Variables ============================================================
COLORTERM=truecolor
VISUAL=vim; export VISUAL EDITOR=vim; export EDITOR
# add color in less (for manpages)
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'
# my scripts
export PATH=$PATH:~/.bin
# prompt
export PS1="\[\e[m\]\[\e[33m\]\w\[\e[36m\] $\[\e[m\] "
# other stuff
export HISTSIZE=100000

# === Other -- End =====================================================================
# when terminal is frozen by ^s, allow unfreezing with any key.
[[ $- == *i* ]] && stty ixany

# source other files (eg. for setup-specific stuff, or for external programs)
for f in $(find ~/dotfiles/bash -type f) ; do source $f ; done
