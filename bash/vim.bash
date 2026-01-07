vim_src_dir="$HOME/src/bin/vim"
[ -x "$vim_src_dir/src/vim" ] || return 2

# note: this is a function, not an alias, so that we can use it from scripts
vim () {
    VIMRUNTIME=$vim_src_dir/runtime $vim_src_dir/src/vim $@
}