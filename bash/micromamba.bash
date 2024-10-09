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



# MINE: allow directly running bins from the `global` environment, & register manpages
global_env="$MAMBA_ROOT_PREFIX/envs/global"
if [ -d "$global_env" ]; then
    for b in $(find "$global_env/bin" -maxdepth 1 -type f -exec basename {} \;); do
        alias "$b"="micromamba run -n global $b"
    done
    [ -d "$global_env/share/man" ] && export MANPATH="$MANPATH:$global_env/share/man"
fi
