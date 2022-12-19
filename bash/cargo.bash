[[ ! -e "$(data-home)/cargo" && ! -e "$(data-home)/rustup" ]] && return 1

export CARGO_HOME="$(data-home)/cargo"
export RUSTUP_HOME="$(data-home)/rustup"

export PATH=$CARGO_HOME/bin:$PATH

source "$CARGO_HOME/env"