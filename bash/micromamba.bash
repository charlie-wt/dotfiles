export MAMBA_ROOT_PREFIX="$(data-home)/micromamba";
export MAMBA_EXE="$MAMBA_ROOT_PREFIX/micromamba";
[ -x "$MAMBA_EXE" ] || return 2

__setup_file="$MAMBA_ROOT_PREFIX/setup.bash"
if [ "$MAMBA_EXE" -nt "$__setup_file" ]; then
    "$MAMBA_EXE" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX" > "$__setup_file" 2>/dev/null
fi
if [ -f "$__setup_file" ]; then
    source "$__setup_file"
else
    alias micromamba="$MAMBA_EXE"  # Fallback on help from mamba activate
fi
unset __setup_file



# MY STUFF (use a function just to be able to use `local`)
__mine () {
    local global_env="$MAMBA_ROOT_PREFIX/envs/global"
    if [ -d "$global_env" ]; then
        # register manpages from `global` environment
        [ -d "$global_env/share/man" ] && export MANPATH="$MANPATH:$global_env/share/man"

        # register bash completion from `global` environment:
        # * some packages put them in `share/bash-completion/completions`, which is nice
        #   and can be exported straight away:
        [ -d "$global_env/share" ] && export XDG_DATA_DIRS="$XDG_DATA_DIRS:$global_env/share"
        # * some packages put them in `etc/bash_completion.d`, which is not nice and
        #   forces us to create a custom dir with the right structure before exporting
        #   (done in `install`):
        local extra_data_dir="$MAMBA_ROOT_PREFIX/global-xdg-data-dir"
        [ -d "$extra_data_dir" ] && export XDG_DATA_DIRS="$XDG_DATA_DIRS:$extra_data_dir"

        # NOTE: allowing running micromamba bins 'globally' is best done with wrapper
        # scripts (so that they work with eg. tools that expect names of executable
        # files). there's infra to do this in `install`, so if that's needed elsewhere
        # best to copy it out of there into a standalone script.
    fi
}
__mine
unset __mine
