# history
HISTSIZE=5000
HISTFILE="${XDG_STATE_HOME}/zsh_history"
SAVEHIST="${HISTSIZE}"
HISTDUP=erase

setopt appendhistory
setopt sharehistory
setopt hist_ignore_space
setopt hist_ignore_all_dups
setopt hist_save_no_dups
setopt hist_ignore_dups
setopt hist_find_no_dups

