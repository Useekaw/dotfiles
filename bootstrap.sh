#!/usr/bin/env bash

set -eu pipefail

USER_BIN="$HOME/.local/bin"

abort() {
  printf "ERROR: %s\n" "$@" >&2
  exit 1
}

log() {
  printf "################################################################################\n"
  printf "%s\n" "$@"
  printf "################################################################################\n"
}

make_dirs() {
  mkdir -p "$HOME/.local/share"
  mkdir -p "$HOME/.config"
  mkdir -p "$HOME/.local/state"
  mkdir -p "$HOME/.cache"
}

install_deps() {
  sudo apt update && sudo apt install -y build-essential procps curl file git zsh
}

main() {
  make_dirs
  install_deps

  for program in wget gunzip tar command chmod rm printf mv mkdir; do
    command -v "$program" >/dev/null 2>&1 || {
      echo "Not found: $program"
      abort "Missing dependencies." 
    }
  done

  # install homebrew
  command -v brew >/dev/null 2>&1 || /bin/bash -c "NONINTERACTIVE=1 $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # enable homebrew for this shell
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  brew analytics off
  # add brew to default bashrc to have it always available (even though we are using zsh)
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.bashrc"

  # install initial tools
  brew install age
  brew install chezmoi

  # initiate chezmoi
  chezmoi init --apply Useekaw

  # install managed tools
  brew bundle --file "${HOME}/.brewfile" --verbose

  # update shell if necessary
  if [[ "$(basename "$SHELL")" != "zsh" ]]; then
    if command -v zsh &> /dev/null; then
        chsh -s "$(command -v zsh)"
        log "chsh command executed. Please log out and log back in for the changes to take effect."
    else
        abort "zsh is not installed. Cannot change shell."
    fi
  else
    log "Dotfiles configured!"
  fi

}

main


