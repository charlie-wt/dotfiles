# misc setting of xdg base dirs


# conan
export CONAN_USER_HOME="$config_home"

# gradle
export GRADLE_USER_HOME="$data_home/gradle"

# less
export LESSHISTFILE="$data_home/less/history"

# moc
alias mocp="mocp -M $config_home/moc"

# pylint (prior to ver 2.10)
export PYLINTHOME="$cache_home/pylint"

# sqlite
[[ -e "$config_home/sqlite3/sqliterc" ]] && alias sqlite3="sqlite3 -init $config_home/sqlite3/sqliterc"
export SQLITE_HISTORY="$data_home/sqlite/history"

# terminfo
export TERMINFO="$data_home/terminfo"
export TERMINFO_DIRS="$data_home/terminfo:/usr/share/terminfo"

# texlive/texmf
export TEXMFHOME="$data_home/texmf"
export TEXMFVAR="$cache_home/texlive/texmf-var"
export TEXMFCONFIG="$config_home/texlive/texmf-config"
