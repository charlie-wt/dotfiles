base_dir="${XDG_DATA_HOME:-$HOME/.local/share}/nvm"
[[ ! -e "$base_dir" ]] && return 1

[ -s "$base_dir/nvm.sh" ] && \. "$base_dir/nvm.sh"  # This loads nvm
[ -s "$base_dir/bash_completion" ] && \. "$base_dir/bash_completion"  # This loads nvm bash_completion
