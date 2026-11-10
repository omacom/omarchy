echo "Restore encrypted application keyrings and SDDM password integration"

# Keep unattended launcher repairs before this interactive step: cancelling
# enrollment must not prevent their security fixes from reaching the user.
# Escalate only the installed helper, never a user-writable development checkout.
sudo /usr/bin/python3 /usr/share/omarchy/default/omarchy/keyring-pam.py

# Refusal, an absent graphical session, or an unsupported daemon leaves this
# migration pending. The next graphical login offers the normal migration notice.
omarchy-setup-security-keyring --migrate
