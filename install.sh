#!/usr/bin/env bash


source "bash/_utils.bash"


# === Basic vars =======================================================================
# directory of this script
d=$(dirname "$(readlink -e "$0")")

# -y or -n options to always pick yes/no at prompts
default_choice=""
if [ "$1" = "-y" ]; then
    default_choice=true
elif [ "$1" = "-n" ]; then
    default_choice=false
fi

cache_home="${XDG_CACHE_HOME:-$HOME/.cache}"
config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
data_home="${XDG_DATA_HOME:-$HOME/.local/share}"
state_home="${XDG_STATE_HOME:-$HOME/.local/state}"


# === Symlinking dotfiles ==============================================================
# symlink a dotfile. if there's a conflict, present a prompt (or do a default behaviour)
#
# note: default choice set by `$default_choice` variable (`true` or `false`).
# $1: name of the file to symlink (relative path)
# $2: name of symlink (absolute path) -- optional, defaults to ~/.$1
# returns: 0 if symlink was made for dotfile; else 1
function dotfile {
    # params
    local dotfile_name="$1"
    local link_name="${2:-$HOME/.$dotfile_name}"

    if [ ! -f $d/$dotfile_name ]; then
        echo "can't find dotfile $dotfile_name to symlink"
        return 1
    fi

    # if `$link_name` exists, check if we should replace it with a new symlink
    if [[ -e "$link_name" || -L "$link_name" ]]; then
        if [ "$(readlink $link_name)" = "$d/$dotfile_name" ]; then
            echo "dotfile $dotfile_name already set correctly; skipping."
            return 1
        elif [ "$default_choice" = false ]; then
            echo "WARN: $link_name already exists, so did not make a link."
            return 1
        elif [ "$default_choice" = "" ] &&
             ! yesno "$link_name already exists -- replace it?" y; then
            return 1
        fi
        rm "$link_name"
    fi

    # make the symlink, including any needed dirs
    mkdir -p $(dirname "$link_name")
    ln -s "$d/$dotfile_name" "$link_name"
}

dotfile bashrc
dotfile gitconfig "$config_home/git/config"
dotfile local/gitconfig "$config_home/git/local.gitconfig"
dotfile local/gitignore "$config_home/git/ignore"
dotfile tmux.conf "$config_home/tmux/tmux.conf"
dotfile vimrc


# === Symlinking other directories =====================================================
function symlink {
    local link_name="$1"
    local target="$2"
    local name="$3"

    if [ -L "$link_name" ]; then
        existing_target=$(readlink "$link_name")

        if [ -d "$target" ] && [ "$existing_target" = "$target" ]; then
            echo "$name already exists; skipping"
        elif [ -d "$target" ]; then
            if [ ! -d "$existing_target" ]; then
                echo "replacing old $name that points to nothing"
                rm "$link_name" && ln -s "$target" "$link_name"
            elif [ "$default_choice" = "false" ]; then
                echo "WARN: $link_name already exists, so did not make a link."
                return 1
            elif [ "$default_choice" = "true" ] ||
                 yesno "$name at '$link_name' already points to '$existing_target'; replace it?" y; then
                echo "replacing old $name"
                rm "$link_name" && ln -s "$target" "$link_name"
            fi
        elif [ "$existing_target" = "$target" ]; then
            echo "deleting old $name that points to nothing"
            rm "$link_name"
        fi
    elif [ -d "$target" ]; then
        # might fail if $link_name exists but isn't a symlink, but eh
        ln -s "$target" "$link_name"
    fi
}
symlink "$HOME/.vim/personal" "$d/vim" "vim personal dir"
symlink "$HOME/.vim/personal-local" "$d/local/vim" "vim personal local dir"


# === Other bits =======================================================================
# make directories for vim swapfiles & backups
mkdir -p "$state_home/vim/backups"
mkdir -p "$state_home/vim/swaps"
mkdir -p "$state_home/vim/undo"

# basic setup for vim plugin manager
vim_plug_loc="$HOME/.vim/autoload/plug.vim"
if [ -e "$vim_plug_loc" ]; then
    echo "plug.vim already exists in $vim_plug_loc; skipping"
else
    curl -fLo "$vim_plug_loc" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# setup tmux plugin manager
tpm_dir="$config_home/tmux/plugins/tpm"
if [ -e "$tpm_dir" ]; then
    echo "tpm already exists in $tpm_dir; skipping"
else
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
fi

# basic rust setup
rustup_dir="$data_home/rustup"
cargo_dir="$data_home/cargo"
if [[ -e "$rustup_dir" && -e "$cargo_dir" ]]; then
    echo "rustup & cargo already exist in $rustup_dir & $cargo_dir; skipping"
elif [ $default_choice = true ] || yesno "do you want to install rust & cargo?"; then
    export RUSTUP_HOME=$rustup_dir
    export CARGO_HOME=$cargo_dir
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
fi

# reminders for manual bits i've not automated yet
echo
echo DONE. remember to do these too:
echo \* run :PluginInstall in vim to install plugins
echo \* run \<prefix\>+I in tmux to install plugins
echo \* do any machine-specific setup in local/\{gitconfig,bash/*,vim/*\}

if [[ ! $(tmux -V) =~ "tmux 3" ]]; then
    echo
    echo WARN: your tmux is too old to understand \$XDG_CONFIG_HOME.
    echo       best thing is to make bash/local/tmux.bash, with this line:
    echo
    echo alias tmux=\"tmux -f \${XDG_CONFIG_HOME:-\$HOME/.config}/tmux/tmux.conf\"
fi
