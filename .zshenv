## Exports to define environment
# Default programs
export BROWSER=firefox
export SUDO_EDITOR=rvim
export VISUAL="vim"
export PAGER=less
# export PAGER=vimpager

# Desktop environment
export QT_QPA_PLATFORMTHEME="qt5ct"
export DE=gnome
export XDG_CURRENT_DESKTOP=gnome

# dottr for git
export PATH=$HOME/projects/dottr/pan.git:$PATH

# add home bin folder to path
export PATH="$HOME/projects/bin":$PATH
export PATH="$HOME/local/bin":$PATH

# add npm to path
export PATH="$HOME/.node_modules/bin":$PATH

# Always source zgen -> needed for update script
# source  "${HOME}/local/zgen/zgen.zsh"

# Ibus
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus

# Rust
#export PATH=$HOME/.multirust/toolchains/nightly/cargo/bin:$PATH
#export RUST_SRC_PATH=$HOME/projects/rust/src
export RUSTFLAGS="-L $HOME/.rustup/toolchains/stable-x86_64-unknown-linux-gnu/lib/rustlib/x86_64-unknown-linux-gnu/lib/"
export RUST_BACKTRACE=1

# Android -> nixos?
#export ANDROID_HOME=/opt/android-sdk

# fix java apps in tiling window managers
export _JAVA_AWT_WM_NONREPARENTING=1

# fix java apps font rendering
# javaopts=$javaopts" -Dawt.useSystemAAFontSettings=gasp -Dsun.java2d.xrender=true -Dswing.aatext=true"
export AWT_TOOLKIT=MToolkit
export GDK_USE_XFT=1

# sbtopts="$sbtopts -Xms64M -Xmx4G -Xss1M -XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC"
sbtopts="$sbtopts -Xms64M -Xmx4G -Xss4M -XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC"
export SBT_OPTS=$sbtopts

## Enhance environment
# color wrappers for common commands
which cope_path > /dev/null && export PATH=$(cope_path):$PATH

# colorful file listings
eval $(dircolors ~/.dir_colors)

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
