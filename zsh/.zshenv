export BROWSER=firefox
export SUDO_EDITOR=rvim
export VISUAL="vim"
#export PAGER=vimpager
export PAGER=less

export QT_QPA_PLATFORMTHEME="qt5ct"
export DE=gnome
export XDG_CURRENT_DESKTOP=gnome

# color wrappers for common commands
export PATH="$(cope_path)":$PATH

# add home bin folder to path
export PATH="$HOME/bin":$PATH

export PATH=$PATH:"$HOME/local/lyx-gc/"

# add npm to path
export PATH="$HOME/.node_modules/bin":$PATH

# Ibus
export GTK_IM_MODULE=ibus
export XMODIFIERS=@im=ibus
export QT_IM_MODULE=ibus

# Rust
export PATH=$HOME/.multirust/toolchains/nightly/cargo/bin:$PATH
export RUST_SRC_PATH=$HOME/projects/rust/src

# Android
export ANDROID_HOME=/opt/android-sdk

# fix java apps in tiling window managers
export _JAVA_AWT_WM_NONREPARENTING=1

# fix java apps font rendering
# javaopts=$javaopts" -Dawt.useSystemAAFontSettings=gasp -Dsun.java2d.xrender=true -Dswing.aatext=true"
export AWT_TOOLKIT=MToolkit
export GDK_USE_XFT=1

# sbtopts="$sbtopts -Xms64M -Xmx4G -Xss1M -XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC"
sbtopts="$sbtopts -Xms64M -Xmx4G -Xss4M -XX:+CMSClassUnloadingEnabled -XX:+UseConcMarkSweepGC"
export SBT_OPTS=$sbtopts

# https://github.com/chenkelmann/neo2-awt-hack
# curl https://github.com/chenkelmann/neo2-awt-hack/blob/master/releases/neo2-awt-hack-0.4-java8oracle.jar\?raw\=true > ~/local/neo2-awt-hack-0.4-java8oracle.jar
export _JAVA_OPTIONS=" -Xbootclasspath/p:$HOME/bin/neo2-awt-hack-0.4-java8oracle.jar"
