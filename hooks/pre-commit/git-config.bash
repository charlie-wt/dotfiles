source "$DOTFILES/bash/_utils.bash"


exit_code=0

# $1: name of property
# $2: expected value
do-check () {
    actual="$(git config --get "$1")"
    if [ "$actual" != "$2" ]; then
        >&2 error "expected $(info-col "$1") to be $(warn-col "$2"), but was $(warn-col "$actual")"
        exit_code=1
    fi
}

do-check "user.name" "charlie-wt"
do-check "user.email" "shout@charlies.computer"

exit $exit_code
