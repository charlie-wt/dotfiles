base_dir="${XDG_DATA_HOME:-$HOME/.local/share}"
[[ ! -e "$base_dir/cargo" && ! -e "$base_dir/rustup" ]] && return 1

export CARGO_HOME="$base_dir/cargo"
export RUSTUP_HOME="$base_dir/rustup"

export PATH=$PATH:$CARGO_HOME/bin

source "$CARGO_HOME/env"