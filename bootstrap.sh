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

install_deps() {
  sudo apt update && sudo apt install -y build-essential procps curl file git
}

main() {
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

  log "Dotfiles configured!"
}

main


