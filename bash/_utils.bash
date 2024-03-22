# general utilities, to be used in other files
#
# NOTE: this should be sourced before anything else in bash/, or local/bash/


# include-guard, since this'll be sourced in lots of places
[ -n "${__utils_included+x}" ] && return 2
__utils_included=1



# for printing with some colours
title () {
    echo -e "\e[32m""$@""\e[0m"
}

error-col () {
    echo -e "\e[31m""$@""\e[0m"
}

warn-col () {
    echo -e "\e[33m""$@""\e[0m"
}

info-col () {
    echo -e "\e[36m""$@""\e[0m"
}

unimportant-col () {
    echo -e "\e[90m""$@""\e[0m"
}

skip () {
    unimportant-col "skipped: $@"
}

error () {
    echo "$(error-col ERROR):" "$@"
}

warn () {
    echo "$(warn-col WARN):" "$@"
}

info () {
    echo "$(info-col INFO):" "$@"
}


# is the environment variable `$1` defined? (note: do not pass $1 in double-quotes)
is-defined () {
    [ -z ${1+x} ] && return 1 || return 0
}

# does the command `$1` exist?
have-cmd () {
    [ -z "$(type -t $1)" ] && return 1 || return 0
}

# get the number of lines in `$1`
num-lines () {
    echo -n "$1" | grep -c ^
}

# echo the exit code of the given command invocation
# $1: if `-p` ('passthrough'), will not suppress stdout & stderr of the given command.
# usage: `$ exit-code ls directory_that_exists
#         0`
#        `$ exit-code -p ls directory_that_doesnt_exist
#         ls: cannot access 'directory_that_doesnt_exist': No such file or directory
#         2`
exit-code () {
    if [ "$1" == "-p" ]; then
        ${@:2}
    else
        $@ >/dev/null 2>&1
    fi
    echo "$?"
}


