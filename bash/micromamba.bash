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



# MINE: register manpages from `global` environment
global_env="$MAMBA_ROOT_PREFIX/envs/global"
if [ -d "$global_env" ]; then
    [ -d "$global_env/share/man" ] && export MANPATH="$MANPATH:$global_env/share/man"
    # NOTE: allowing running micromamba bins 'globally' is best done with wrapper
    # scripts (so that they work with eg. tools that expect names of executables).
    # there's infra to do this in `install`, so if that's needed elsewhere best to copy
    # it out of there into a standalone script.
fi
