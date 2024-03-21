! have-cmd rustup && return 1

completion_dir="$HOME/.local/share/bash-completion/completions"

ensure-completions () {
    local name="$1"

    local current_version="$("$name" --version 2>/dev/null | sed 's/.*(\([0-9a-f]\+\) .*/\1/')"
    local completion_file="$completion_dir/$name"

    if [ ! -d "$completion_dir" ]; then
        mkdir -p "$completion_dir" || return 1
    fi

    if [ -f "$completion_file" ]; then
        local existing_version="$(head -n 1 "$completion_file" | cut -d ' ' -f 3)"
        [ "$current_version" == "$existing_version" ] && return 1
    fi

    echo "# @VERSION $current_version" > "$completion_file"
    rustup completions bash "$name" >> "$completion_file"
}
ensure-completions rustup
ensure-completions cargo
unset -f ensure-completions

