#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/bin"
export PACMAN_CONFIG="$test_dir/pacman.conf" CALL_LOG="$test_dir/calls"
sed "s|/etc/pacman.conf|$PACMAN_CONFIG|g" "$ROOT/migrations/1791403252.sh" >"$test_dir/migration.sh"

cat >"$test_dir/bin/sudo" <<'SH'
#!/bin/bash
[[ ${CONFIG_STATUS:-0} == 0 ]] || exit "$CONFIG_STATUS"
if [[ $1 == "install" ]]; then
  install -m 644 "${@: -2}"
else
  "$@"
fi
SH
cat >"$test_dir/bin/omarchy-update-system-pkgs" <<'SH'
#!/bin/bash
# Snapshot exactly the configuration visible to the package updater.
cat "$PACMAN_CONFIG" >"$CALL_LOG"
exit "${UPDATE_STATUS:-0}"
SH
chmod +x "$test_dir/bin/"*

run() {
  rm -f "$CALL_LOG"
  env PATH="$test_dir/bin:$PATH" "$@" bash -euo pipefail "$test_dir/migration.sh" >"$test_dir/output" 2>&1
}

for channel in stable rc edge; do
  cat >"$PACMAN_CONFIG" <<CONF
[options]
Architecture = auto
IgnorePkg = custom-package
[custom]
Server = https://custom.example/\$arch
[core]
Include = /etc/pacman.d/mirrorlist
[omarchy]
Server = https://pkgs.omarchy.org/$channel/\$arch
SigLevel = Required
[extra]
Include = /etc/pacman.d/mirrorlist
CONF
  cp "$PACMAN_CONFIG" "$test_dir/original"
  run || fail "$channel migration succeeds"
  [[ $(awk '/^\[/ && $0 != "[options]" { print; exit }' "$CALL_LOG") == "[omarchy]" ]] || fail "packages update after OPR is prioritized"
  cmp -s "$PACMAN_CONFIG.bak" "$test_dir/original" || fail "original configuration is backed up"
  for setting in 'IgnorePkg = custom-package' '[custom]' 'Server = https://custom.example/$arch' 'SigLevel = Required' "Server = https://pkgs.omarchy.org/$channel/\$arch"; do
    grep -qxF "$setting" "$CALL_LOG" || fail "repository settings survive"
  done
  cp "$PACMAN_CONFIG" "$test_dir/ordered"
  run || fail "already ordered configuration still upgrades"
  cmp -s "$PACMAN_CONFIG" "$test_dir/ordered" || fail "repeated ordering is idempotent"
  cmp -s "$PACMAN_CONFIG.bak" "$test_dir/original" || fail "repeat preserves original backup"
  pass "$channel updates packages after ordering and preserves configuration on repeat"
done

if run UPDATE_STATUS=42; then
  fail "failed package update leaves the migration pending"
fi
[[ -f $CALL_LOG ]] || fail "failed update was attempted"
run || fail "failed package update can be retried after ordering"
pass "package update failure propagates and retry updates already ordered repositories"

# A failed configuration write must never proceed to the package update.
cp "$test_dir/original" "$PACMAN_CONFIG"
if run CONFIG_STATUS=1; then
  fail "failed configuration write stops the migration"
fi
[[ ! -e $CALL_LOG ]] || fail "packages are not updated after a failed configuration write"
pass "configuration failure prevents the package update"
