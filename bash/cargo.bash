[[ ! -e "$data_home/cargo" && ! -e "$data_home/rustup" ]] && return 1

export CARGO_HOME="$data_home/cargo"
export RUSTUP_HOME="$data_home/rustup"

export PATH=$PATH:$CARGO_HOME/bin

source "$CARGO_HOME/env"