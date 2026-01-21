# === Init =============================================================================
# only run if in an interactive terminal
[[ "$-" == *i* ]] || return

export DOTFILES="$(dirname "$(readlink -e "$BASH_SOURCE")")"  # directory of this script
source "$DOTFILES/bash/_utils.bash"


# === Environment Variables ============================================================
# xdg
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

# history
export HISTSIZE=100000
export HISTFILESIZE=$HISTSIZE
# don't put duplicate lines or lines starting with space in the history.
export HISTCONTROL=ignoreboth

[ "$(whoami)" == root ] && pref="\[\e[31m\](\u) " || pref=""
export PS1="\[\e[m\]$pref\[\e[33m\]\w\[\e[36m\] $\[\e[m\] "
unset pref
export COLORTERM=truecolor
export VISUAL=vim EDITOR=vim


# === Aliases ==========================================================================
alias ls='ls --color=auto'
alias l='ls -GF'
alias la='ls -AGF'
alias ll='ls -lhAGF'
alias c=clear
alias cl='c && l'
alias cll='c && ll'
alias v=vim
alias g=git
alias gs='git status'
alias gd='git diff'
alias gdc='git dc'
alias gdb='gdb -q'
alias grep='grep --color=auto'

alias qm='qmake -spec linux-g++ CONFIG+=debug CONFIG+=qml_debug'
alias tma="tmux attach -t"
# there's already a fd in apt
have-cmd fdfind && alias fd='fdfind'
# rg for certain filetypes
alias rgc="rg -g '*.{c,cpp,cc,C,cxx,h,hpp,hh,H,hxx}'"
alias rgp="rg -g '*.py'"
# quick name for ranger (and when it exits, bash gets put into wherever ranger was)
alias ra='. ranger'
alias rf=rifle
# update flatpaks
alias fpu='flatpak update -y ; flatpak uninstall --unused -y'
# update cargo packages
alias cgu="cargo install \$(cargo install --list | awk '/:$/ { print \$1; }')"
# push a new branch to `origin`
alias push-branch='git push --set-upstream origin "$(git branch --show-current)"'
# copy stdin to system clipboard using osc-52
alias osc='printf "\033]52;c;$(printf "$(cat -)" | base64)\a"'

# need to explicitly tell sudo to keep $TERMINFO, to keep xterm-kitty; without it,
# exiting vim won't clear the screen of it properly. doing `sudo visudo` and adding
# `Defaults env_keep += "TERM TERMINFO"` works for `sudo vim`, but not `sudo -E vim`.
alias se='sudo -E TERMINFO="$TERMINFO"'


# === Functions ========================================================================
mkcd () { mkdir -p "$@" && cd "$@"; }

cdc () { cd "$(config-home)/$1"; }

__cdc_completion () {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local dirs="$(find "$(config-home)" -maxdepth 1 -mindepth 1 -type d -printf "%f\n")"
    COMPREPLY=($(compgen -W "$dirs" -- "${cur}"))
}
complete -F __cdc_completion cdc

# go to dotfiles dir, or install them
dots () {
    case $1 in
        i|install) "$DOTFILES/install" ${@:2} ;;
        "")        cd "$DOTFILES"             ;;
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
    [ ! -f "$1" ] && >&2 echo "'$1' is not a valid file!" && return 1

    case "$1" in
        *.7z)        7z x "$1"        ;;
        *.Z)         uncompress "$1"  ;;
        *.tar.bz2)   tar xvjf "$1"    ;;
        *.tar.gz)    tar xvzf "$1"    ;;
        *.bz2)       bunzip2 "$1"     ;;
        *.gz)        gunzip "$1"      ;;
        *.rar)       unrar x "$1"     ;;
        *.tar)       tar xvf "$1"     ;;
        *.tbz2)      tar xvjf "$1"    ;;
        *.tgz)       tar xvzf "$1"    ;;
        *.whl)       unzip "$1"       ;;
        *.zip)       unzip "$1"       ;;
        *)           >&2 echo "don't know how to extract '$1'..." ;;
    esac
}

# quick way to do simple compilations & run, for small bits of (normally) test code.
mkrn () {
    case ${1##*.} in
       c)             gcc -Wall -ggdb3 -Og            -o "${1%.*}" ${@:2} "$1" && ./"${1%.*}" ;;
       C|cc|cpp|cxx)  g++ -Wall -ggdb3 -Og -std=c++20 -o "${1%.*}" ${@:2} "$1" && ./"${1%.*}" ;;
       hs)            ghc -Wall --make "${1%.*}" && ./"${1%.*}" ${@:2}  ;;
       js)            node "$@"                                         ;;
       py)            python3 "$@"                                      ;;
       rs)            rustc "$1" && ./"${1%.*}" ${@:2}                  ;;
       *)
           [ -f "Cargo.toml" ] && cargo run || >&2 echo "unknown filetype '${1##*.}'." ;;
    esac
}

