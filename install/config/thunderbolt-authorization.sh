echo "Configure Thunderbolt device authorization"

install -Dm644 "$OMARCHY_PATH/default/polkit/org.omarchy.thunderbolt.policy" /usr/share/polkit-1/actions/org.omarchy.thunderbolt.policy

# The builder's accessories must not become the new owner's trust policy.
# Keep ordinary Bolt behavior until interactive owner setup has finished.
if [[ -n ${OMARCHY_INSTALL_USER:-} ]]; then
  /usr/bin/omarchy-thunderbolt-authorization-admin prepare
  systemctl enable omarchy-thunderbolt-authorization.service
fi
