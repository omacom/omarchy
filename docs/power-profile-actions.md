# Optional power profile actions

Run `omarchy pkg add python-gobject iw` then `omarchy setup profile-actions` to opt in. The system service subscribes to power-profiles-daemon ActiveProfile, daemon ownership changes and NetworkManager device state. It never selects profiles or changes saved connections. The existing Omarchy setter remains authoritative for AC/battery preferences.

Only brcmfmac is qualified: power-saver enables live Wi-Fi power saving, balanced/performance disable it without reconnecting. Intel policy remains unchanged. New drivers require separate qualification. Root-owned, executable regular files under `/etc/omarchy/powerprofiles/actions.d` receive the validated profile; group/world writable files and symlinks are excluded. The directory itself must remain root-owned and not writable by others.

Disable with `sudo systemctl disable --now omarchy-profile-actions.service`, then set the previous Wi-Fi policy with `sudo iw dev INTERFACE set power_save off` when appropriate. Remove only this feature's installed files and reload systemd. This does not provide GPU/CPU policy where the platform PPD driver is a placeholder. Physical source transitions and long radio soak remain hardware acceptance gates.

Provenance: extracted from the owner-authorized November 2 Omarchy proposal 036780397. This branch intentionally excludes its low-charge thresholds, panel and battery plugin changes, and personal `/usr/local` setter. No Apple private implementation or firmware source was used.
