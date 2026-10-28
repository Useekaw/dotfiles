#!/bin/bash
PROXMOX="pve.faha.home"
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
# w32tm /resync /force refuses large offsets (phase-correction check applies
# even with /force); registry limit bumps don't help. Instead compute the
# true offset via stripchart and set the clock directly (-EncodedCommand
# avoids quoting across ssh -> qm guest exec -> Windows cmdline).
#
# Unencoded PowerShell (base64 below is this, UTF-16LE):
#   $l = w32tm /stripchart /computer:0.at.pool.ntp.org /samples:1 /dataonly | Select-Object -Last 1
#   $o = [double]::Parse((($l -split ",\s*")[1]).TrimEnd("s"), [Globalization.CultureInfo]::InvariantCulture)
#   Set-Date ((Get-Date).ToUniversalTime().AddSeconds(-$o)).ToLocalTime()
#   Stop-Service w32time
#   Set-Service w32time -StartupType Disabled
# w32time stays disabled: its resync would revert the clock to the stale
# pre-suspend time. Set-Date above is the only sync; drift between wakes is small.
TIME_SYNC_B64="JABsACAAPQAgAHcAMwAyAHQAbQAgAC8AcwB0AHIAaQBwAGMAaABhAHIAdAAgAC8AYwBvAG0AcAB1AHQAZQByADoAMAAuAGEAdAAuAHAAbwBvAGwALgBuAHQAcAAuAG8AcgBnACAALwBzAGEAbQBwAGwAZQBzADoAMQAgAC8AZABhAHQAYQBvAG4AbAB5ACAAfAAgAFMAZQBsAGUAYwB0AC0ATwBiAGoAZQBjAHQAIAAtAEwAYQBzAHQAIAAxAAoAJABvACAAPQAgAFsAZABvAHUAYgBsAGUAXQA6ADoAUABhAHIAcwBlACgAKAAoACQAbAAgAC0AcwBwAGwAaQB0ACAAIgAsAFwAcwAqACIAKQBbADEAXQApAC4AVAByAGkAbQBFAG4AZAAoACIAcwAiACkALAAgAFsARwBsAG8AYgBhAGwAaQB6AGEAdABpAG8AbgAuAEMAdQBsAHQAdQByAGUASQBuAGYAbwBdADoAOgBJAG4AdgBhAHIAaQBhAG4AdABDAHUAbAB0AHUAcgBlACkACgBTAGUAdAAtAEQAYQB0AGUAIAAoACgARwBlAHQALQBEAGEAdABlACkALgBUAG8AVQBuAGkAdgBlAHIAcwBhAGwAVABpAG0AZQAoACkALgBBAGQAZABTAGUAYwBvAG4AZABzACgALQAkAG8AKQApAC4AVABvAEwAbwBjAGEAbABUAGkAbQBlACgAKQAKAFMAdABvAHAALQBTAGUAcgB2AGkAYwBlACAAdwAzADIAdABpAG0AZQAKAFMAZQB0AC0AUwBlAHIAdgBpAGMAZQAgAHcAMwAyAHQAaQBtAGUAIAAtAFMAdABhAHIAdAB1AHAAVAB5AHAAZQAgAEQAaQBzAGEAYgBsAGUAZAAKAA=="
ssh -o BatchMode=yes $PROXMOX "sudo /usr/sbin/qm guest exec $VM_ID --timeout 25 -- C:\\\\Windows\\\\System32\\\\WindowsPowerShell\\\\v1.0\\\\powershell.exe -NoProfile -NonInteractive -EncodedCommand $TIME_SYNC_B64" &>/dev/null

for i in {1..60}; do
    (echo > /dev/tcp/$VM_IP/3389) &>/dev/null && exit 0
    sleep 1
done
exit 1
