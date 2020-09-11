# if there's an automatically generated bashrc with stuff in it
if [ -f ~/dotfiles/.bashrc.auto ]; then
    . ~/dotfiles/.bashrc.auto
fi

### MY STUFF ###
# when terminal is frozen by ^s, allow unfreezing with any key.
[[ $- == *i* ]] && stty ixany

## aliases:
# rifle (open file with suitable program; comes from ranger)
alias rf=rifle
# quick name for ranger (and when it exits, bash gets put into what ranger's directory was)
alias ra='ranger --choosedir=$HOME/.local/share/ranger/current_dir; cd $(cat $HOME/.local/share/ranger/current_dir)'
# why is python 2 the default anywhere any more
alias python=/usr/bin/python3
alias pip=/usr/bin/pip3
# shorter clear
alias c=clear
# clear & ls
alias cl='clear && ls'
# qmake
alias qm='qmake -spec linux-g++ CONFIG+=debug CONFIG+=qml_debug'
# xclip into system (ctrl+c/v) clipboard
alias xcl='xclip -sel clip'
# vim
alias v=vim
# git
alias g=git
# quickly list tagged todo comments as made by the corresponding vimrc functions
alias todos='grep -EInr "\s*(#|//|/\*|\"|<!--)\sTODO\s*#"'
# edit the shelf
alias shelf='vim ~/Documents/shelf.md'
# there's already a fd on ubuntu
alias fd='fdfind'
# rg in c(++) code only
alias rgc="rg -g '*.{c,cpp,cc,C,cxx,h,hpp,hh,H,hxx}'"
## my scripts:
export PATH=$PATH:~/.bin
# pip stuff
export PATH=$PATH:~/.local/bin

## functions:
mkcd () { mkdir "$@" && cd "$@"; }
# Easy way to extract archives
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

# make a note
note () {
    case $1 in
        *.md) vim "+set nospell" "+Goyo" "$1"                 ;;
        "")   vim "+set filetype=pandoc nospell" "+Goyo"      ;;
        *)    vim "+set filetype=pandoc nospell" "+Goyo" "$1" ;;
    esac
}

# Quick way to do simple compilations & run, for small bits of (normally) test code.
mkrn () {
    case ${1##*.} in
       C)   g++ -Wall -o ${1%.*} "$1" && ./${1%.*} ;;
       c)   gcc -Wall -o ${1%.*} "$1" && ./${1%.*} ;;
       cc)  g++ -Wall -o ${1%.*} "$1" && ./${1%.*} ;;
       cpp) g++ -Wall -o ${1%.*} "$1" && ./${1%.*} ;;
       cxx) g++ -Wall -o ${1%.*} "$1" && ./${1%.*} ;;
       hs)  ghc --make ${1%.*} && ./${1%.*}        ;;
       js)  node "$1"                              ;;
       py)  python "$1"                            ;;
       *)   echo "unknown filetype '${1##*.}'."    ;;
    esac
}

# Move 'up' so many directories instead of using several cd ../../, etc.
up () { cd $(eval printf '../'%.0s {1..$1}); }

# basically an alias
gip () { get-iplayer --modes=best --pid=$1; }

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

# edit this month's goals
goals () {
    dirname=~/goals
    fulldirname=~/Documents/goals/$(date +%Y)

    if [ ! -L $dirname ] ; then
        if [ ! -d $fulldirname ] ; then
            mkdir $fulldirname
            [ -d ~/Documents/goals/year ] && cp ~/Documents/goals/year/* $fulldirname
        fi

        ln -s $fulldirname $dirname
    elif [ ! "$(readlink $dirname)" -ef "$fulldirname" ] ; then
        rm $dirname && ln -s $fulldirname $dirname
    fi

    fname=$dirname/$(date +%B | tr A-Z a-z).md
    template_name=$dirname/_month.md

    [ ! -f $fname ] && [ -f $template_name ] && cp $template_name $fname

    vim $fname
}

## environment variables:
COLORTERM=truecolor
VISUAL=vim; export VISUAL EDITOR=vim; export EDITOR
# Add color in less (for manpages)
export LESS_TERMCAP_mb=$'\E[01;31m'
export LESS_TERMCAP_md=$'\E[01;31m'
export LESS_TERMCAP_me=$'\E[0m'
export LESS_TERMCAP_se=$'\E[0m'
export LESS_TERMCAP_so=$'\E[01;44;33m'
export LESS_TERMCAP_ue=$'\E[0m'
export LESS_TERMCAP_us=$'\E[01;32m'

# source files created for other software (to get completion, for example)
for f in $(ls -A ~/dotfiles/tools) ; do source ~/dotfiles/tools/$f ; done
