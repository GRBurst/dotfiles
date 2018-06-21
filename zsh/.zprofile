[[ -e ~/.profile ]] && emulate sh -c 'source ~/.profile'
[[ -z $DISPLAY && $XDG_VTNR -le 3 ]] && exec startx

# color wrappers for common commands
export PATH=$(cope_path):$PATH

# colorful file listings
eval $(dircolors ~/.dir_colors)

# vimpager instead of less
export PAGER=/usr/bin/vimpager

# colorize manpages (when using less as pager)
export LESS_TERMCAP_mb=$(printf "\33[01;34m")   # begin blinking
export LESS_TERMCAP_md=$(printf "\33[01;34m")   # begin bold
export LESS_TERMCAP_me=$(printf "\33[0m")       # end mode
export LESS_TERMCAP_se=$(printf "\33[0m")       # end standout-mode
export LESS_TERMCAP_so=$(printf "\33[44;1;37m") # begin standout-mode - info box
export LESS_TERMCAP_ue=$(printf "\33[0m")       # end underline
export LESS_TERMCAP_us=$(printf "\33[01;35m")   # begin underline

# fzf fuzzy file finder
export FZF_DEFAULT_COMMAND='ag --hidden -g ""'
export FZF_DEFAULT_OPTS="-x -m --ansi --exit-0 --select-1" # extended match and multiple selections

# https://github.com/chenkelmann/neo2-awt-hack
# curl https://github.com/chenkelmann/neo2-awt-hack/blob/master/releases/neo2-awt-hack-0.4-java8oracle.jar\?raw\=true > ~/local/neo2-awt-hack-0.4-java8oracle.jar
export _JAVA_OPTIONS=" -Xbootclasspath/p:$HOME/bin/neo2-awt-hack-0.4-java8oracle.jar"
