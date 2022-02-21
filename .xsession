#!/bin/sh

if [ -e "$HOME/.profile" ]; then
    source $HOME/.profile
fi

EDITOR=nvim
LC_CTYPE=en_US.UTF-8
PATH=$HOME/pkg/bin:$PATH
GTK3_CSD=0
export EDITOR GTK3_CSD LC_CTYPE PATH

xset b off
xrdb -l $HOME/.Xdefaults
pekwm_panel &

if [ -z "$SSH_AGENT_PID" ]; then
    exec ssh-agent pekwm
else
    exec pekwm
fi
