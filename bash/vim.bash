vim_src_dir="$HOME/src/bin/vim"
[ ! -d "$vim_src_dir" ] && return 1

alias vim="VIMRUNTIME=$vim_src_dir/runtime $vim_src_dir/src/vim"