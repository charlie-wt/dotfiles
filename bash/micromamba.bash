# !! Contents within this block are managed by 'mamba init' !!
export MAMBA_EXE='/nethome/charliew/.local/share/micromamba/micromamba';
[ ! -x "$MAMBA_EXE" ] && return 1

export MAMBA_ROOT_PREFIX='/nethome/charliew/.local/share/micromamba';
__mamba_setup="$("$MAMBA_EXE" shell hook --shell bash --root-prefix "$MAMBA_ROOT_PREFIX" 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__mamba_setup"
else
    alias micromamba="$MAMBA_EXE"  # Fallback on help from mamba activate
fi
unset __mamba_setup


# MINE: allow directly running bins from the `global` environment, & register manpages
global_env="$MAMBA_ROOT_PREFIX/envs/global"
for b in $(find "$global_env/bin" -maxdepth 1 -type f 2>/dev/null | xargs -r basename); do
    alias "$b"="micromamba run -n global $b"
done
[ -d "$global_env/share/man" ] && export MANPATH="$MANPATH:$global_env/share/man"
