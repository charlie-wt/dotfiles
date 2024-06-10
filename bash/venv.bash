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

    print-list "$str"
}

venv-new () {
    # TODO #enhancement: all args after `--` are passed to `python3 -m venv`
    verify-name-supplied "$1" || return 1

    let num_made=0
    local first_made=""

    for name in "$@"; do
        if is-a-known-venv "$name"; then
            if yesno "venv $name already exists; replace it?" n; then
                venv-rm "$name"
                echo "making new $name"
            else
                echo "did not make $name"
                continue
            fi
        fi

        python3 -m venv "$VENV_HOME/$name"

        let num_made++
        [ -z "$first_made" ] && first_made="$name"
    done

    [ "$num_made" == 1 ] && venv-set "$first_made"
}

venv-rm () {
    verify-name-supplied "$1" || return 1

    for arg in "$@"; do
        local matches="$(get-any-name-match "$(venv-ls)" "$arg" venv)"

        while read -r name; do
            [ -z "$name" ] && continue

            if [ "$arg" == "$matches" ]; then
                # exact match
                echo "removing $name"
            else
                # inexact match: confirm we're about to remove the right venv.
                ! yesno "remove matching venv $name?" y && continue
            fi

            [ "$(venv-on)" == "$name" ] && venv-unset

            rm -rf "$VENV_HOME/$name"
        done <<< "$matches"
    done
}

venv-set () {
    local name="$(get-unique-name-match "$(venv-ls)" "$1" venv)"
    [ -z "$name" ] && return 1

    source "$VENV_HOME/$name/bin/activate"
}

venv-unset () {
    command -v deactivate &>/dev/null && deactivate || echo "not in a venv"
}

# utils
is-a-known-venv () {
    [ -f "$VENV_HOME/$1/bin/activate" ] && return || return 1
}

verify-name-supplied () {
    if [ -z "$1" ]; then
        >&2 echo please specify a venv.
        return 1
    fi
}

# completion
__venv_completion () {
    local cur="${COMP_WORDS[COMP_CWORD]}"
    local cmd="${COMP_WORDS[1]}"

    COMPREPLY=()
    case "${COMP_CWORD}" in
        1)
            COMPREPLY=($(compgen -W "on ls list show new mk make add rm delete remove uninstall set workon go in unset deactivate out help" -- ${cur}))
            ;;
        2)
            case ${cmd} in
                rm|del*|remove|uninstall|set|workon|go|in)        ;;
                *)                                         return ;;
            esac
            COMPREPLY=($(compgen -W "$(venv ls)" -- ${cur}))
            ;;
        *)
            case ${cmd} in
                rm|del*|remove|uninstall)        ;;
                *)                        return ;;
            esac
            COMPREPLY=($(compgen -W "$(venv ls)" -- ${cur}))
            ;;
    esac
}
complete -F __venv_completion venv
