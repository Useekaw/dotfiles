# initialize plugin manager
ZINIT_HOME="${XDG_DATA_HOME:-${HOME}/.local/share}/zinit/zinit.git"
if [ ! -d "${ZINIT_HOME}" ]; then
    mkdir -p "$(dirname ${ZINIT_HOME})"
    git clone https://github.com/zdharma-continuum/zinit.git "${ZINIT_HOME}"
fi

# disable zi alias in favour of zoxide
typeset -gA ZINIT
ZINIT[NO_ALIASES]=1

source "${ZINIT_HOME}/zinit.zsh"

