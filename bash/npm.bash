[ ! -e "$(data-home)/npm" ] && return 1
[ ! -e "$(config-home)/npm" ] && return 1

# NOTE these take ages to run, so disabling until i need them

# export PATH=$PATH:"$(data-home)/npm/bin"
# export NPM_CONFIG_USERCONFIG="$(config-home)/npm/npmrc"