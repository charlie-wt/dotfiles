#!/usr/bin/env bash


# === Basic setup ======================================================================
d=$(dirname "$(readlink -e "$0")")  # directory of this script
source "$d/bash/_utils.bash"

# -y or -n options to always pick yes/no at prompts
default_choice=""
if [ "$1" = "-y" ]; then
    default_choice=true
elif [ "$1" = "-n" ]; then
    default_choice=false
fi

# general function to symlink a file, presenting prompts under various scenarios.
# responds to $default_choice.
#
# fails with an error message if the file to link to doesn't exist.
#
# will make any necessary directories that the symlink will sit in.
#
# $1: absolute(!) path of file to link to -- you'll probably want to prepend $d.
# $2: absolute path to symlink to be made.
# $3: human-friendly name of the thing being symlinked, for messages.
#
# example: `symlink "$d/vimrc" "$HOME/.vimrc" "my vimrc"
function symlink {
    local target="$1"
    local link_name="$2"
    local name="$3"

    if [ ! -e "$target" ]; then
        >&2 echo "$name: can't find target $target to symlink"
        return 1
    fi

    if [ -L "$link_name" ]; then
        existing_target=$(readlink -f "$link_name")

        if [ -e "$target" ] && [ "$existing_target" = "$target" ]; then
            echo "$name already set correctly; skipping"
            return 0
        fi

        if [ -e "$target" ]; then
            if [ -e "$existing_target" ]; then
                if confirm-action "WARN: '$link_name' is already a symlink, so did not make a link." \
                                  "$name: '$link_name' already points to '$existing_target'; replace it?" \
                                  y; then
                    echo "replacing old $name"
                    rm "$link_name"
                else
                    return 0
                fi
            else
                if confirm-action "WARN: '$link_name' exists as a dead link; did not make a new link." \
                                  "$name: '$link_name' exists as a dead link -- replace it?" \
                                  y; then
                    echo "replacing dead link for $name"
                    rm "$link_name"
                else
                    return 0
                fi
            fi
        fi
    elif [ -e "$link_name" ]; then
        if confirm-action "WARN: '$link_name' already exists, so did not make a link." \
                          "$name: a file at '$link_name' already exists; replace it?" \
                          n; then
            echo "replacing old $name"
            rm "$link_name"
        else
            return 0
        fi
    fi

    # make a new symlink
    mkdir -p $(dirname "$link_name")
    ln -s "$target" "$link_name"
}


# === Symlinking dotfiles ==============================================================
# wrapper around `symlink`, specifically for dotfiles.
#
# $1: name of the file to link to (relative path, from $d)
# $2: name of symlink (absolute path) -- optional, defaults to ~/.$1
function dotfile {
    # params
    local dotfile_name="$1"
    local link_name="${2:-$HOME/.$dotfile_name}"

    if ! symlink "$d/$dotfile_name" "$link_name" "dotfile $dotfile_name"; then
        return 1
    fi
}

echo symlinking dotfiles...
dotfile bashrc
dotfile gdbinit
dotfile gitconfig       "$(config-home)/git/config"
dotfile local/gitconfig "$(config-home)/git/local.gitconfig"
dotfile local/gitignore "$(config-home)/git/ignore"
dotfile tmux.conf       "$(config-home)/tmux/tmux.conf"
dotfile vimrc
dotfile kitty.conf      "$(config-home)/kitty/kitty.conf"
echo


# === Install scripts ==================================================================
# general function
install_location="$HOME/.local/bin"
script_root="$d"
function install-script {
    # params
    local script_name="$1"

    if ! symlink "$script_root/$script_name" "$install_location/$script_name" "$script_name script"; then
        >&2 echo "(looking in $script_root for scripts; have you set \$script_root correctly?)"
        return 1
    fi
}

echo symlinking scripts...

# install local scripts, if-present
if [ -x "$d/local/install-scripts" ]; then
    script_root="$d/local/scripts"
    . "$d/local/install-scripts"
fi
echo


# === Symlinking other directories =====================================================
echo symlinking other files...
[ -e "$d/vim" ]       && symlink "$d/vim"       "$HOME/.vim/personal"       "vim personal dir"
[ -e "$d/local/vim" ] && symlink "$d/local/vim" "$HOME/.vim/personal-local" "vim personal local dir"
echo


# === Other bits =======================================================================
echo doing other misc stuff...

# make directories for vim swapfiles & backups
mkdir -p "$(state-home)/vim/backups"
mkdir -p "$(state-home)/vim/swaps"
mkdir -p "$(state-home)/vim/undo"

# basic setup for vim plugin manager
vim_plug_loc="$HOME/.vim/autoload/plug.vim"
if [ -e "$vim_plug_loc" ]; then
    echo "plug.vim already exists in $vim_plug_loc; skipping"
else
    curl -fLo "$vim_plug_loc" --create-dirs \
        https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
fi

# setup tmux plugin manager
tpm_dir="$(config-home)/tmux/plugins/tpm"
if [ -e "$tpm_dir" ]; then
    echo "tpm already exists in $tpm_dir; skipping"
else
    git clone https://github.com/tmux-plugins/tpm "$tpm_dir"
fi

# basic rust setup
rustup_dir="$(data-home)/rustup"
cargo_dir="$(data-home)/cargo"
if [[ -e "$rustup_dir" && -e "$cargo_dir" ]]; then
    echo "rustup & cargo already exist in $rustup_dir & $cargo_dir; skipping"
elif [ "$default_choice" != false ]; then
    if [ "$default_choice" = true ] ||
       yesno "do you want to install rust & cargo?"; then
        export RUSTUP_HOME=$rustup_dir
        export CARGO_HOME=$cargo_dir
        curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
    fi
fi

# reminders for manual bits i've not automated yet
echo
echo DONE. remember to do these too:
echo "* run :PluginInstall in vim to install plugins"
echo "* run <prefix>+I in tmux to install plugins"
echo "* do any machine-specific setup in local/{gitconfig,bash/*,vim/*} (then run again)"

if [[ ! $(tmux -V) =~ "tmux 3" ]]; then
    echo
    echo "WARN: your tmux is too old to understand \$XDG_CONFIG_HOME."
    echo "      best thing is to make bash/local/tmux.bash, with this line:"
    echo
    echo 'alias tmux="tmux -f ${XDG_CONFIG_HOME:-$HOME/.config}/tmux/tmux.conf"'
fi
