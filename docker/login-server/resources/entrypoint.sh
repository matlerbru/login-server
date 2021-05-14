#!/bin/sh

#start sshd
etc/init.d/ssh start

#keep running
tail -f /dev/null