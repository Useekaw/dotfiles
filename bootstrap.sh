#!/usr/bin/env bash

set -eu pipefail

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
  mkdir -p "$HOME/.cache"
  mkdir -p "$HOME/.config/environment.d/"
  mkdir -p "$HOME/.local/bin"
  mkdir -p "$HOME/.local/share"
  mkdir -p "$HOME/.local/state"
}

install_deps() {
  if command -v pacman &>/dev/null; then
    sudo pacman -Suy --needed --noconfirm base-devel procps-ng curl file git zsh wget gzip tar
  elif command -v dnf &>/dev/null; then
    sudo dnf install -y gcc gcc-c++ make procps-ng curl file git zsh wget gzip tar
  elif command -v apt &>/dev/null; then
    sudo apt update && sudo apt install -y build-essential procps curl file git zsh wget gzip tar
  else
    abort "No supported package manager found (pacman, dnf, apt)."
}

main() {
  make_dirs
  install_deps

  # prevent future creation of xdg directories
  sudo sed -i 's/enabled=True/enabled=False/' /etc/xdg/user-dirs.conf
  rmdir ~/Bilder ~/Dokumente ~/Musik ~/Öffentlich ~/Schreibtisch ~/Videos ~/Vorlagen ~/Downloads
  mkdir  ~/downloads

  # install homebrew
  command -v brew >/dev/null 2>&1 || /bin/bash -c \
    "NONINTERACTIVE=1 $(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  # enable homebrew for this shell
  eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
  brew analytics off
  # add brew to default bashrc to have it always available (even though we are using zsh)
  echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> "$HOME/.bashrc"

  # bootstrap initial tools. everything else will be installed via brewfile
  brew install age
  brew install chezmoi

  # initiate chezmoi
  # chezmoi init [repo] [flags]
  # [repo] is guessed via given username, looking for a dotfiles.gig on github
  # [flags] apply to destination directory and use ssh
  chezmoi init Useekaw --apply --ssh

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


