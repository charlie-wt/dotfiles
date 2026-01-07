vim_src_dir="$HOME/src/bin/vim"
[ -x "$vim_src_dir/src/vim" ] || return 2

# use locally-built vim, if it exists
export VIMRUNTIME="$vim_src_dir/runtime"
export PATH="$vim_src_dir/src:$PATH"