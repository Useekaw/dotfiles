#!/bin/bash
PROXMOX="pve"
VM_ID="10013"
VV_FILE="/tmp/hoth_${VM_ID}.vv"

/home/usee/.local/bin/wake_hoth.sh || exit 1

ssh -o BatchMode=yes $PROXMOX "sudo /usr/sbin/qm spiceproxy $VM_ID" > "$VV_FILE"

remote-viewer "$VV_FILE"
rm -f "$VV_FILE"
