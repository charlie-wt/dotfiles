# enable core dumps
ulimit -c unlimited

# swap capslock and escape
/usr/bin/setxkbmap -option "caps:swapescape"

echo $PATH="$PATH:~/.local/bin"

export HISTSIZE=100000
export HISTFILESIZE=$HISTSIZE
