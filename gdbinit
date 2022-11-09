set confirm off
set history save on
set pagination off
set print pretty on


# don't step into the standard library
skip -gfi /usr/include/c++/*/*/*
skip -gfi /usr/include/c++/*/*
skip -gfi /usr/include/c++/*

# source local config
python
import gdb
import os
path = os.getenv('DOTFILES') + '/local/gdbinit'
if os.path.isfile(path):
    gdb.execute(f'source {path}')
end

# commands:
#
# watch foo
# watch -l foo
# rwatch foo
# watch foo thread 3
# watch foo if foo > 10
#
# backtrace full
#
# thread all apply $COMMAND
# thread 1-3 apply $COMMAND
#
# dprintf myfun,"x is %i",x
#
# catch throw
# catch catch
#
# call func_returning_void  # could be a printing function
#
# gdbserver host:port /path/to/a.out
# > then connect from gdb with target remote host:port
#
# gcc -ggdb3  # or higher numbers i guess
#
# valgrind --vgdb=full --vgdb-error 0 ./a.out   # starts gdb server
