[[ ! -e "$data_home/npm" ]] && return 1
[[ ! -e "$config_home/npm" ]] && return 1

# NOTE these take ages to run, so disabling until i need them

# export PATH=$PATH:"$data_home/npm/bin"
# export NPM_CONFIG_USERCONFIG="$config_home/npm/npmrc"