base_dir="/var/lib/flatpak"
[[ ! -e "$base_dir" ]] && return 1

export PATH="$PATH:$base_dir/exports/bin"