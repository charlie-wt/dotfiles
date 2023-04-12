#!/usr/bin/env bash

# some basic tools to centralise python virtual environments, roughly replicating the
# virtualenvwrapper tool


export VENV_HOME="$HOME/.local/var/venv"


# main interface
venv () {
    case "$1" in
        ""|on)                     venv-on    "${@:2}" ;;
        ls|list|show)              venv-ls    "${@:2}" ;;
        new|mk|make|add)           venv-new   "${@:2}" ;;
        rm|del*|remove|uninstall)  venv-rm    "${@:2}" ;;
        set|workon|go|in)          venv-set   "${@:2}" ;;
        unset|deac*|out)           venv-unset "${@:2}" ;;
        help|-h)
            echo "commands:"
            echo " ls | list | show:                      list venvs"
            echo " new | mk | make | add \$ENV:            make a new venv"
            echo " rm | del* | remove | uninstall \$ENV:   remove a venv"
            echo " set | workon | go | in \$ENV:           enter a venv"
            echo " unset | deac* | out:                   leave current venv"
            echo " [nothing] | on:                        print current venv"
            echo " help | -h:                             print this message"
            ;;
        *)
            echo "unknown command $1; commands:"
            echo "ls   new   rm   set   unset   on   help"
            ;;
    esac
}

# individual commands
venv-on () {
    local on="${VIRTUAL_ENV##*/}"
    # make a nicer message if running interactively
    [ -t 1 ] && on=$([ -n "$on" ] && echo "working on $on" || echo "(not in a venv)")

    echo "$on"
}

venv-ls () {
    [ ! -d "$VENV_HOME" ] && return

    local str=$(for d in $(ls "$VENV_HOME"); do is-a-known-venv "$d" && echo $d; done)

    # if running interactively & not too many venvs, concat onto one line & pad with
    # spaces
    if [ -t 1 ]; then
        local oneline="${str//$'\n'/   }"
        (( "$(printf "$oneline" | wc -c)" < "$(tput cols)" )) && str="$oneline"
    fi

    printf "$str\n"
}

venv-new () {
    verify-name-supplied "$1" || return 1

    if is-a-known-venv "$1"; then
        if yesno "venv $1 already exists; replace it?" n; then
            venv-rm "$1"
            echo "making new $1"
        else
            echo "did not make a new venv"
            return 1
        fi
    fi

    local venv_name="$1"
    python3 -m venv "$VENV_HOME/$venv_name"
    venv-set $venv_name
}

venv-rm () {
    local name="$(get-unique-name-match "$1")"
    [ -z "$name" ] && return 1

    # if given a regex instead of an exact name, confirm if we're about to remove the
    # right venv.
    if ! is-a-known-venv "$1"; then
        ! yesno "remove matching venv "$name"?" y && return 1
    else
        echo removing "$name"
    fi

    [ "$(venv-on)" == "$name" ] && venv-unset

    rm -rf "$VENV_HOME/$name"
}

venv-set () {
    local name="$(get-unique-name-match "$1")"
    [ -z "$name" ] && return 1

    source "$VENV_HOME/$name/bin/activate"
}

venv-unset () {
    command -v deactivate &>/dev/null && deactivate || echo "not in a venv"
}

# utils
is-a-known-venv () {
    [ -d "$VENV_HOME/$1" ] && [ -f "$VENV_HOME/$1/bin/activate" ] && return || return 1
}

verify-name-supplied () {
    if [ -z "$1" ]; then
        >&2 echo please specify a venv.
        return 1
    fi
}

verify-is-a-known-venv () {
    verify-name-supplied "$1" || return 1
    if ! is-a-known-venv "$1"; then
        >&2 echo "unknown venv $1 -- available venvs:"
        >&2 venv-ls
        return 1
    fi
}

# echoes the name of the single venv that matches the regex `$1`, or nothing with a
# stderr msg if that can't be done.
get-unique-name-match () {
    verify-name-supplied "$1" || return 1

    # if they've given an exact match, go with it -- otherwise, if you've got a venv
    # with a name that's a subset of another venv's name, there's no way to refer to it.
    if is-a-known-venv "$1"; then
        echo "$1"
        return
    fi

    # check for valid env to switch to
    local match=$(venv-ls | grep "$1")

    if [ -z "$match" ] ||  # even if no matches, assigning to `match` makes 1 empty line
       [ "$(echo "$match" | wc -l)" -ne 1 ]; then
        >&2 echo unknown or ambiguous venv \'"$1"\'. available:
        >&2 venv-ls
        return 1
    fi

    echo $match
}

# completion
__venv_completion () {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local prev="${COMP_WORDS[COMP_CWORD-1]}"

    COMPREPLY=()
    case "${COMP_CWORD}" in
        1)
            COMPREPLY=($(compgen -W "on ls list show new mk make add rm delete remove uninstall set workon go in unset deactivate out help" -- ${cur}))
            ;;
        2)
            case ${prev} in
                rm|del*|remove|uninstall|set|workon|go|in)        ;;
                *)                                         return ;;
            esac
            COMPREPLY=($(compgen -W "$(venv ls)" -- ${cur}))
            ;;
        *)  ;;
    esac
}
complete -F __venv_completion venv
