set nocompatible
set showmatch
set colorcolumn=80
set cursorline
syntax on
" disable mouse integration, terminal is fully capable of copying
" and pasting text
set mouse=
" highlight search results
set hlsearch
" autoindent depending on file type
set autoindent
filetype plugin indent on
" bash-like tab completion
set wildmode=longest,list
set number

" spell-check us
set spell spelllang=en_us

" enable use of the shipped Man command
runtime ftplugin/man.vim
" enable use of the shipped editorconfig
packadd! editorconfig

colorscheme iceberg

" function to update background color based on _PEKWM_THEME_VARIANT property
" set on the root window
function! PekwmThemeBackground()
	let l:prop = system("xprop -root _PEKWM_THEME_VARIANT")
	if prop =~ '"light"'
		set background=light
	elseif prop =~ '"dark"'
		set background=dark
	endif
endfunction
call PekwmThemeBackground()
