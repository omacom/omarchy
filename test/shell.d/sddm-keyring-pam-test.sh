#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

sddm_install="$ROOT/install/login/sddm.sh"
migration="$ROOT/migrations/1790544001.sh"

rg -q 'OMARCHY_SDDM_AUTOLOGIN_PAM' "$sddm_install" ||
  fail "SDDM install script can target a test autologin PAM path"
rg -q "sed -i '/pam_gnome_keyring\\\\.so/d'" "$sddm_install" ||
  fail "SDDM install script strips gnome-keyring from autologin PAM"
pass "SDDM install script strips gnome-keyring from autologin PAM"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

cat >"$tmp_dir/sddm" <<'EOF'
#%PAM-1.0
auth        include     system-login
-auth       optional    pam_gnome_keyring.so
-password   optional    pam_gnome_keyring.so use_authtok
session     include     system-login
EOF

cat >"$tmp_dir/sddm-autologin" <<'EOF'
#%PAM-1.0
auth        required    pam_permit.so
auth        required    pam_faillock.so authsucc
auth        required    pam_shells.so
auth        required    pam_nologin.so
auth        required    pam_env.so
session     required    pam_loginuid.so
session     optional    pam_keyinit.so force revoke
session     required    pam_limits.so
session     required    pam_unix.so
-session    optional    pam_gnome_keyring.so auto_start
session     optional    pam_umask.so
session     optional    pam_systemd.so
EOF

OMARCHY_SDDM_PAM="$tmp_dir/sddm" OMARCHY_SDDM_AUTOLOGIN_PAM="$tmp_dir/sddm-autologin" \
  bash -c 'source '"$sddm_install"

grep -q 'pam_gnome_keyring\.so' "$tmp_dir/sddm" &&
  fail "password SDDM PAM still references gnome-keyring auth/password" "$(cat "$tmp_dir/sddm")"
grep -q 'pam_gnome_keyring\.so' "$tmp_dir/sddm-autologin" &&
  fail "autologin PAM still starts gnome-keyring" "$(cat "$tmp_dir/sddm-autologin")"
pass "sourced SDDM install script clears gnome-keyring from both PAM files"

# Migration must clear an existing autologin line without touching other session modules.
cat >"$tmp_dir/sddm-autologin" <<'EOF'
session     required    pam_unix.so
-session    optional    pam_gnome_keyring.so auto_start
session     optional    pam_systemd.so
EOF

OMARCHY_SDDM_AUTOLOGIN_PAM="$tmp_dir/sddm-autologin" bash "$migration"

grep -q 'pam_gnome_keyring\.so' "$tmp_dir/sddm-autologin" &&
  fail "migration left gnome-keyring on autologin PAM" "$(cat "$tmp_dir/sddm-autologin")"
grep -qx 'session     required    pam_unix.so' "$tmp_dir/sddm-autologin" ||
  fail "migration preserved unrelated PAM lines"
grep -qx 'session     optional    pam_systemd.so' "$tmp_dir/sddm-autologin" ||
  fail "migration preserved systemd PAM line"
pass "autologin keyring migration drops only gnome-keyring"
