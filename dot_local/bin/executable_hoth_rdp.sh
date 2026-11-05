#!/bin/bash
# Connects to the hoth VM via RDP with the FreeRDP SDL client.
#   full:   one fullscreen window per active output (both dock monitors,
#           or the laptop panel alone when undocked). Remmina and xfreerdp
#           can't do this under niri: they draw all monitors into a single
#           window, and niri never lets a window span outputs.
#   window: one regular niri window; Windows follows its size live, but
#           only has one monitor in this mode.
# Switching mode means reconnecting; the Windows session stays alive.
# Password comes from gnome-keyring, set it once with:
#   secret-tool store --label="hoth RDP" service hoth-rdp user fabian
MODE="${1:-full}"
VM_IP="192.168.84.13"
RDP_USER="fabian"

/home/usee/.local/bin/wake_hoth.sh || {
    notify-send "Hoth" "VM did not come up (RDP port closed)"
    exit 1
}

PASSWORD=$(secret-tool lookup service hoth-rdp user "$RDP_USER") || {
    notify-send "Hoth" "No password in keyring, run: secret-tool store --label=\"hoth RDP\" service hoth-rdp user $RDP_USER"
    exit 1
}

args=(/v:"$VM_IP" /u:"$RDP_USER" /p:"$PASSWORD" /gfx +clipboard /cert:tofu /title:hoth)
case "$MODE" in
    full) args+=(/multimon) ;;
    window) args+=(/dynamic-resolution) ;;
    *) echo "usage: $0 [full|window]" >&2; exit 2 ;;
esac

# /args-from keeps the password out of the process list.
printf '%s\n' "${args[@]}" | sdl-freerdp3 /args-from:stdin
