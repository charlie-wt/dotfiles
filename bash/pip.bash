base_dir="$HOME/.local/bin"
[ ! -e "$base_dir" ] && return 1

export PATH=$PATH:"$base_dir"

