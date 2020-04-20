## Exports to define environment
# Default programs
export BROWSER=firefox
export SUDO_EDITOR=rvim
export EDITOR=nvim
export VISUAL="nvim"
export PAGER="less -R -F"
# export PAGER=vimpager

# Desktop environment
# if [ -n "$DESKTOP_SESSION" ]; then
#     eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh,gpg)
# fi
export QT_QPA_PLATFORMTHEME="qt5ct"
export DE=gnome
export XDG_CURRENT_DESKTOP=gnome

# dottr for git
export PATH=$HOME/.zgen/dottr/dottr-master/pan.git:$PATH

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

#export _JAVA_OPTIONS="-Xms1G -Xmx4G -Xss1M -XX:MetaspaceSize=300M -XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC -XX:+UseCompressedOops -Dawt.useSystemAAFontSettings=lcd";
# export _JAVA_OPTIONS="-Xms1G -Xmx4G -Xss1M -XX:MetaspaceSize=300M -XX:MaxMetaspaceSize=2G -XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC -XX:+UseCompressedOops -Dawt.useSystemAAFontSettings=lcd -Xbootclasspath/p:$HOME/local/jars/neo2-awt-hack-0.4-java8oracle.jar";
# export JAVA_OPTS="-Xms1G -Xmx4G -Xss1M -XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC"
# export SBT_OPTS="-J-Xms1G -J-Xmx4G -J-Xss1M -J-XX:+CMSClassUnloadingEnabled -J-XX:+UseConcMarkSweepGC"

# Idea neo keyboard
# export _JAVA_OPTIONS="-Xms1G -Xmx4G -Xss1M -XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC -XX:+UseCompressedOops -Dawt.useSystemAAFontSettings=lcd -Xbootclasspath/p:$HOME/local/jars/neo2-awt-hack-0.4-java8oracle.jar"

## Enhance environment
# color wrappers for common commands
which cope_path > /dev/null && export PATH=$(cope_path):$PATH

# colorful file listings
if [ -n "${commands[dircolors]}" ]; then
    eval $(dircolors ~/.dir_colors)
fi

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
