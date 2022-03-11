# get autocompletion for vcstool
if [ -f /usr/share/vcstool-completion/vcs.bash ]; then
    source /usr/share/vcstool-completion/vcs.bash
elif [ -f /usr/local/share/vcstool-completion/vcs.bash ]; then
    source /usr/local/share/vcstool-completion/vcs.bash
fi