# general utilities, to be used in other files
#
# NOTE: this should be sourced before anything else in bash/, or local/bash/

# is the environment variable `$1` defined?
function is-defined {
    [ -z ${1+x} ] && return 1 || return 0
}

# yes/no prompt
# $1: the prompt string
# $2: default value (optional) -- should be `y`, `n` or empty
# returns: 0 if `yes` chosen; 1 if `no` chosen; if no default was given, will loop
# usage: `if yesno "wanna do the thing?" y; then
#             echo did the thing!
#         fi`
function yesno {
    local qn=$1
    local default=$2

    # set our default based on input
    local opts="[y/n]"
    if [ "$default" = y ]; then
        local opts="[Y/n]"
    elif [ "$default" = n ]; then
        local opts="[y/N]"
    fi

    while true; do
        # read input
        read -p "$qn $opts " -n 1 -s -r input
        echo ${input}

        # if nothing entered and have a default, return it
        if [[ -z "$input" && ! -z "$default" ]]; then
            [ "$default" = "y" ] && return 0 || return 1
        fi

        # else if something entered, return if valid
        if [[ "$input" =~ ^[yYnN]$ ]]; then
            input=${input:-${default}}
            [[ "$input" =~ ^[yY]$ ]] && return 0 || return 1
        fi
    done
}

# insert a call to this into a script, to 'break' there and be able to type `echo`
# (etc.) to see what's going on.
# from: https://blog.jez.io/bash-debugger/
function debugger {
    echo "[DBG] Press ^D to resume, or ^C to abort."
    local line
    while read -r -p "> " line; do
        eval "$line"
    done
    echo
}

# echo xdg vars
function cache-home {
    is-defined "$XDG_CACHE_HOME" && [ -d "$XDG_CACHE_HOME" ] \
        && echo "$XDG_CACHE_HOME" \
        || echo "$HOME/.cache"
}

function config-home {
    is-defined "$XDG_CONFIG_HOME" && [ -d "$XDG_CONFIG_HOME" ] \
        && echo "$XDG_CONFIG_HOME" \
        || echo "$HOME/.config"
}

function data-home {
    is-defined "$XDG_DATA_HOME" && [ -d "$XDG_DATA_HOME" ] \
        && echo "$XDG_DATA_HOME" \
        || echo "$HOME/.local/share"
}

function state-home {
    is-defined "$XDG_STATE_HOME" && [ -d "$XDG_STATE_HOME" ] \
        && echo "$XDG_STATE_HOME" \
        || echo "$HOME/.state"
}
