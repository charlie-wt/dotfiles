# === Init =============================================================================
# export dotfiles dir as directory ~/.bashrc is symlinked into
export DOTFILES=$(dirname "$(readlink -f ~/.bashrc)")

# source automatically generated bashrc if there is one
[ -f $DOTFILES/bashrc.auto ] && source $DOTFILES/bashrc.auto

source $DOTFILES/bash/_utils.bash


# === Environment Variables ============================================================
# xdg vars
export XDG_CACHE_HOME="$HOME/.cache"
export XDG_CONFIG_HOME="$HOME/.config"
export XDG_DATA_HOME="$HOME/.local/share"
export XDG_STATE_HOME="$HOME/.local/state"

# add user bin dirs to PATH if they exist
[ -d "$(bin-home)" ] && PATH="$(bin-home):$PATH"

# add color in less (for manpages)
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# other
export PS1="\[\e[m\]\[\e[33m\]\w\[\e[36m\] $\[\e[m\] "
export COLORTERM=truecolor
export VISUAL=vim EDITOR=vim


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
alias gd='git diff'
alias gdc='git dc'
alias gdb='gdb -q'

alias qm='qmake -spec linux-g++ CONFIG+=debug CONFIG+=qml_debug'
alias tma="tmux attach -t"
# there's already a fd on ubuntu
alias fd='fdfind'
# rg in c(++) code only
alias rgc="rg -g '*.{c,cpp,cc,C,cxx,h,hpp,hh,H,hxx}'"
# quick name for ranger (and when it exits, bash gets put into wherever ranger was)
alias ra='. ranger'
alias rf=rifle
# update flatpaks
alias fpu='flatpak update -y && flatpak uninstall --unused -y'

# TODO #temp: need to explicitly tell sudo to keep $TERMINFO, to keep xterm-kitty;
# without it, exiting vim won't clear the screen of it properly. doing `sudo visudo` and
# adding `Defaults env_keep += "TERM TERMINFO"` works for `sudo vim`, but not `sudo -E
# vim`.
alias sv='sudo -E TERMINFO="$TERMINFO" vim'


# === Functions ========================================================================
mkcd () { mkdir -p "$@" && cd "$@"; }

cdc () { cd "$(config-home)/$1"; }

# go to dotfiles dir, or install them
dots () {
    case $1 in
        i|install) $DOTFILES/install "${@:2}" ;;
        "")        cd $DOTFILES               ;;
        *)         >&2 echo ?                 ;;
    esac
}

# `up 3` == `cd ../../..`
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
       c)             gcc -Wall -g            -o "${1%.*}" "${@:2}" "$1" && ./${1%.*} ;;
       C|cc|cpp|cxx)  g++ -Wall -g -std=c++17 -o "${1%.*}" "${@:2}" "$1" && ./${1%.*} ;;
       hs)            ghc --make ${1%.*} && ./${1%.*} "${@:2}"             ;;
       js)            node "$@"                                            ;;
       py)            python3 "$@"                                         ;;
       rs)            rustc "$1" && ./${1%.*} "${@:2}"                     ;;
       *)
           [[ -f "Cargo.toml" ]] && cargo run || echo "unknown filetype '${1##*.}'." ;;
    esac
}

# get size of current directory (and size of constituent directories).
# $1: number of constituent directories to list, or `all` for all of them. Optional;
#     defaults to 25.
# NOTE: suppresses error messages, since they're usually 'permission denied' clutter
size () {
    [ $# -ge 1 ] && local size=$1 || local size=25

    if [ $size == "all" ] ; then
        du -ahd1 2>/dev/null | sort -hr
    else
        du -ahd1 2>/dev/null | sort -hr | head -n $((size+1))
    fi
}

# quickly list tagged todo comments as made by the corresponding vimrc functions.
# $1 : specific tag to search for (optional; defaults to all tags)
todos () {
    [ $# -ge 1 ] && local tag="$1" || local tag="\w+"

    have-cmd rg && local cmd=rg || local cmd="grep -EInr --color=auto"

    $cmd "(#|//|/\*|\"|<!--|--|;)\sTODO\s*#$tag\b" ${@:2}
}


# === Other ============================================================================
# when terminal is frozen by ^s, allow unfreezing with any key.
[[ $- == *i* ]] && stty ixany


# === End ==============================================================================
# source other files (eg. for setup-specific stuff, or for external programs)
for f in $(find $DOTFILES/bash -maxdepth 1 -type f) ; do source $f ; done
# explicitly source machine-local files afterwards, so they can override earlier config
[[ -d $DOTFILES/local/bash ]] && \
    for f in $(find $DOTFILES/local/bash/ -maxdepth 1 -type f) ; do source $f ; done
