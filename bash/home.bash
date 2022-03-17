# edit the shelf
alias shelf='vim "+cd ~/Documents/shelf" ~/Documents/shelf/articles/done.md'

# basically an alias
gip () { get-iplayer --modes=best --pid=$1; }

# edit this month's goals
goals () {
    dirname=~/goals
    fulldirname=~/Documents/goals/$(date +%Y)

    if [ ! -L $dirname ] ; then
        if [ ! -d $fulldirname ] ; then
            mkdir $fulldirname
            [ -d ~/Documents/goals/year ] && cp ~/Documents/goals/year/* $fulldirname
        fi

        ln -s $fulldirname $dirname
    elif [ ! "$(readlink $dirname)" -ef "$fulldirname" ] ; then
        rm $dirname && ln -s $fulldirname $dirname
    fi

    fname=$dirname/$(date +%B | tr A-Z a-z).md
    template_name=$dirname/_month.md

    [ ! -f $fname ] && [ -f $template_name ] && cp $template_name $fname

    vim $fname
}
