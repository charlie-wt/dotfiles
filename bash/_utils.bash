# general utilities, to be used in other files
#
# NOTE: this should be sourced before anything else in bash/, or local/bash/

# is the environment variable `$1` defined?
is-defined () {
    [ -z ${1+x} ] && return 1 || return 0
}

