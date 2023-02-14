# general utilities, to be used in other files
#
# NOTE: this should be sourced before anything else in bash/, or local/bash/


# include-guard, since this'll be sourced in lots of places
[ -n "${__utils_included+x}" ] && return 1
__utils_included=1



# for printing with some colours
# TODO #feature: add a with-colour, or something?
function title {
    echo -e "\e[32m""$@""\e[0m"
}

function error {
    echo -e "\e[31m""$@""\e[0m"
}

function warn {
    echo -e "\e[33m""$@""\e[0m"
}

function info {
    echo -e "\e[36m""$@""\e[0m"
}

function unimportant {
    echo -e "\e[90m""$@""\e[0m"
}

function error-pref {
    echo "$(error ERROR):" "$@"
}

function warn-pref {
    echo "$(warn WARN):" "$@"
}

function info-pref {
    echo "$(info INFO):" "$@"
}


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

# confirm whether to do an action, with a yesno prompt, but also responding to a
# $default_choice variable. if $default_choice is `true` or `false`, the yesno prompt is
# not presented.
#
# $1: yesno prompt
# $2: a message to print if $default_choice is `false`.
# $3: yesno default (ie. [Yn] vs. [yN] vs. [yn])
function confirm-action {
    local prompt="$1"
    local default_false_message="$2"
    local yesno_default="$3"

    local default="$default_choice"
    if [[ "$default_choice" != true && \
          "$default_choice" != false && \
          "$default_choice" != "" ]]; then
        >&2 echo "$(error internal error): unknown \$default_choice '$default_choice'"
        default=""
    fi

    if [ "$default" = false ]; then
        >&2 echo "$default_false_message"
        return 1
    elif [ "$default" = "" ] && ! yesno "$prompt" "$yesno_default"; then
        return 1
    fi

    return 0
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
        || echo "$HOME/.local/state"
}

function bin-home {
    # not xdg, but used for stuff
    echo "$HOME/.local/bin"
}


# is the first given version number at least that of the second? returns 0 if true.
#
# strips out any bad chars from the inputs, so you can pipe in eg. $(tmux -V).
#
# $1: version number to compare.
# $2: version number to compare against.
function at-least-version {
    fst="$(echo "$1" | sed 's/[^0-9\.]//g')"
    snd="$(echo "$2" | sed 's/[^0-9\.]//g')"

    [ $(printf "$fst\n$snd" | sort -Vr | head -n 1) = "$fst" ] && return 0 || return 1
}
