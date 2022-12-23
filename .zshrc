zstyle ':completion:*' completer _complete _ignored
zstyle :compinstall filename "$HOME/.zshrc"

autoload -Uz compinit && compinit
autoload -U colors && colors

if test -f "$HOME/.profile"; then
	source $HOME/.profile
fi

HISTFILE=~/.histfile
HISTSIZE=1000
SAVEHIST=1000
setopt extendedglob nomatch notify
unsetopt autocd beep
bindkey -e

PROMPT="%{$fg[yellow]%}%T%{$reset_color%} %m %{$fg[green]%}%1~%{$reset_color%} [%?] %{$fg[cyan]%}%#%{$reset_color%} "
case $TERM in
    xterm*)
        chpwd () { print -Pn "\e]0;%n@%m: %~\a" }
        periodic() { xterm_control_timeofday.sh }
        PERIOD=300
        # initial set before any change of directory
        print -Pn "\e]0;%n@%m: %~\a"
        ;;
esac

if test `which nvim >/dev/null 2>&1`; then
	EDITOR=nvim
else
	EDITOR=vim
fi
LC_CTYPE=en_US.UTF-8

if test -d /usr/pkg/bin; then
	PATH=/usr/pkg/bin:$PATH
	ZSH_EXT_DIR=/usr/pkg/share
elif test -d /usr/local/share/zsh; then
	ZSH_EXT_DIR=/usr/local/share
elif test -d /opt/local/share/zsh; then
	ZSH_EXT_DIR=/opt/local/share
else
	ZSH_EXT_DIR=/usr/share
fi
PATH=$HOME/pkg/bin:$PATH

export LC_CTYPE PATH EDITOR

source $ZSH_EXT_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
	>/dev/null 2>&1
