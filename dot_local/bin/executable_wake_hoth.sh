#!/bin/bash
PROXMOX="pve"
VM_IP="192.168.84.13"
VM_ID="10013"
USER="usee"

ssh -o BatchMode=yes $PROXMOX "sudo /usr/sbin/qm status $VM_ID | grep -q 'stopped' && sudo /usr/sbin/qm resume $VM_ID"

# VM clock drifts while suspended/paused, Windows fires no reliable resume event.
# Guest Agent channel comes up before the network stack, so sync via it here
# instead of waiting for RDP below.
for i in {1..30}; do
    ssh -o BatchMode=yes $PROXMOX "sudo /usr/sbin/qm agent $VM_ID ping" &>/dev/null && break
    sleep 1
done
ssh -o BatchMode=yes $PROXMOX "sudo /usr/sbin/qm guest exec $VM_ID --timeout 15 -- C:\\\\Windows\\\\System32\\\\w32tm.exe /resync /force" &>/dev/null

for i in {1..60}; do
    (echo > /dev/tcp/$VM_IP/3389) &>/dev/null && exit 0
    sleep 1
done
exit 1
