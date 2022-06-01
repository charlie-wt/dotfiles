base_dir=~/src/bin/fzf
[ ! -e "$base_dir" ] && return 1

# Setup fzf
# ---------
if [[ ! "$PATH" == *$base_dir/bin* ]]; then
  export PATH="${PATH:+${PATH}:}$base_dir/bin"
fi

# Auto-completion
# ---------------
[[ $- == *i* ]] && source "$base_dir/shell/completion.bash" 2> /dev/null

# Key bindings
# ------------
source "$base_dir/shell/key-bindings.bash"



# my settings

# Use rg for files to filter through, ignoring vcs-ignored files.
export FZF_DEFAULT_COMMAND='rg --files'
# export FZF_DEFAULT_COMMAND='fd --type file'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"

