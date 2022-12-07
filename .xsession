#!/bin/sh

if test -e "$HOME/.profile"; then
	source $HOME/.profile
fi

# setup environment before starting applications
EDITOR=nvim
LC_CTYPE=en_US.UTF-8
PATH=$HOME/pkg/bin:$PATH
if test "x$HOST" = "x"; then
	HOST=`uname -n`
fi

export EDITOR LC_CTYPE PATH HOST

xset b off
xset s off
xset -dpms
xrdb -l $HOME/.Xdefaults
pekwm_panel &
xscreensaver &

if [ -z "$SSH_AGENT_PID" ]; then
    exec ssh-agent pekwm
else
    exec pekwm
fi
