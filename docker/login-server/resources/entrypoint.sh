#!/bin/sh

#start sshd
etc/init.d/ssh start
etc/init.d/rsyslog start

#keep running
tail -f /dev/null