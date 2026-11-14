#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
mkdir -p "$TMPDIR/bin"
home="$TMPDIR/home"
calls="$TMPDIR/calls"
for id in alpha.one beta.two; do
  mkdir -p "$home/.config/omarchy/plugins/$id/.git"
done

# git reports every plugin up to date and records which one it was asked about.
cat >"$TMPDIR/bin/git" <<'SH'
#!/bin/bash
[[ $1 == "-C" ]] && printf '%s %s\n' "${2##*/}" "$3" >>"$OMARCHY_TEST_CALLS"
[[ $3 == "rev-parse" ]] && echo same
exit 0
SH
chmod +x "$TMPDIR/bin/git"

run() {
  HOME="$home" OMARCHY_PATH="$ROOT" OMARCHY_TEST_CALLS="$calls" \
    PATH="$TMPDIR/bin:$ROOT/bin:$PATH" "$@"
}

run omarchy-plugin-hold beta.two >/dev/null
[[ -f $home/.local/state/omarchy/plugins/held/beta.two ]] || fail "hold did not record the plugin"
pass "plugin hold records the plugin"

: >"$calls"
out=$(run omarchy-plugin-update --yes)
grep -q '^alpha.one fetch' "$calls" || fail "update skipped a plugin that is not held"
! grep -q '^beta.two' "$calls" || fail "update touched a held plugin"
grep -Fq 'beta.two is held back' <<<"$out" || fail "update did not say the plugin is held"
pass "plugin update skips a held plugin and says so"

: >"$calls"
run omarchy-plugin-update beta.two --yes >/dev/null
grep -q '^beta.two fetch' "$calls" || fail "update by name did not update a held plugin"
pass "plugin update by name still updates a held plugin"

run omarchy-plugin-unhold beta.two >/dev/null
: >"$calls"
run omarchy-plugin-update --yes >/dev/null
grep -q '^beta.two fetch' "$calls" || fail "unhold did not let the plugin update again"
pass "plugin unhold lets it update again"

if run omarchy-plugin-hold '../evil' >/dev/null 2>&1; then
  fail "hold accepted a path as a plugin id"
fi
pass "plugin hold rejects ids that are not plugin ids"
