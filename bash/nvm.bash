base_dir="$(data-home)/nvm"
[ -e "$base_dir" ] || return 2

export NVM_DIR="$base_dir"

# NOTE these take ages to run

[ -s "$base_dir/nvm.sh" ] && \. "$base_dir/nvm.sh"  # This loads nvm
[ -s "$base_dir/bash_completion" ] && \. "$base_dir/bash_completion"  # This loads nvm bash_completion
