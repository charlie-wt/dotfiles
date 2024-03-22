export GHCUP_USE_XDG_DIRS=1
export STACK_XDG=1  # (...but probably don't use stack)
ghcup_dir="$(data-home)/ghcup"

[ -f "$ghcup_dir/env" ] && . "$ghcup_dir/env"

[ -d "$ghcup_dir/share/man" ] && export MANPATH="$MANPATH:$ghcup_dir/share/man"

completion_file="$(data-home)/bash-completion/completions/ghcup"
[ ! -f "$completion_file" ] && cat << "EOF" > "$completion_file"
_ghcup()
{
    local CMDLINE
    local IFS=$'\n'
    CMDLINE=(--bash-completion-index $COMP_CWORD)

    for arg in ${COMP_WORDS[@]}; do
        CMDLINE=(${CMDLINE[@]} --bash-completion-word $arg)
    done

    COMPREPLY=( $(ghcup "${CMDLINE[@]}") )
}

complete -o filenames -F _ghcup ghcup
EOF

unset completion_file
unset ghcup_dir