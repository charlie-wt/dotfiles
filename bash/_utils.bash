# general utilities, to be used in other files
#
# NOTE: this should be sourced before anything else in bash/, or local/bash/


# include-guard, since this'll be sourced in lots of places
[ -n "${__utils_included+x}" ] && return 1
__utils_included=1



# for printing with some colours
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


# is the environment variable `$1` defined? (note: do not pass $1 in double-quotes)
function is-defined {
    [ -z ${1+x} ] && return 1 || return 0
}

# does the command `$1` exist?
function have-cmd {
    [ -z "$(type -t $1)" ] && return 1 || return 0
}

# get the number of lines in `$1`
function num-lines {
    echo -n "$1" | grep -c ^
}


# yes/no prompt
# $1: the prompt string
# $2: default value (optional) -- should be `y`, `n` or empty
# returns: 0 if `yes` chosen; 1 if `no` chosen; if no default was given, will loop
# usage: `if yesno "wanna do the thing?" y; then
#             echo did the thing!
#         fi`
function yesno {
    local qn="$1"
    local default="$2"

    # set our default based on input
    local opts="[y/n]"
    if [ "$default" = y ]; then
        local opts="[Y/n]"
    elif [ "$default" = n ]; then
        local opts="[y/N]"
    fi

    while true; do
        # read input
        read -p "$qn $opts " -n 1 -s -r input < /dev/tty
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
        [ -n "$default_false_message" ] && >&2 echo "$default_false_message"
        return 1
    elif [ "$default" = "" ] && ! yesno "$prompt" "$yesno_default"; then
        return 1
    fi

    return 0
}


# prints a list (line-separated string), but concat onto one line & pad with spaces if
# running interactively
# $1: list to print
# $2: (optional) single-line padding string to use; defaults to four spaces
# $3: (optional) label for the list, to print as a prefix
print-list () {
    str="$1"
    padding="${2:-"    "}"

    [ -n "$3" ] && str="$3:  $str"

    if [ -t 1 ]; then
        local oneline="${str//$"\n"/$padding}"
        oneline="${oneline//$'\n'/$padding}"
        [ "$(printf "$oneline" | wc -c)" -lt "$(tput cols)" ] && str="$oneline"
    fi

    printf "$str\n"
}

# echoes the name of any option in `$1` that matches the regex `$2`, or nothing with a
# stderr msg if there are no matches.
# note: if the supplied query is an exact match of an option that's a subset of another,
# both options will be returned.
# $1: list of options, one per line
# $2: supplied name to try to match to an option
# $3: (optional) name of what the options represent, for error messages
get-any-name-match () {
    local options="$1"
    local query="$2"
    local label="${3:-name}"

    if [ -z "$2" ]; then
        >&2 echo "please specify a $label."
        return 1
    fi

    # check for an inexact regex match
    local match=$(printf "$options" | grep "$query")

    if [ -z "$match" ]; then
        >&2 echo "'$query' does not match any $label. available:"
        >&2 print-list "$options"
        return 1
    fi

    echo "$match"
}

# echoes the name of the single option in `$1` that matches the regex `$2`, or nothing
# with a stderr msg if that can't be done.
# $1: list of options, one per line
# $2: supplied name to try to match to an option
# $3: (optional) name of what the options represent, for error messages
get-unique-name-match () {
    local options="$1"
    local query="$2"
    local label="${3:-name}"

    # if given an exact match, go with it -- otherwise, if you've got an option with a
    # name that's a subset of another option's name, it's inconvenient to refer to it.
    if [ -n "$(printf "$options" | grep -Fx "$query")" ]; then
        echo "$query"
        return
    fi

    local match
    match="$(get-any-name-match "$options" "$query" "$label")" || return 1

    local num_matches="$(num-lines "$match")"
    if [ "$num_matches" -ne 1 ]; then
        >&2 echo "'$query' does not match a single $label (matches $num_matches). available:"
        >&2 print-list "$options"
        return 1
    fi

    echo "$match"
}


# insert a call to this into a script, to 'break' there and be able to type `echo`
# (etc.) to see what's going on.
# from: https://blog.jez.io/bash-debugger/
function breakpoint {
    echo "[DBG] Press ^D to resume, or ^C to abort."
    local line
    while read -r -p "> " line < /dev/tty; do
        eval "$line"
    done
    echo
}


# echo xdg vars
function cache-home {
    [ -n "$XDG_CACHE_HOME" ] && echo "$XDG_CACHE_HOME" || echo "$HOME/.cache"
}

function config-home {
    [ -n "$XDG_CONFIG_HOME" ] && echo "$XDG_CONFIG_HOME" || echo "$HOME/.config"
}

function data-home {
    [ -n "$XDG_DATA_HOME" ] && echo "$XDG_DATA_HOME" || echo "$HOME/.local/share"
}

function state-home {
    [ -n "$XDG_STATE_HOME" ] && echo "$XDG_STATE_HOME" || echo "$HOME/.local/state"
}

function bin-home {
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
