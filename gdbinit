set history save on
set print pretty on
set pagination off
set confirm off

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
# catch catch
#
# gdbserver host:port /path/to/a.out
# > then connect from gdb with target remote host:port
#
# gcc -ggdb3  # or higher numbers i guess
#
# valgrind --vgdb=full --vgdb-error 0 ./a.out   # starts gdb server
