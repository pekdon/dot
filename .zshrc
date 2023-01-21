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

# provide VCS information in the prompt
autoload -Uz vcs_info
zstyle ':vcs_info:git:*' formats "(%b) "
precmd() {
	vcs_info
}

setopt prompt_subst
PROMPT='%{$fg[yellow]%}%T%{$reset_color%} %m %{$fg[green]%}%1~%{$reset_color%} %{$fg[blue]%}${vcs_info_msg_0_}%{$reset_color%}[%?]%{$fg[cyan]%}%#%{$reset_color%} '
case $TERM in
    xterm*)
        chpwd () { print -Pn "\e]0;%n@%m: %~\a" }
        periodic() { xterm_control_timeofday.sh }
        PERIOD=300
        # initial set before any change of directory
        print -Pn "\e]0;%n@%m: %~\a"
        ;;
esac

which nvim >/dev/null 2>&1
if test $? -eq 0; then
	EDITOR=nvim
else
	EDITOR=vim
fi
LC_CTYPE=en_US.UTF-8

# add optional directories to the PATH
path_add() {
	if test -d "$1"; then
		PATH="$1:$PATH"
	fi
}

path_add "/usr/pkg/bin"
path_add "/opt/local/bin"
path_add "$HOME/go/bin"
path_add "$HOME/.local/bin"
path_add "$HOME/pkg/bin"

export LC_CTYPE PATH EDITOR

# load extensions
if test -d /usr/pkg/bin; then
	ZSH_EXT_DIR=/usr/pkg/share
elif test -d /usr/local/share/zsh; then
	ZSH_EXT_DIR=/usr/local/share
elif test -d /opt/local/share/zsh; then
	ZSH_EXT_DIR=/opt/local/share
else
	ZSH_EXT_DIR=/usr/share
fi

source $ZSH_EXT_DIR/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh \
	>/dev/null 2>&1

export GPG_TTY=`tty 2>/dev/null`
