base_dir="$(data-home)/python"
export PYTHONUSERBASE="$base_dir"
[ -e "$base_dir" ] || return 2

export PATH=$PATH:"$base_dir/bin"

