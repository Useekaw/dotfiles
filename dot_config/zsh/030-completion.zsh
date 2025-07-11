export ZCOMPDIR="${XDG_CACHE_HOME}/zcompcache"

# load completions
# autoload -Uz compinit && compinit -d "${ZCOMPDIR}/.zcompdump"
autoload -U compinit && compinit

set -o autopushd
zinit cdreplay -q

# completion styling
# zstyle ':completion::complete:*' cache-path "${ZCOMPDIR}"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu no
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'ls --color $realpath'
zstyle ':fzf-tab:complete:__zoxide_z:*' fzf-preview 'ls --color $realpath'

