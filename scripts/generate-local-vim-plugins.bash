# constants
contents_stub='" NOTE: This file is intended to be loaded in a vim-plug `plug#begin` block'
file_name="plugins.vim"


# setup
dotfiles=$(dirname $(dirname "$(readlink -e "$0")"))  # dotfiles directory
source "$dotfiles/bash/_utils.bash"


# do the thing
locald="$DOTFILES/local"
if [ ! -e "$locald" ]; then
    mkdir -p "$locald"
elif [ ! -d "$locald" ]; then
    >&2 error "A \`local\` file exists in the dotfiles dir, but it isn't a dir. Don't know what to do, so exiting."
    exit 1
fi

fn="$locald/$file_name"
if [ -e "$fn" ]; then
    >&2 error "Intended plugins file "$(warn-col $fn)" already exists. Don't know what to do, so exiting."
    exit 1
fi

echo "$contents_stub" >> "$fn"

echo "$(info-col DONE). remember to also add this to your local/install:"
echo 'symlink "$root/plugins.vim" "$HOME/.vim/local-plugins.vim" "vim local plugins"'
