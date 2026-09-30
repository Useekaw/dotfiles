# Refresh the update-notice cache right after an actual brew/chezmoi update,
# instead of waiting for tomorrow's timer run — avoids a stale "update
# available" notice in shells opened after you already updated.

brew() {
  command brew "$@"
  local ec=$?
  case "$1" in
    update|upgrade)
      "${HOME}/.local/bin/brew-update-check"
      ;;
  esac
  return $ec
}

chezmoi() {
  command chezmoi "$@"
  local ec=$?
  case "$1" in
    apply|update|init|re-add)
      "${HOME}/.local/bin/chezmoi-update-check"
      ;;
  esac
  return $ec
}
