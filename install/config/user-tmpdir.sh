# setup to support private tmpdirs in ~
# ~/.local/tmp is created via /etc/skel in omarchy-settings
# * pam_env (ssh logins)
# * environment.d (systemd instantiated user env)
# * user-tmpfiles.d unit for cleanup

# ensure root has a local tmp

install -d -m 700 "/root/.local/tmp"

# Set user-tmpfiles cleanup for systemd

install -Dm644 /dev/stdin /usr/share/user-tmpfiles.d/omarchy-tmp.conf <<'EOF'
d %h/.local/tmp 0700 - - 10d
EOF

systemctl --global enable systemd-tmpfiles-setup.service systemd-tmpfiles-clean.timer

install -Dm644 \
  "$OMARCHY_PATH/default/environment.d/10-omarchy-tmpdir.conf" \
  /usr/lib/environment.d/10-omarchy-tmpdir.conf

# Same line install/config/user-tmpdir.sh writes on fresh installs; skip if
# TMPDIR is already managed there, by us or by the user.
grep -qE '^TMPDIR[[:space:]]' /etc/security/pam_env.conf && exit 0

tee -a /etc/security/pam_env.conf >/dev/null <<'EOF'

# Omarchy: use a private per-user tempdir where possible

TMPDIR DEFAULT=@{HOME}/.local/tmp
EOF
