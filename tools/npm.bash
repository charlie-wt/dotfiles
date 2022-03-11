base_dir="${XDG_DATA_HOME:-$HOME/.local/share}/npm"
[[ ! -e "$base_dir" ]] && return 1

export PATH=$PATH:"$base_dir/npm/packages/bin"