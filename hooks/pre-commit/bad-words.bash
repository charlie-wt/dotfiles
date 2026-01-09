source "$DOTFILES/bash/_utils.bash"


# bad-words file format: each line is a term to `grep -Ei`, except those starting with a
# `#` which are skipped
bad_words_list="$DOTFILES/local/bad-words.conf"


[ -f "$bad_words_list" ] || exit 0

changed_files="$(git diff --name-only)"

exit_code=0

IFS=$'\n'
for term in $(cat "$bad_words_list") ; do
    [[ "$term" =~ "#" ]] && continue

    matches="$(grep "$term" $changed_files -Ei --color=always -n -C 1)"
    if [ -n "$matches" ] ; then
        >&2 error "found bad word matches for term "$(warn-col "$term")":"
        printf "$matches\n\n"
        exit_code=1
    fi
done

# might want to think about this warning, but not failing, so false positives aren't
# quite as punishing
exit $exit_code
