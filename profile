# if running bash
if [ -n "$BASH_VERSION" ]; then
    [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
fi

# enable core dumps
ulimit -c unlimited

# env vars
export HISTSIZE=100000
export HISTFILESIZE=$HISTSIZE
