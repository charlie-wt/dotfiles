# misc setting of xdg base dirs


# conan
export CONAN_USER_HOME="$(config-home)"

# gradle
export GRADLE_USER_HOME="$(data-home)/gradle"

# less
export LESSHISTFILE="$(data-home)/less/history"

# moc
alias mocp="mocp -M $(config-home)/moc"

# pylint (prior to ver 2.10)
export PYLINTHOME="$(cache-home)/pylint"

# sqlite
[ -e "$(config-home)/sqlite3/sqliterc" ] && alias sqlite3="sqlite3 -init $(config-home)/sqlite3/sqliterc"
export SQLITE_HISTORY="$(data-home)/sqlite/history"

# terminfo
export TERMINFO="$(data-home)/terminfo"
export TERMINFO_DIRS="$(data-home)/terminfo:/usr/share/terminfo"

# texlive/texmf
export TEXMFHOME="$(data-home)/texmf"
export TEXMFVAR="$(cache-home)/texlive/texmf-var"
export TEXMFCONFIG="$(config-home)/texlive/texmf-config"

# readline
export INPUTRC="$(config-home)/readline/inputrc"
