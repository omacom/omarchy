# Keep native encrypted login-keyring integration. This also repairs only the
# known stock entries removed by older Omarchy installs, leaving custom PAM
# stacks for their administrator. Disk-encryption autologin remains unchanged.
/usr/bin/python3 "$OMARCHY_PATH/default/omarchy/keyring-pam.py"
