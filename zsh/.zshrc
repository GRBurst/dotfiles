eval "$(fasd --init auto)"

# load zgen
source "${HOME}/.zsh/zgen/zgen.zsh"

if ! zgen saved; then
    echo "creating zgen save..."
    zgen oh-my-zsh # oh-my-zsh default settings

    zgen load zsh-users/zsh-syntax-highlighting
    zgen load zsh-users/zsh-history-substring-search # needs to be loaded after highlighting
    zgen load jimhester/per-directory-history

    zgen load tarruda/zsh-autosuggestions

    zgen load mafredri/zsh-async # for pure-prompt
    zgen load sindresorhus/pure # prompt

    zgen load dottr/dottr
    zgen save
fi

# bind UP and DOWN arrow keys
bindkey '^[[A' history-substring-search-up
bindkey '^[[B' history-substring-search-down


fry completion
fry ncserve
fry pacman-disowned
fry alias-usage-analysis
fry print-expanded-alias
fry search-select-edit
fry git-select-commit
fry git-onstage
fry github-clone
fry interactive-mv
fry cd-tmp
fry cd-git-root
fry mkdir-cd
fry aur-remove-vote


# command not found for Arch
[ -r /etc/profile.d/cnf.sh ] && . /etc/profile.d/cnf.sh

source ~/.zaliases

# renaming utils
autoload -U zmv

setopt nonomatch # avoid the zsh "no matches found" / allows sbt ~compile
setopt hash_list_all # rehash command path and completions on completion attempt
setopt share_history

# Vi-mode for zsh
# bindkey -v
# export KEYTIMEOUT=1
