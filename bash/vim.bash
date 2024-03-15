vim_src_dir="$HOME/src/bin/vim"
[ ! -x "$vim_src_dir/src/vim" ] && return 1

alias vim="VIMRUNTIME=$vim_src_dir/runtime $vim_src_dir/src/vim"