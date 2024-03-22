have-cmd rustup && have-cmd cargo || return 2

completion_dir="$(data-home)/bash-completion/completions"

[ ! -d "$completion_dir" ] && { mkdir -p "$completion_dir" || return 1; }

ensure-completions () {
    local name="$1"
    local completion_file="$completion_dir/$name"

    [ "$(which "$name")" -ot "$completion_file" ] && return

    rustup completions bash "$name" > "$completion_file"
}
ensure-completions rustup
ensure-completions cargo

unset -f ensure-completions
unset completion_dir
