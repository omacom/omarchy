#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration=$(grep -l 'Stop fprintd before sleep instead of restarting it after resume' "$ROOT"/migrations/*.sh || true)
[[ -n $migration && $(wc -l <<<"$migration") -eq 1 ]] ||
  fail "one migration replaces the shipped fprintd hook" "found: ${migration:-none}"

shipped="$ROOT/default/systemd/system-sleep/fprintd-resume"
legacy_sha256=$(sed -n 's/^legacy_sha256=//p' "$migration")
[[ $legacy_sha256 =~ ^[0-9a-f]{64}$ ]] ||
  fail "the migration names the previous shipped hook by its sha256" "sha: ${legacy_sha256:-missing}"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

stub_bin="$tmpdir/bin"
sudo_log="$tmpdir/sudo"
mkdir -p "$stub_bin"
cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$SUDO_LOG"
exec "$@"
STUB
chmod +x "$stub_bin/sudo"

dst="$tmpdir/system-sleep/fprintd-resume"
mkdir -p "$(dirname "$dst")"

run_migration() {
  : >"$sudo_log"
  env -u OMARCHY_FPRINTD_RESUME_SRC \
    PATH="$stub_bin:$PATH" \
    SUDO_LOG="$sudo_log" \
    OMARCHY_PATH="$ROOT" \
    OMARCHY_FPRINTD_RESUME_DST="$dst" \
    bash -euo pipefail "$migration" >"$tmpdir/out" ||
    fail "migration exits clean" "$(cat "$tmpdir/out")"
}

# The previous shipped hook is the only text this migration replaces, and the
# replacement is the file in default/, not a copy kept beside the test.
cat >"$dst" <<'EOF'
#!/bin/bash

# Suspend can wedge fprintd's claim; restart it after resume to clear it.
# Upstream: https://gitlab.freedesktop.org/libfprint/fprintd/-/issues/173

if [[ $1 == "post" ]]; then
  # user.slice stays frozen until this hook returns; enqueue rather than wait.
  systemctl --no-block try-restart fprintd.service 2>/dev/null || true
fi
EOF
actual=$(sha256sum -- "$dst")
[[ ${actual%% *} == "$legacy_sha256" ]] ||
  fail "the fixture is the previous shipped hook" "sha: ${actual%% *}"
run_migration
cmp -s "$dst" "$shipped" ||
  fail "migration installs the hook from default/"
[[ $(stat -c '%a' "$dst") == 755 ]] ||
  fail "migration installs the hook executable" "mode: $(stat -c '%A' "$dst")"
grep -q 'install -Dm755' "$sudo_log" ||
  fail "migration installs through sudo" "sudo: $(<"$sudo_log")"
pass "migration replaces the previous shipped hook with the file in default/"

# A second run finds the shipped hook and does not install again.
run_migration
cmp -s "$dst" "$shipped" ||
  fail "migration leaves the shipped hook in place"
[[ ! -s $sudo_log ]] ||
  fail "migration does not reinstall the shipped hook" "sudo: $(<"$sudo_log")"
pass "migration leaves the shipped hook alone"

# An administrator's edit is not the previous shipped text.
printf '\n# local\n' >>"$dst"
cp -a "$dst" "$tmpdir/admin-hook"
run_migration
cmp -s "$dst" "$tmpdir/admin-hook" ||
  fail "migration leaves an administrator's hook alone"
[[ ! -s $sudo_log ]] ||
  fail "migration does not install over an administrator's hook" "sudo: $(<"$sudo_log")"
pass "migration leaves an administrator's hook alone"

rm -f "$dst"
ln -s "$tmpdir/admin-hook" "$dst"
run_migration
[[ -L $dst ]] || fail "migration leaves a symlink hook alone"
[[ ! -s $sudo_log ]] ||
  fail "migration does not replace a symlink hook" "sudo: $(<"$sudo_log")"
pass "migration leaves a symlink hook alone"

rm -f "$dst"
run_migration
[[ ! -e $dst ]] || fail "migration does nothing when no hook is installed"
[[ ! -s $sudo_log ]] ||
  fail "migration does not install when no hook is present" "sudo: $(<"$sudo_log")"
pass "migration does nothing when no hook is installed"
