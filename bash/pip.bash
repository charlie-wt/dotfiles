base_dir="$(data-home)/python"
[ -e "$base_dir" ] || return 2

export PYTHONUSERBASE="$base_dir"

export PATH=$PATH:"$base_dir/bin"
