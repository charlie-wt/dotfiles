base_dir="$(data-home)/deno"
[ -e "$base_dir" ] || return 2

export DENO_DIR="$(cache-home)/deno"

[ -s "$base_dir/env" ] && \. "$base_dir/env"
[ -s "$base_dir/bash_completion" ] && \. "$base_dir/bash_completion"
