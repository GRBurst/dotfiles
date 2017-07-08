# README #

Dotfiles /configs / config files I am using. Feel free to do anything with it ;-)

Previously used with stow -> see branch 'stow'.

Now using plain git with different working tree.
Repo is located in $HOME/projects/dotfiles while index is over $HOME

Usage:
```bash
mkdir -p ~/projects
git clone --bare https://github.com/fdietze/dotfiles.git projects/dotfiles
GIT_DIR=$HOME/projects/dotfiles GIT_WORK_TREE=$HOME git checkout master

git clone https://github.com/tarjoilija/zgen.git "${HOME}/.zgen"
```
