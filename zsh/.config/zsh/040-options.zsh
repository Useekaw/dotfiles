# completions
autoload -Uz compinit && compinit
# matches case insensitive for lowercase
zstyle ':completion:*' matcher-list 'm:{a-zA-Z}={A-Za-z}'
zstyle ':completion:*' menu select
compdef w=-redirect-,-default-,-default- # gives w <tab> autocomplete

# History
HISTSIZE=10000 # lines of history to keep in memory
HISTFILESIZE=10000 # number of lines saved to file
SAVEHIST=10000 # number of history entries saved 
HISTFILE=$CACHE_DIR/.zsh_history # history locations
HISTDUP=erase # erase duplicates in history file
setopt hist_ignore_dups # ignore duplicates

# Options - `man zshoptions`
setopt append_history # append history to file
setopt share_history # share history across terminals
setopt inc_append_history # immediately append history to file
setopt extended_glob # use extended globbing syntax
setopt auto_cd # auto change dir without cd

# Dirstack
export DIRSTACKSIZE=9
setopt autopushd pushdminus pushdsilent pushdtohome
