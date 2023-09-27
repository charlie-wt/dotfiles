#!/usr/bin/env bash

# tool for centralising python virtual environments.


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
            echo "Commands:"
            echo " ls | list | show:                      list venvs"
            echo " new | mk | make | add \$ENV:            make a new venv or list of venvs"
            echo " rm | del* | remove | uninstall \$ENV:   remove a venv or list of venvs"
            echo " set | workon | go | in \$ENV:           enter a venv"
            echo " unset | deac* | out:                   leave current venv"
            echo " [nothing] | on:                        print current venv"
            echo " help | -h:                             print this message"
            echo
            echo "Note: When adding or removing venvs, you can supply a list of names; if "
            echo "adding multiple venvs, you won't be put into any created venv."
            echo
            echo "Note: When removing venvs, you can give a regex in the place of an name; if so,"
            echo "you'll be prompted for each matching venv you're about to remove. You can pass "
            echo "a regex to 'set' too, but it must have a unique match."
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

    local str=$(find "$VENV_HOME" -mindepth 1 -maxdepth 1 -printf "%f\n" | while read f; do is-a-known-venv "$f" && echo "$f"; done)

    # if running interactively & not too long, concat onto one line & pad with spaces
    if [ -t 1 ]; then
        local oneline="${str//$'\n'/   }"
        [ "$(printf "$oneline" | wc -c)" -lt "$(tput cols)" ] && str="$oneline"
    fi

    printf "$str\n"
}

venv-new () {
    verify-name-supplied "$1" || return 1

    for name in "$@"; do
        if is-a-known-venv "$name"; then
            if yesno "venv $name already exists; replace it?" n; then
                venv-rm "$name"
                echo "making new $name"
            else
                echo "did not make a new venv"
                return 1
            fi
        fi

        python3 -m venv "$VENV_HOME/$name"
    done

    [ "$#" == 1 ] && venv-set "$1"
}

venv-rm () {
    verify-name-supplied "$1" || return 1

    for arg in "$@"; do
        local matches="$(get-any-name-match "$arg")"

        echo "$matches" | while read -r name; do
            [ -z "$name" ] && continue

            # if given a regex instead of an exact name, confirm if we're about to
            # remove the right venv.
            if ! is-a-known-venv "$arg"; then
                ! yesno "remove matching venv $name?" y && continue
            else
                echo "removing $name"
            fi

            [ "$(venv-on)" == "$name" ] && venv-unset

            rm -rf "$VENV_HOME/$name"
        done
    done
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

# echoes the name of any venv that matches the regex `$1`, or nothing with a stderr msg
# if there are no matches.
get-any-name-match () {
    verify-name-supplied "$1" || return 1

    # if given an exact match, go with it -- otherwise, if you've got a venv with a name
    # that's a subset of another venv's name, there's no way to refer to it.
    if is-a-known-venv "$1"; then
        echo "$1"
        return
    fi

    # check for valid env to switch to
    local match=$(venv-ls | grep "$1")

    if [ -z "$match" ]; then
        >&2 echo "'$1' does not match any venvs. available:"
        >&2 venv-ls
        return 1
    fi

    echo "$match"
}

# echoes the name of the single venv that matches the regex `$1`, or nothing with a
# stderr msg if that can't be done.
get-unique-name-match () {
    # check for valid env to switch to
    local match
    match="$(get-any-name-match "$1")" || return 1
    local num_matches="$(num-lines "$match")"

    if [ "$num_matches" -ne 1 ]; then
        >&2 echo "'$1' does not match a single venv (matches $num_matches). available:"
        >&2 venv-ls
        return 1
    fi

    echo "$match"
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
