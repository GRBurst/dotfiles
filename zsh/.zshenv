export BROWSER=firefox
export SUDO_EDITOR=rvim
export VISUAL="vim"

# color wrappers for common commands
export PATH="$(cope_path)":$PATH

# add home bin folder to path
export PATH="$HOME/bin":$PATH

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
