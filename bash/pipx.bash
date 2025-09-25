base_dir="$(data-home)/pipx"
[ -e "$base_dir" ] || return 2

export PIPX_HOME="$base_dir"
export PIPX_BIN_DIR="$base_dir/bin"

export PATH=$PATH:"$base_dir/bin"
