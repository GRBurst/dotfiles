# README #

Dotfiles /configs / config files I am using. Feel free to do anything with it ;-)

Previously used with stow -> see branch 'stow'.

Now using plain git with different working tree.
Repo is located in $HOME/projects/dotfiles while index is over $HOME

Usage:
```bash
# Create project folder
mkdir -p ~/projects

# Clone dotfiles with ssh
git clone --bare git@github.com:GRBurst/dotfiles.git projects/dotfiles

# OR with https (if ssh is not configured yet)
git clone --bare https://github.com/GRBurst/dotfiles.git projects/dotfiles

# Initially checkout master
GIT_DIR=$HOME/projects/dotfiles GIT_WORK_TREE=$HOME git checkout master

# Clone zgen (used in dotfiles)
git clone https://github.com/tarjoilija/zgen.git "${HOME}/local/zgen"

# Modify and run upgrade
basic-upgrade
```
