#!/bin/sh
#
# Setup environment using dot files as master, downloading remote
# content for resources such as fonts.
#

DOT_DIR="$(cd `dirname $0` && pwd)"

FONT_MASTER="https://github.com/cormullion/juliamono/raw/master"
FONT_NAME="JuliaMono-Regular.ttf"

GTK_THEME_MASTER="https://github.com/thesquash"
GTK_THEME="gtk-theme-raleigh"
PEKWM_THEME="pwm-p"

verify_required_tools()
{
    for i in curl git; do
	which $i >/dev/null 2>&1
	if test $? -ne 0; then
	    echo "required tool $i not found, aborting"
	    exit 1
	fi
    done
}

build()
{
    echo "build tools"
    make -C "$DOT_DIR/src"
}

make_dirs()
{
    echo "create non version control directory structure"
    mkdir -p ~/git ~/projects ~/tmp/download
}

link_files()
{
    echo "link files (bin)"
    mkdir -p "$HOME/pkg/bin"
    for i in `ls "$DOT_DIR/bin/"`; do
	ln -sf "$DOT_DIR/bin/$i" "$HOME/pkg/bin/`basename $i`"
    done
    ln -sf "$DOT_DIR/src/shell_util" "$HOME/pkg/bin/shell_util"

    echo "link files (dot)"
    for i in .config .emacs.d .gitconfig .pekwm .tmux.conf .vimrc \
	     .Xdefaults .xsession .xscreensaver .zshrc; do
	ln -sf "$DOT_DIR/$i" "$HOME/$i"
    done
}

init_dot_emacs()
{
    if test -e "$HOME/.emacs"; then
	return
    fi

    echo "setup .emacs to load .emacs.d/init.el"
    cat > ~/.emacs <<EOF
(load-file "~/.emacs.d/init.el")

(custom-set-variables
 '(package-selected-packages '(spacemacs-theme)))
EOF
}

download_fonts()
{
    mkdir -p "$HOME/.local/share/fonts"
    if ! test -e "$HOME/.local/share/fonts/$FONT_NAME"; then
	echo "downloading $FONT_NAME..."
	curl -L --silent --output "$HOME/.local/share/fonts/$FONT_NAME" \
	     "$FONT_MASTER/$FONT_NAME"
    fi
}

download_gtk_themes()
{
    if ! test -e "$HOME/git/$GTK_THEME"; then
	echo "downloading gtk theme $GTK_THEME..."
	(cd $HOME/git ; git clone $GTK_THEME_MASTER/$GTK_THEME.git)
    fi
    mkdir -p $HOME/.local/share/themes
    ln -sf $HOME/git/$GTK_THEME/themes/* $HOME/.local/share/themes
}

download_pekwm_themes()
{
    if ! test -e "$HOME/.pekwm/themes/pwm-p"; then
	echo "downloading pekwm theme $PEKWM_THEME..."
	pekwm_theme install $PEKWM_THEME
    fi
}

reload_config()
{
    echo "loading Xdefaults"
    xrdb $HOME/.Xdefaults

    echo "refreshing font cache"
    fc-cache

    pekwm_pid=`xprop -root _NET_WM_PID 2>/dev/null | awk '/ = / { print $3 }'`
    if ! test -z "$pekwm_pid"; then
	echo "reloading pekwm configuration"
	kill -HUP $pekwm_pid
    fi
}

verify_required_tools

build
make_dirs
link_files
init_dot_emacs
download_fonts
download_gtk_themes
download_pekwm_themes
reload_config
