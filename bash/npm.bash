[ -e "$(data-home)/npm" ] && [ -e "$(config-home)/npm" ] || return 2

# NOTE these take ages to run

export PATH=$PATH:"$(data-home)/npm/bin"
export NPM_CONFIG_USERCONFIG="$(config-home)/npm/npmrc"