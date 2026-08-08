# TODO #enhancement: this doesn't work for eg. opening a new tmux split from one running
# yazi; would want the new split to open in yazi's current dir, but doesn't.
function y () {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    command yazi "$@" --cwd-file="$tmp"
    IFS= read -r -d '' cwd < "$tmp"
    [ "$cwd" != "$PWD" ] && [ -d "$cwd" ] && builtin cd -- "$cwd"
    rm -f -- "$tmp"
}