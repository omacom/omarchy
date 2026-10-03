#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

script="$ROOT/install/login/sddm.sh"
shipped_migration="$ROOT/migrations/1788600002.sh"

grep -q 'sddm-autologin' "$script" ||
  fail "SDDM keyring strip covers the autologin PAM stack"
grep -q "/etc/pam.d/sddm-autologin" "$script" ||
  fail "SDDM keyring strip names the autologin PAM file"
[[ -f $shipped_migration ]] || fail "existing installs get an autologin keyring migration"
[[ $(head -n 1 "$shipped_migration") == echo* ]] ||
  fail "autologin keyring migration starts with an echo"
! grep -q '^#!' "$shipped_migration" || fail "autologin keyring migration has no shebang"
grep -Fxq 'pam=/etc/pam.d/sddm-autologin' "$shipped_migration" ||
  fail "the production autologin PAM path is a fixed literal"
if grep -q 'OMARCHY_.*PAM' "$shipped_migration"; then
  fail "the migration does not accept caller-controlled privileged paths"
fi
pass "SDDM keyring strip covers password and autologin stacks"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/bin"
pam="$test_dir/sddm-autologin"
calls="$test_dir/calls"

cat >"$test_dir/bin/sudo" <<'STUB'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"${CALLS:?}"
exec "$@"
STUB
chmod +x "$test_dir/bin/sudo"

sed "s|^pam=/etc/pam.d/sddm-autologin$|pam=$pam|" "$shipped_migration" >"$test_dir/migration.sh"

cat >"$test_dir/pam-fixture" <<'PAM'
#%PAM-1.0
auth        required    pam_permit.so
-auth       optional    pam_gnome_keyring.so
account     include     system-local-login
password    include     system-local-login
-password   optional    pam_gnome_keyring.so use_authtok
-session    optional    pam_gnome_keyring.so auto_start
session     include     system-local-login
PAM
cp "$test_dir/pam-fixture" "$pam"

: >"$calls"
CALLS="$calls" PATH="$test_dir/bin:$PATH" bash -euo pipefail "$test_dir/migration.sh" >/dev/null

grep -q 'pam_permit.so' "$pam" || fail "keyring strip keeps required autologin auth"
grep -q 'pam_gnome_keyring.so auto_start' "$pam" ||
  fail "keyring strip keeps session keyring auto_start"
if grep -qE -- '-auth.*pam_gnome_keyring\.so|-password.*pam_gnome_keyring\.so' "$pam"; then
  fail "keyring strip removes autologin auth and password gnome-keyring modules"
fi
# Root runs the migration's direct sed path, so the sudo stub stays silent.
if (( EUID != 0 )); then
  grep -q '^sudo sed' "$calls" || fail "non-root migration elevates with sudo"
else
  [[ ! -s $calls ]] || fail "root migration edits the autologin stack without sudo" "$(<"$calls")"
fi
pass "keyring strip removes autologin auth and password gnome-keyring modules"

: >"$calls"
CALLS="$calls" PATH="$test_dir/bin:$PATH" bash -euo pipefail "$test_dir/migration.sh" >/dev/null
[[ ! -s $calls ]] || fail "an already-stripped autologin stack is a no-op" "$(<"$calls")"
pass "an already-stripped autologin stack is a no-op"

# install/login/sddm.sh hardcodes /etc/pam.d. Point a copy at the fixture
# instead of editing the host PAM stacks or the installer.
install_pam_dir="$test_dir/etc/pam.d"
mkdir -p "$install_pam_dir"
cp "$test_dir/pam-fixture" "$install_pam_dir/sddm"
cp "$test_dir/pam-fixture" "$install_pam_dir/sddm-autologin"
sed "s|/etc/pam.d|$install_pam_dir|g" "$script" >"$test_dir/install-sddm.sh"
bash -euo pipefail "$test_dir/install-sddm.sh"

for stack in sddm sddm-autologin; do
  target="$install_pam_dir/$stack"
  grep -q 'pam_permit.so' "$target" || fail "fresh install keeps required auth in $stack"
  grep -q 'pam_gnome_keyring.so auto_start' "$target" ||
    fail "fresh install keeps session keyring auto_start in $stack"
  if grep -qE -- '-auth.*pam_gnome_keyring\.so|-password.*pam_gnome_keyring\.so' "$target"; then
    fail "fresh install removes auth and password gnome-keyring modules from $stack"
  fi
done
pass "fresh install strips password and autologin keyring auth"
