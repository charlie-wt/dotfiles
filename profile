# if running bash
[ -n "$BASH_VERSION" ] && [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"

# enable core dumps
ulimit -c unlimited

# env vars
export HISTSIZE=100000
export HISTFILESIZE=$HISTSIZE
