echo "Publish the sudoers default that lets \`sudo -v\` validate against the passwordless grant"

# The grant file is the only record of the passwordless sudo policy, and it
# now carries the sudoers default that makes `sudo -v` validate against the
# grant instead of every other entry in the policy. A grant published before
# that default existed is rewritten in place, keeping its rule and deadline.
helper="$OMARCHY_PATH/bin/omarchy-sudo-passwordless"
# Only an account holding a grant needs it rewritten, and that grant lets sudo
# run without a password; anyone else would be asked to authorize nothing.
if "$helper" --active; then
  sudo "$helper" __upgrade-grant-format
fi
