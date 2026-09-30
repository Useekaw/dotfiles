#!/bin/bash
PROXMOX="pve"
NODE="pve"
VM_ID="10013"
VV_FILE="/tmp/hoth_${VM_ID}.vv"

/home/usee/.local/bin/wake_hoth.sh || exit 1

JSON=$(ssh -o BatchMode=yes $PROXMOX "sudo pvesh create /nodes/${NODE}/qemu/${VM_ID}/spiceproxy --output-format json") || exit 1

{
    echo "[virt-viewer]"
    echo "type=spice"
    echo "host=$(echo "$JSON" | jq -r '.host')"
    echo "proxy=$(echo "$JSON" | jq -r '.proxy')"
    echo "tls-port=$(echo "$JSON" | jq -r '.["tls-port"]')"
    echo "password=$(echo "$JSON" | jq -r '.password')"
    echo "ca=$(echo "$JSON" | jq -r '.ca')"
    echo "host-subject=$(echo "$JSON" | jq -r '.["host-subject"]')"
    echo "title=$(echo "$JSON" | jq -r '.title')"
    echo "toggle-fullscreen=$(echo "$JSON" | jq -r '.["toggle-fullscreen"]')"
    echo "release-cursor=$(echo "$JSON" | jq -r '.["release-cursor"]')"
    echo "secure-attention=$(echo "$JSON" | jq -r '.["secure-attention"]')"
    echo "delete-this-file=1"
} > "$VV_FILE"

remote-viewer "$VV_FILE"
rm -f "$VV_FILE"
