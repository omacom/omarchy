echo "Repair a corrupt passwordless default keyring before session apps use it"

# Existing installs can already be stuck on a password-protected Default_Keyring
# that autologin cannot unlock, or on a cleartext file poisoned by a multi-line
# secret. Enable the early session repair and run it once now.
omarchy-keyring-repair || true

omarchy-keyring-repair --enable
