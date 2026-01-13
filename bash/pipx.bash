base_dir="$(data-home)/pipx"
[ -e "$base_dir" ] || return 2

export PIPX_HOME="$base_dir"
export PIPX_BIN_DIR="$PIPX_HOME/bin"

export PATH=$PATH:"$PIPX_BIN_DIR"
