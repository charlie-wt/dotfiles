#!/usr/bin/env bash

# some basic tools to centralise python virtual environments, roughly replicating the
# virtualenvwrapper tool


export VENV_HOME="$HOME/.local/var/venv"


venv () {
    if [ -z "$1" ]; then
        echo working on $(venv-on)
        return 0
    fi

    case "$1" in
        ls|list|show)             venv-ls    "${@:2}" ;;
        new|mk|make|add)          venv-new   "${@:2}" ;;
        rm|del|remove|uninstall)  venv-rm    "${@:2}" ;;
        set|workon|go|in)         venv-set   "${@:2}" ;;
        unset|deac*|out)          venv-unset "${@:2}" ;;
        *)
            echo "unknown command $1; commands:"
            echo "ls   new   rm   set   unset"
            ;;
    esac
}

venv-on () {
    echo "${VIRTUAL_ENV##*/}"
}

venv-ls () {
    pushd "$VENV_HOME" >/dev/null ; ls -Cd */ | tr -d '/' ; popd >/dev/null
}

venv-new () {
    venv_name="$1"
    python3 -m venv "$VENV_HOME/$venv_name"
    venv-set $venv_name
}

venv-rm () {
    if [ -z "$1" ]; then
        echo please specify a venv to remove.
        return 1
    fi

    if [ ! -d "$VENV_HOME/$1" ]; then
        echo "unknown venv $1 -- available venvs:"
        venv-ls
        return 1
    fi

    [ "$(venv-on)" == "$1" ] && venv-unset

    rm -rf "$VENV_HOME/$1"
}

venv-set () {
    if [ ! -d "$VENV_HOME/$1" ]; then
        echo "unknown venv $1 -- available venvs:"
        venv-ls
        return 1
    fi

    if [ ! -f "$VENV_HOME/$1/bin/activate" ]; then
        echo "$1 is not a valid venv -- available venvs:"
        venv-ls
        return 1
    fi

    source "$VENV_HOME/$1/bin/activate"
}

venv-unset () {
    command -v deactivate &>/dev/null && deactivate || echo "not in a venv"
}