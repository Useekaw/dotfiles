#!/bin/bash
# Connects to the hoth VM via RDP with the FreeRDP SDL client.
#   full:   docked, one fullscreen window per dock monitor; undocked,
#           fullscreen on the laptop panel. Remmina and xfreerdp can't do
#           multimon under niri: they draw all monitors into a single
#           window, and niri never lets a window span outputs.
#   window: one regular niri window; Windows follows its size live, but
#           only has one monitor in this mode.
# Switching mode means reconnecting; the Windows session stays alive.
# Password comes from gnome-keyring, set it once with:
#   secret-tool store --label="hoth RDP" service hoth-rdp user fabian
MODE="${1:-full}"
VM_IP="192.168.84.13"
RDP_USER="fabian"
# Matched by model, not connector: the MST dock renumbers DP-N on replug.
DOCK_MODELS=("DELL S3220DGF" "DELL P2219H")

docked() {
    local outputs_json m
    outputs_json=$(niri msg --json outputs) || return 1
    for m in "${DOCK_MODELS[@]}"; do
        jq -e --arg m "$m" 'any(.[]; .model == $m)' <<<"$outputs_json" >/dev/null || return 1
    done
}

/home/usee/.local/bin/wake_hoth.sh || {
    notify-send "Hoth" "VM did not come up (RDP port closed)"
    exit 1
}

PASSWORD=$(secret-tool lookup service hoth-rdp user "$RDP_USER")
if [ -z "$PASSWORD" ]; then
    notify-send "Hoth" "Keyring locked or no password stored, set it with: secret-tool store --label=\"hoth RDP\" service hoth-rdp user $RDP_USER"
    exit 1
fi

args=(/v:"$VM_IP" /u:"$RDP_USER" /p:"$PASSWORD" /gfx +clipboard /cert:tofu)
case "$MODE" in
    full) args+=(/title:hoth); if docked; then args+=(/multimon); else args+=(/f); fi ;;
    # Title matched by a niri window rule that tiles this mode only;
    # applied to the multimon windows it breaks their fullscreen layout.
    window) args+=(/title:hoth-window /dynamic-resolution) ;;
    *) echo "usage: $0 [full|window]" >&2; exit 2 ;;
esac

# /args-from keeps the password out of the process list.
printf '%s\n' "${args[@]}" | sdl-freerdp3 /args-from:stdin
