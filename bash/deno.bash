deno_base_dir="$(data-home)/deno"

register-deno () {
    export DENO_DIR="$(cache-home)/deno"
    export DENO_INSTALL_ROOT="$deno_base_dir"
    maybe-prepend-to-path "$deno_base_dir/bin"
}

install-deno () {
    # unfortunately there's no way to modify the behaviour of their install script
    # (https://deno.land/install.sh) to do the right thing without interactive prompts,
    # so instead just paste the important bits manually lol
    case $(uname -sm) in
        "Darwin x86_64") local target="x86_64-apple-darwin" ;;
        "Darwin arm64") local target="aarch64-apple-darwin" ;;
        "Linux aarch64") local target="aarch64-unknown-linux-gnu" ;;
        *) local target="x86_64-unknown-linux-gnu" ;;
    esac

    local deno_version="$(curl -s https://dl.deno.land/release-latest.txt)"
    local deno_uri="https://dl.deno.land/release/${deno_version}/deno-${target}.zip"
    local bin_dir="$deno_base_dir/bin"
    local exe="$bin_dir/deno"

    mkdir -p "$bin_dir"
    curl --fail --location --progress-bar --output "$exe.zip" "$deno_uri"
    unzip -d "$bin_dir" -o "$exe.zip"
    chmod +x "$exe"
    rm "$exe.zip"

    register-deno

    # generate completions
    local completions_dir="$(data-home)/bash-completion/completions"
    mkdir -p "$completions_dir"
    deno completions bash > "$completions_dir/deno"
}

[ -e "$deno_base_dir" ] || return 2
register-deno
