base_dir="/var/lib/flatpak"
[ -e "$base_dir" ] || return 2

export PATH="$PATH:$base_dir/exports/bin"