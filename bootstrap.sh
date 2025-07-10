#!/usr/bin/env bash

set -eu pipefail

USER_BIN="$HOME/.local/bin"

abort() {
  printf "ERROR: $s\n" "$@" >&2
}

log() {
  printf "################################################################################\n"
  printf "%s\n" "$@"
  printf "################################################################################\n"
}

install_brew() {
  /bin/bash -c "NONINTERACTIVE=1 $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
}

main() {
  for program in wget gunzip tar command chmod rm printf mv mkdir; do
    command -v "$program" >/dev/null 2>&1 || {
      echo "Not found: $program"
      abort "Missing dependencies." 
    }
  done

  command -v brew >/dev/null 2>&1 || install_brew

  log "Dotfiles configured!"
}

main


