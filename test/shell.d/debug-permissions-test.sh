#!/bin/bash

# A root-run `omarchy update` leaves the home owned by root, and the report that
# finds it is the only thing that tells the user why their files stopped being
# writable. This holds it to its two answers -- 0 for a home the invoking user
# owns, 1 naming a home it does not -- and to repairing the home in one chown.

set -euo pipefail

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

home="$tmpdir/home"
runtime="$tmpdir/runtime"
stub_bin="$tmpdir/bin"

mkdir -p "$home/.config/hypr" "$runtime" "$stub_bin"
touch "$home/.config/hypr/hyprland.conf"

# XDG_RUNTIME_DIR and OMARCHY_UPDATE_LOG name the two files a root-run update
# leaves outside the home, so both point into the scratch directory: a real
# leftover on this machine must not decide what the report says.
report() {
  HOME="$home" XDG_RUNTIME_DIR="$runtime" OMARCHY_UPDATE_LOG="$tmpdir/absent.log" \
    "$ROOT/bin/omarchy-debug-permissions" "$@"
}

run() {
  local status=0

  report "$@" >"$tmpdir/out" 2>&1 || status=$?
  printf '%s' "$status"
}

[[ $(run) == 0 ]] || fail "a home owned by the invoking user reports clean" "$(cat "$tmpdir/out")"
grep -Fq 'No entry in' "$tmpdir/out" || fail "a clean report says the home is clean" "$(cat "$tmpdir/out")"
grep -Fq 'No root-owned update leftovers.' "$tmpdir/out" ||
  fail "a clean report covers the files a root-run update leaves outside the home" "$(cat "$tmpdir/out")"
pass "a home owned by the invoking user reports clean"

# Nothing to fix must not ask for a password: a sudo that is reached fails here.
cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$SUDO_CALLS"
STUB
chmod +x "$stub_bin/sudo"

SUDO_CALLS="$tmpdir/sudo-calls" PATH="$stub_bin:$PATH" report --fix >"$tmpdir/out" 2>&1 ||
  fail "--fix on a clean home exits 0" "$(cat "$tmpdir/out")"
grep -Fq 'Nothing to fix' "$tmpdir/out" || fail "--fix on a clean home says there is nothing to fix" "$(cat "$tmpdir/out")"
[[ ! -e $tmpdir/sudo-calls ]] || fail "--fix on a clean home runs no privileged command" "$(cat "$tmpdir/sudo-calls")"
pass "--fix on a clean home exits 0 without privileged work"

# `omarchy debug permissions` reaches the same command through the router, which
# is the route the metadata exists for.
if HOME="$home" XDG_RUNTIME_DIR="$runtime" OMARCHY_UPDATE_LOG="$tmpdir/absent.log" \
  "$ROOT/bin/omarchy" debug permissions >"$tmpdir/out" 2>&1; then
  pass "omarchy debug permissions routes to the report"
else
  fail "omarchy debug permissions routes to the report" "$(cat "$tmpdir/out")"
fi

# An entry the invoking user does not own. Unprivileged chown to another uid
# needs CAP_CHOWN, so this is real only where the test can get one; the report is
# otherwise shown an `id` naming another uid, which is the same question the
# check asks of every file.
foreign="$home/.config/hypr/root-owned.conf"
touch "$foreign"

if chown 4242:4242 "$foreign" 2>/dev/null && [[ $(stat -c '%u' "$foreign") == 4242 ]]; then
  status=$(run)
  [[ $status == 1 ]] || fail "an entry owned by another user exits 1" "exit $status: $(cat "$tmpdir/out")"
  grep -Fq "$foreign" "$tmpdir/out" || fail "the report names the entry owned by another user" "$(cat "$tmpdir/out")"
  pass "an entry owned by another user exits 1 and is named"

  cat >"$stub_bin/sudo" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$SUDO_CALLS"
exec "$@"
STUB
  chmod +x "$stub_bin/sudo"

  SUDO_CALLS="$tmpdir/sudo-calls" PATH="$stub_bin:$PATH" report --fix >"$tmpdir/out" 2>&1 ||
    fail "--fix repairs a home owned by another user" "$(cat "$tmpdir/out")"
  [[ $(stat -c '%u' "$foreign") == "$(id -u)" ]] || fail "--fix hands the entry back to the invoking user"
  (( $(grep -c '^chown' "$tmpdir/sudo-calls") == 1 )) ||
    fail "--fix takes ownership in one chown" "$(cat "$tmpdir/sudo-calls")"
  pass "--fix takes ownership of every entry in one chown"

  # A sudo that cannot prompt must not claim success.
  chown 4242:4242 "$foreign" 2>/dev/null
  printf '#!/bin/bash\nexit 1\n' >"$stub_bin/sudo"
  chmod +x "$stub_bin/sudo"
  status=$(run --fix)
  [[ $status == 1 ]] || fail "--fix exits 1 when the chown fails" "exit $status: $(cat "$tmpdir/out")"
  grep -Fq 'Could not take ownership' "$tmpdir/out" ||
    fail "--fix says it could not take ownership when the chown fails" "$(cat "$tmpdir/out")"
  pass "--fix exits 1 and says so when the chown fails"
else
  skip "an entry owned by another user exits 1 and is named: chown to another uid needs root"
fi

cat >"$stub_bin/id" <<'STUB'
#!/bin/bash
case "${1:-}" in
  -u) printf '%s\n' 4242 ;;
  *) exec /usr/bin/id "$@" ;;
esac
STUB
chmod +x "$stub_bin/id"

status=$(PATH="$stub_bin:$PATH" run)
[[ $status == 1 ]] || fail "entries the invoking user does not own exit 1" "exit $status: $(cat "$tmpdir/out")"
grep -Fq "$home/.config/hypr/hyprland.conf" "$tmpdir/out" ||
  fail "the report names every entry the invoking user does not own" "$(cat "$tmpdir/out")"
pass "entries the invoking user does not own exit 1 and are named"
