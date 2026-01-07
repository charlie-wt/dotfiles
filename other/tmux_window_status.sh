#!/usr/bin/env bash


# setup
max_length=16  # maximum length of result before ellipsising
cd "$1"
trunc() {
    if [ "${#1}" -le "$max_length" ]; then
        echo "$1"
    else
        local fst_half="$(( "$max_length" / 2))"
        local snd_half="$(( ("$max_length" - 1) / 2))"
        printf '%s…%s\n' "${1:0:$fst_half}" "${1:(-$snd_half)}"
    fi
}


# try getting git repo dir
res="$(git rev-parse --show-toplevel 2>/dev/null)"

# otherwise take cwd
[ -z "$res" ] && res="$1"

# take final portion of dir, then ellipsise
trunc "$(basename "$res")"