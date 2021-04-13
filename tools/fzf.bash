fzf_dir=/home/charlie/src/bin/fzf

# Setup fzf
# ---------
if [[ ! "$PATH" == *$fzf_dir/bin* ]]; then
  export PATH="${PATH:+${PATH}:}$fzf_dir/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$fzf_dir/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "$fzf_dir/shell/key-bindings.bash"

# Use rg for files to filter through, ignoring vcs-ignored files.
export FZF_DEFAULT_COMMAND='rg --files'
