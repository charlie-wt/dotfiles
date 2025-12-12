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



# MINE: (maybe) allow directly running bins from the `global` environment, & register manpages
global_env="$MAMBA_ROOT_PREFIX/envs/global"
if [ -d "$global_env" ]; then
    [ -d "$global_env/share/man" ] && export MANPATH="$MANPATH:$global_env/share/man"

    # define some functions to potentially call from local dotfiles', to make use of the
    # global env.
    #
    # * sometimes you can make use of all the binaries from the packages installed.
    # * sometimes a package installs a bunch of binaries you don't care about (eg.
    #   `clang-tools`), which would make the exhaustive search too slow.
    # * sometimes you need the commands to have associated executable files & not be
    #   aliases, so you can't use these at all.
    #   * TODO #enhancement: add a function to `install` to manage making wrapper
    #     scripts easily?
    _do-alias () {
        alias "$1"="micromamba run -n global $1"
    }

    # make an alias for all binaries in the global micromamba env, to run them directly
    alias-all-global-bins () {
        for b in $(find "$global_env/bin" -maxdepth 1 -type f 2>/dev/null -exec basename {} \;); do
            _do-alias "$b"
        done
    }

    # for each arg, make an alias to run it from the global micromamba env
    alias-specific-global-bins () {
        for b in $@; do _do-alias "$b" ; done
    }

    # make a wrapper script in a specified directory
    # $1: binary name
    micromamba-wrap () {
        # check we have the chosen binary (fail silently if not)
        [ -f "$global_env/bin/$1" ] || return 1

        # ensure we have the wrapper script dir
        [ -d "$mamba_wrappers_dir" ] || mkdir -p "$mamba_wrappers_dir"

        # make the wrapper script, if needed (assume if the file exists, it's correct)
        if ! [ -f "$mamba_wrappers_dir/$1" ]; then
            printf "#!/usr/bin/env bash
[ -z \"\$MAMBA_EXE\" ] && >&2 echo \"\\\$MAMBA_EXE not set\" && exit 1
\"\$MAMBA_EXE\" run -n global $1 \$@
" > "$mamba_wrappers_dir/$1"
        fi
        chmod u+x "$mamba_wrappers_dir/$1"
    }
fi