# yes/no prompt
# $1: the prompt string
# $2: default value (optional) -- should be `y`, `n` or empty
# returns: 0 if `yes` chosen; 1 if `no` chosen; if no default was given, will loop
# usage: `if yesno "wanna do the thing?" y; then
#             echo did the thing!
#         fi`
yesno () {
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
confirm-action () {
    local prompt="$1"
    local default_false_message="$2"
    local yesno_default="$3"

    local default="$default_choice"
    if [[ "$default_choice" != true && \
          "$default_choice" != false && \
          "$default_choice" != "" ]]; then
        >&2 echo "$(error-col internal error): unknown \$default_choice '$default_choice'"
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


# interactive function to symlink a file, presenting prompts under various scenarios.
# responds to $default_choice ("true", "false", "").
#
# fails with an error message if the file to link to doesn't exist.
#
# will make any necessary directories that the symlink will sit in.
#
# $1: absolute path of file to link to.
# $2: absolute path to symlink to be made.
# $3: (optional) human-friendly name of the thing being symlinked, for messages.
#
# returns:
# 0: if the symlink now exists (including if it was already set correctly)
# 1: if the symlink does not now exist (if there was a conflict, and the user cancelled)
# 2: on error
#
# example: `symlink "$DOTFILES/vimrc" "$HOME/.vimrc" "my vimrc"
symlink () {
    local target="$1"
    local link_name="$2"
    local name="${3:-$(basename "$target")}"

    if [ ! -e "$target" ]; then
        >&2 echo "$(error-col "$name"): can't find target $target to symlink"
        return 2
    fi

    if [ -L "$link_name" ]; then
        existing_target="$(readlink -f "$link_name")"

        if [ "$existing_target" = "$target" ]; then
            skip "$name already set correctly"
            return 0
        fi

        # link exists -- confirm whether to replace it
        local prompt="$(warn-col "$name"): '$link_name' exists as a dead link -- replace it?"
        local def_msg="$(warn "'$link_name' exists as a dead link; did not make a new link.")"
        local link_status="dead"
        if [ -e "$existing_target" ]; then
            prompt="$(warn-col "$name"): '$link_name' already points to '$existing_target'; replace it?"
            def_msg="$(warn "'$link_name' is already a symlink, so did not make a link.")"
            link_status="old"
        fi

        if confirm-action "$prompt" "$def_msg" y; then
            echo "replacing $link_status link for $(info-col "$name")"
            rm "$link_name"
        else
            return 1
        fi
    elif [ -e "$link_name" ]; then
        if confirm-action "$(warn-col "$name"): a file at '$link_name' already exists; replace it?" \
                          "$(warn "'$link_name' already exists, so did not make a link.")" \
                          n; then
            echo "replacing old $(info-col "$name")"
            rm "$link_name"
        else
            return 1
        fi
    fi

    # make a new symlink
    mkdir -p $(dirname "$link_name") && ln -s "$target" "$link_name"
}

# interactive function to mount a device, presenting prompts under various scenarios.
# responds to $default_choice ("true", "false", ""). doesn't deal with all edge cases.
#
# fails with an error message if the device to mount to doesn't exist.
#
# will make any necessary directories that the mount point will sit in.
#
# $1: absolute path of device.
# $2: absolute path to mount point.
# $3: (optional) human-friendly name of the thing being mounted, for messages.
#
# returns:
# 0: if the device is now mounted at the given mountpoint (including if it was already
#    set correctly)
# 1: if the device is not now mounted at the given mountpoint (if there was a conflict,
#    and the user cancelled)
# 2: on error
#
# example: `do-mount "/dev/vde" "/work" "work block device"
do-mount () {
    local device="$1"
    local mountpoint="$2"
    local name="${3:-"$device"}"

    if ! lsblk "$device" >/dev/null 2>&1; then
        >&2 echo "$(error-col "$name"): $device is not a mountable device"
        return 2
    fi

    local existing_mountpoints="$(findmnt "$device" -n -o "TARGET")"
    if [ -n "$(echo "$existing_mountpoints" | grep "^$mountpoint$")" ]; then
        skip "$name already mounted correctly"
        return 0
    elif [ -n "$existing_mountpoints" ]; then
        >&2 warn "$device is already mounted in the following locations:"
        >&2 echo -e "$existing_mountpoints"
        if ! confirm-action "continue?" "$device is already mounted" n; then
            return 1
        fi
    fi

    if [ -e "$mountpoint" ]; then
        # mountpoint already exists as a file
        local prompt="$(warn-col "$name"): a file at '$mountpoint' already exists; replace it?"
        local def_msg="$(warn "'$mountpoint' already exists, so did not mount.")"

        existing_devices="$(findmnt -n -o "SOURCE" -M "$mountpoint")"
        if [ -n "$existing_devices" ]; then
            # mountpoint already exists as a mountpoint for another device(s)
            echo "existing_devices: $existing_devices"
            prompt="$(warn-col "$name"): '$mountpoint' already mounts '$existing_devices'; continue?"
            def_msg="$(warn "'$mountpoint' already mounts some devices, so did not mount.")"

            if ! confirm-action "$prompt" "$def_msg" y; then
                return 1
            fi
        fi

        if confirm-action "$prompt" "$def_msg" n; then
            echo "replacing old $(info-col "$name")"
            rm -r "$mountpoint"
        else
            return 1
        fi
    fi

    # make a new symlink
    sudo mkdir -p "$mountpoint"
    sudo mount "$device" "$mountpoint"
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
breakpoint () {
    echo "[DBG] Press ^D to resume, or ^C to abort."
    local line
    while read -r -p "> " line < /dev/tty; do
        eval "$line"
    done
    echo
}


# echo xdg vars
cache-home () {
    [ -n "$XDG_CACHE_HOME" ] && echo "$XDG_CACHE_HOME" || echo "$HOME/.cache"
}

config-home () {
    [ -n "$XDG_CONFIG_HOME" ] && echo "$XDG_CONFIG_HOME" || echo "$HOME/.config"
}

data-home () {
    [ -n "$XDG_DATA_HOME" ] && echo "$XDG_DATA_HOME" || echo "$HOME/.local/share"
}

state-home () {
    [ -n "$XDG_STATE_HOME" ] && echo "$XDG_STATE_HOME" || echo "$HOME/.local/state"
}

bin-home () {
    echo "$HOME/.local/bin"
}


# is the first given version number at least that of the second? returns 0 if true.
#
# strips out any bad chars from the inputs, so you can pipe in eg. $(tmux -V).
#
# $1: version number to compare.
# $2: version number to compare against.
at-least-version () {
    fst="$(echo "$1" | sed 's/[^0-9\.]//g')"
    snd="$(echo "$2" | sed 's/[^0-9\.]//g')"

    [ $(printf "$fst\n$snd" | sort -Vr | head -n 1) = "$fst" ] && return 0 || return 1
}