# get size of current directory (and size of constituent directories).
# $1: (optional) number of constituent directories to list, or `all` for all of them.
#     defaults to 25.
# NOTE: suppresses error messages, since they're usually 'permission denied' clutter
size () {
    [ $# -ge 1 ] && local size="$1" || local size=25

    if [ $size == "all" ] ; then
        du -ahd1 2>/dev/null | sort -hr
    else
        du -ahd1 2>/dev/null | sort -hr | head -n $((size+1))
    fi
}

# quickly list tagged todo comments as made by the corresponding vimrc functions.
# $1: (optional) specific tag to search for. defaults to all tags.
todos () {
    [ $# -ge 1 ] && local tag="$1" || local tag="\w+"

    have-cmd rg && local cmd=rg || local cmd="grep -EInr --color=auto"

    $cmd "(#|//|/\*|\"|<!--|--|;)\sTODO\s*#$tag\b" ${@:2}
}

# checkout a github pull request.
# $1: pull request index.
# $2: (optional) name of local branch to make. defaults to `pr-$1`.
# $3: (optional) name of remote to pull from. defaults to `upstream`, if not `origin`.
pr () {
    [ -z "$1" ] && >&2 error "please provide a pull request index." && return 1

    local idx="$1"
    local branch_name="${2:-pr-$idx}"
    local default_remote=upstream
    [ -z "$(git remote | grep "$default_remote")" ] && default_remote=origin
    # TODO #cleanup: is there a way to do this?
    # git remote | grep -q "$default_remote" && default_remote=origin
    local remote="${3:-$default_remote}"

    git fetch "$remote" pull/"$idx"/head:"$branch_name" && git checkout "$branch_name"
}

# get the location of coredumps
dumploc () {
    local corepat="/proc/sys/kernel/core_pattern"
    # check if coredumps are disabled
    [ ! -f "$corepat" ] || [ "$(wc -l "$corepat")" = 0 ] && [ "$(cat /proc/sys/kernel/core_uses_pid)" = 0 ]
    local noname="$?"
    [ "$(ulimit -c)" = 0 ] || [ "$noname" = 0 ] && >&2 echo "(coredumps disabled)"
    # try and get a location
    local handler=core
    [ -f "$corepat" ] && handler="$(sed 's/\([^\]\) .*/\1/g' "$corepat")"
    case "$handler" in
        \|*apport) echo "/var/lib/apport/coredump"                  ;;
        \|*)       >&2 echo "piped to unknown program ${handler#|}" ;;
        */*)       echo "$handler"                                  ;;
        *)         pwd                                              ;;
    esac
}

# 'vim session': launch a vim session stored in a standard location, or create the
# session if it doesn't exist yet.
# $1: session name
# all other arguments: passed on to vim
VIM_SESSIONS_DIR="$(state-home)/vim/sessions"
vims () {
    [ -z "$1" ] && >&2 error "please provide a session name." && return 1

    local session="$1"
    local session_file="$VIM_SESSIONS_DIR/$session.vim"
    if [ -f "$session_file" ]; then
        vim -S "$session_file"
    else
        vim ${@:2} -c ":Obsess $session_file"
    fi
}
__vims_completion () {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local sessions="$(find "$(state-home)/vim/sessions" -maxdepth 1 -mindepth 1 -type f -printf "%f\n" | sed 's/\.vim$//')"
    COMPREPLY=($(compgen -W "$sessions" -- "${cur}"))
}
complete -F __vims_completion vims

# === Other ============================================================================
# TODO #test
# if [[ $- == *i* ]]; then
    # when terminal is frozen by ^s, allow unfreezing with any key.
    stty ixany

    shopt -s checkwinsize globstar histappend
    # make less more friendly for non-text input files, see lesspipe(1)
    have-cmd lesspipe && eval "$(SHELL=/bin/sh lesspipe)"
    # do some standard colour setup for ls
    have-cmd dircolors && eval "$(dircolors -b)"

    # NOTE(slow) enable programmable completion features (you don't need to enable this,
    # if it's already enabled in /etc/bash.bashrc and /etc/profile sources
    # /etc/bash.bashrc).
    if ! shopt -oq posix; then
      if [ -f /usr/share/bash-completion/bash_completion ]; then
        . /usr/share/bash-completion/bash_completion
      elif [ -f /etc/bash_completion ]; then
        . /etc/bash_completion
      fi
    fi
# fi


# === End ==============================================================================
# source other files (eg. for setup-specific stuff, or for external programs)
for f in $(find "$DOTFILES/bash" -maxdepth 1 -type f) ; do source "$f" ; done
# explicitly source machine-local files afterwards, so they can override earlier config
[ -d "$DOTFILES/local/bash" ] && \
    for f in $(find "$DOTFILES/local/bash" -maxdepth 1 -type f) ; do source "$f" ; done
