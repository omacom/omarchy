
echo "Set up private per-user temporary directories"
install -d -m 700 "$HOME/.local/tmp"


machine_marker="/var/lib/omarchy/migrations/1789168169"
[[ ! -e $machine_marker ]] || exit 0

echo "Set user TMPDIR via the PAM environment"

# Complementary with environment.d/10-omarchy-tmpdir.conf this sets TMPDIR
# in PAM controlled contexts such as ssh


# root also gets a local tmp.

sudo install -d -m 700 "/root/.local/tmp"

# Set user-tmpfiles cleanup for syste

sudo install -Dm644 /dev/stdin /usr/share/user-tmpfiles.d/omarchy-tmp.conf <<'EOF'
d %h/.local/tmp 0700 - - 10d
EOF

sudo systemctl --global enable systemd-tmpfiles-setup.service systemd-tmpfiles-clean.timer

sudo install -Dm644 /dev/stdin /usr/lib/environment.d/10-omarchy-tmpdir.conf <<'EOF'
TMPDIR=${HOME}/.local/tmp
EOF

if ! grep -qE '^TMPDIR[[:space:]]' /etc/security/pam_env.conf; then
  sudo tee -a /etc/security/pam_env.conf >/dev/null <<'EOF'

# Omarchy: use a private per-user tempdir where possible

TMPDIR DEFAULT=@{HOME}/.local/tmp
EOF

fi

sudo install -Dm644 /dev/null "$machine_marker"
