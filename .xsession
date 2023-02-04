#!/bin/sh

# setup environment before starting applications
EDITOR=nvim
LC_CTYPE=en_US.UTF-8
PATH=$HOME/pkg/bin:$PATH
if test "x$HOST" = "x"; then
	HOST=`uname -n`
fi
export EDITOR LC_CTYPE PATH HOST

# override with environment from profile
if test -e "$HOME/.profile"; then
	source $HOME/.profile
fi

# ensure core dumps
ulimit -c unlimited

xset b off
xset s off
xset -dpms
xrdb -l $HOME/.Xdefaults
pekwm_panel &
xscreensaver &

if test "x$SSH_AGENT_PID" = "x"; then
	eval `ssh-agent`
fi

exec pekwm
