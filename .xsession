#!/bin/sh

# setup environment before starting applications
EDITOR=vim
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

UNAME_S=`uname -s`
if test "x$UNAME_S" = "xOpenBSD"; then
	AUTOCONF_VERSION="`ls /usr/local/bin/autoconf-* 2>/dev/null | sed 's/.*-\([0-9]\)/\1/' | sort -n | tail -1`"
	AUTOMAKE_VERSION="`ls /usr/local/bin/automake-* 2>/dev/null | sed 's/.*-\([0-9]\)/\1/' | sort -n | tail -1`"
	export AUTOCONF_VERSION AUTOMAKE_VERSION
fi

# ensure core dumps
ulimit -c unlimited

if test "x$SSH_AGENT_PID" = "x"; then
	eval `ssh-agent`
fi

exec pekwm
