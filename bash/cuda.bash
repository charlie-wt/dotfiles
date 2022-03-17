base_dir="/usr/local/cuda-9.0"
[[ ! -e "$base_dir" ]] && return 1

export PATH=$base_dir/bin${PATH:+:${PATH}}
export LD_LIBRARY_PATH=$base_dir/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}
export LD_LIBRARY_PATH=$base_dir/extras/CUPTI/lib64${LD_LIBRARY_PATH:+:${LD_LIBRARY_PATH}}