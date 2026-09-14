#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1787691200.sh"
prefs_path="/usr/lib/chromium/initial_preferences"

# The seed is pinned here the way the migration pins it: the whole point of
# the migration is that already-installed machines converge on this content.
seed='{"distribution":{"require_eula":false},"browser":{"theme":{"color_scheme":0,"color_scheme2":0}}}'

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
call_log="$test_tmp/calls.log"
fake_home="$test_tmp/home"
mkdir -p "$stub_bin" "$fake_home"
: >"$call_log"

cat >"$stub_bin/cat" <<'SH'
#!/bin/bash
printf '%s' "${CHROMIUM_PREFS_CONTENT:-}"
SH

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
printf 'sudo %s\n' "$*" >>"$CALL_LOG"
if [[ $1 == "tee" ]]; then
  # command -p bypasses the cat stub above: this must read sudo's stdin.
  command -p cat >>"$CALL_LOG"
fi
SH

# Guard rails, not behavior: tee and mkdir are only reachable through the sudo
# stub above, which never execs. If a regression ever calls them directly,
# fail loudly instead of touching the real filesystem.
for guard in tee mkdir; do
  cat >"$stub_bin/$guard" <<'SH'
#!/bin/bash
echo "unexpected direct call to ${0##*/}: $*" >&2
exit 99
SH
done
chmod +x "$stub_bin/cat" "$stub_bin/sudo" "$stub_bin/tee" "$stub_bin/mkdir"

run_migration() {
  : >"$call_log"
  PATH="$stub_bin:$PATH" \
    CALL_LOG="$call_log" \
    CHROMIUM_PREFS_CONTENT="${1:-}" \
    HOME="$fake_home" \
    OMARCHY_PATH="$ROOT" \
    bash -euo pipefail "$migration" >/dev/null
}

# A machine that never had the seed gets it written next to the binary.
run_migration "" || fail "the migration seeds Chromium preferences on a machine without them"
grep -qxF "sudo mkdir -p /usr/lib/chromium" "$call_log" ||
  fail "the migration creates the Chromium preferences directory"
grep -qxF "sudo tee $prefs_path" "$call_log" ||
  fail "the migration writes the Chromium seed preferences"
grep -qxF "$seed" "$call_log" ||
  fail "the migration answers the first-run EULA in the seed"
pass "the migration seeds Chromium preferences on a machine without them"

# Once the seed is in place, the migration leaves the machine alone.
run_migration "$seed" || fail "the migration fails on a machine that already has the seed"
[[ ! -s $call_log ]] || fail "the migration touches a machine that already has the seed"
pass "the migration no-ops on a machine that already has the seed"

# A stale seed is still a seed-shaped file, not the seed: rewrite it.
run_migration '{"distribution":{}}' || fail "the migration fails on a machine with a stale seed"
grep -qxF "sudo tee $prefs_path" "$call_log" ||
  fail "the migration rewrites a stale seed"
pass "the migration rewrites a stale seed"
