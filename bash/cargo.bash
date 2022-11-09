[[ ! -e "$(data-home)/cargo" && ! -e "$(data-home)/rustup" ]] && return 1

export CARGO_HOME="$(data-home)/cargo"
export RUSTUP_HOME="$(data-home)/rustup"

export PATH=$PATH:$CARGO_HOME/bin

source "$CARGO_HOME/env"