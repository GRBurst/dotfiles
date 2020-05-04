[[ -e ~/.zprofile ]] && emulate sh -c 'source ~/.zprofile'

source ~/.zprofile

export PURE_GIT_PULL=0 # disable pure-promt git pull when entering git repo
export DISABLE_AUTO_UPDATE="true" # disable oh-my-zsh auto-update
export DISABLE_UPDATE_PROMPT="true" # disable oh-my-zsh update prompt
export ZSH_DISABLE_COMPFIX="true" # disable oh-my-zsh security check

eval    "$(fasd --init auto)"
source  "${HOME}/local/zgen/zgen.zsh"

if ! zgen saved; then
    echo "creating zgen save..."
    zgen oh-my-zsh # oh-my-zsh default settings

    # zgen load mafredri/zsh-async # for pure-prompt
    # zgen load sindresorhus/pure # prompt
    zgen load b4b4r07/zsh-vimode-visual

    zgen load dottr/dottr
    zgen load denysdovhan/spaceship-prompt spaceship

    # must be last, because it wraps all widgets
    zgen load zsh-users/zsh-syntax-highlighting

    zgen save
fi

SPACESHIP_PROMPT_ORDER=(
  time          # Time stamps section
  user          # Username section
  dir           # Current directory section
  host          # Hostname section
  git           # Git section (git_branch + git_status)
  # hg            # Mercurial section (hg_branch  + hg_status)
  package       # Package version
  # node          # Node.js section
  # ruby          # Ruby section
  # elixir        # Elixir section
  # xcode         # Xcode section
  # swift         # Swift section
  # golang        # Go section
  # php           # PHP section
  rust          # Rust section
  haskell       # Haskell Stack section
  julia         # Julia section
  # docker        # Docker section
  aws           # Amazon Web Services section
  venv          # virtualenv section
  conda         # conda virtualenv section
  pyenv         # Pyenv section
  # dotnet        # .NET section
  # ember         # Ember.js section
  # kubecontext   # Kubectl context section
  # terraform     # Terraform workspace section
  exec_time     # Execution time
  line_sep      # Line break
  battery       # Battery level and status
  # vi_mode       # Vi-mode indicator
  jobs          # Background jobs indicator
  exit_code     # Exit code section
  char          # Prompt character
)
SPACESHIP_CHAR_SYMBOL="❯ "
SPACESHIP_GIT_STATUS_STASHED=""

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

fry alias-usage-analysis
fry bell-on-precmd
fry bind2maps
fry cd-git-root
fry cd-tmp
fry completion
fry github-clone
fry git-dirty-files-command
fry git-onstage
fry git-select-commit
fry interactive-mv
fry mkdir-cd
fry ncserve
fry nvim-rpc
fry print-expanded-alias
fry screencapture
fry search-select-edit
fry transcode-video
fry watchdo
fry aws-profile-status
# fry vim-open-files-at-lines
# fry neo4j-query
#NEO4J_QUERY_JSON_FORMATTER="underscore print --color --outfmt json"
# fry docker-host-status

setopt nonomatch # avoid the zsh "no matches found" / allows sbt ~compile
setopt hash_list_all # rehash command path and completions on completion attempt
setopt transient_rprompt # hide earlier rprompts
unsetopt flow_control # we do not want no flow control, Ctrl-s / Ctrl-q, this allows vim to map <C-s>
stty -ixon # (belongs to flow control option)
autoload -U zmv # renaming utils

# activate vi modes and display mode indicator in prompt
source ~/.zshrc.vimode
RPROMPT='${MODE_INDICATOR}'

bind2maps emacs viins vicmd -- -s '^[[1;5C' forward-word
bind2maps emacs viins vicmd -- -s '^[[1;5D' backward-word

autoload edit-command-line
zle -N edit-command-line
bind2maps vicmd viins -- -s '^v' edit-command-line

autoload bashcompinit && bashcompinit

# history prefix search
autoload -U history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bind2maps emacs viins vicmd -- "Up" up-line-or-search
bind2maps emacs viins vicmd -- "Down" down-line-or-search

# fzf fuzzy file matcher shell extensions
if [ -n "${commands[fzf-share]}" ]; then
    source "$(fzf-share)/key-bindings.zsh"
    source "$(fzf-share)/completion.zsh"
fi
# . $HOME/.vim/bundle/fzf/shell/completion.zsh
# . $HOME/.vim/bundle/fzf/shell/key-bindings.zsh

source ~/.zaliases

# added by travis gem
[ -f $HOME/.travis/travis.sh ] && source $HOME/.travis/travis.sh

# broot
[ -f $HOME/.config/broot/launcher/bash/br ] && source $HOME/.config/broot/launcher/bash/br

[ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

cd $HOME/projects/listo
