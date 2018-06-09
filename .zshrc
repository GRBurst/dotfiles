export PURE_GIT_PULL=0 # disable pure-promt git pull when entering git repo
DISABLE_AUTO_UPDATE="true" # disable oh-my-zsh auto-update

eval    "$(fasd --init auto)"
source  "${HOME}/local/zgen/zgen.zsh"

if ! zgen saved; then
    echo "creating zgen save..."
    zgen oh-my-zsh # oh-my-zsh default settings

    zgen load zsh-users/zsh-syntax-highlighting

    zgen load mafredri/zsh-async # for pure-prompt
    zgen load sindresorhus/pure # prompt
    zgen load b4b4r07/zsh-vimode-visual

    zgen load dottr/dottr

    # must be last, because it wraps all widgets
    zgen load zsh-users/zsh-syntax-highlighting

    zgen save
fi

# needed for bind2maps
typeset -A key
key=(
Home     "${terminfo[khome]}"
End      "${terminfo[kend]}"
Insert   "${terminfo[kich1]}"
Delete   "${terminfo[kdch1]}"
Backspace "^?"
Up       "${terminfo[kcuu1]}"
Down     "${terminfo[kcud1]}"
Left     "${terminfo[kcub1]}"
Right    "${terminfo[kcuf1]}"
PageUp   "${terminfo[kpp]}"
PageDown "${terminfo[knp]}"
BackTab  "${terminfo[kcbt]}"
)


fry completion
fry ncserve
fry alias-usage-analysis
fry print-expanded-alias
# fry vim-open-files-at-lines
fry search-select-edit
fry git-select-commit
fry git-onstage
fry github-clone
fry interactive-mv
fry cd-tmp
fry cd-git-root
fry neo4j-query
#NEO4J_QUERY_JSON_FORMATTER="underscore print --color --outfmt json"
fry mkdir-cd
fry screencapture
fry transcode-video
fry bind2maps
fry git-dirty-files-command
fry watchdo


setopt nonomatch # avoid the zsh "no matches found" / allows sbt ~compile
setopt hash_list_all # rehash command path and completions on completion attempt
setopt transient_rprompt # hide earlier rprompts
unsetopt flow_control # we do not want no flow control, Ctrl-s / Ctrl-q, this allows vim to map <C-s>
stty -ixon # (belongs to flow control option)
autoload -U zmv # renaming utils

# activate vi modes and display mode indicator in prompt
source ~/.zshrc.vimode
RPROMPT='${MODE_INDICATOR}'


# history prefix search
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bind2maps emacs viins vicmd -- "Up" up-line-or-search
bind2maps emacs viins vicmd -- "Down" down-line-or-search

# fzf fuzzy file matcher shell extensions
. $HOME/.vim/bundle/fzf/shell/completion.zsh
. $HOME/.vim/bundle/fzf/shell/key-bindings.zsh

source ~/.zaliases

# added by travis gem
[ -f /home/jelias/.travis/travis.sh ] && source /home/jelias/.travis/travis.sh
