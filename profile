# if running bash
if [ -n "$BASH_VERSION" ]; then
    [ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
fi

# add user bin dirs to PATH if they exist
[ -d "$HOME/.local/bin" ] && PATH="$HOME/.local/bin:$PATH"
[ -d "$HOME/.bin" ]       && PATH="$HOME/.bin:$PATH"

# enable core dumps
ulimit -c unlimited

# env vars
export HISTSIZE=100000
export HISTFILESIZE=$HISTSIZE
