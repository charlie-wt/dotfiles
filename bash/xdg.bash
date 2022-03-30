# misc setting of xdg base dirs

# less
export LESSHISTFILE="$data_home/less/history"

# moc
alias mocp="mocp -M $config_home/moc"

# sqlite
[[ -e "$config_home/sqlite3/sqliterc" ]] && alias sqlite3="sqlite3 -init $config_home/sqlite3/sqliterc"
export SQLITE_HISTORY="$data_home/sqlite/history"

# texlive/texmf
export TEXMFHOME="$data_home/texmf"
export TEXMFVAR="$cache_home/texlive/texmf-var"
export TEXMFCONFIG="$config_home/texlive/texmf-config"
