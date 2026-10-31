#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'chmod -R u+w "$test_tmp" 2>/dev/null || true; rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/home"
export FAKE_CALLS="$test_tmp/calls" FAKE_NOTIFICATIONS="$test_tmp/notifications"
for layout in hyprmoncfg/src/go-mod standard/src/pkg/mod nested/src/gopath/pkg/mod; do
  mkdir -p "$test_tmp/cache/yay/$layout/module"
  touch "$test_tmp/cache/yay/$layout/module/LICENSE"
  chmod -R a-w "$test_tmp/cache/yay/$layout"
done
cat >"$test_tmp/bin/pacman" <<'SH'
#!/bin/bash
[[ $1 == "-Qem" ]] || exit 90
exit "${TEST_NO_AUR:-0}"
SH
cat >"$test_tmp/bin/omarchy-pkg-aur-accessible" <<'SH'
#!/bin/bash
exit "${TEST_AUR_UNAVAILABLE:-0}"
SH
cat >"$test_tmp/bin/yay" <<'SH'
#!/bin/bash
printf '%s\n%s\n' "$GOFLAGS" "$*" >>"$FAKE_CALLS"
exit "${TEST_YAY_STATUS:-1}"
SH
cat >"$test_tmp/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$FAKE_NOTIFICATIONS"
exit "${TEST_NOTIFICATION_STATUS:-0}"
SH
chmod +x "$test_tmp/bin/"*
run() {
  : >"$FAKE_CALLS"
  : >"$FAKE_NOTIFICATIONS"
  HOME="$test_tmp/home" XDG_CACHE_HOME="$test_tmp/cache" PATH="$test_tmp/bin:$PATH" OMARCHY_PATH="$ROOT" \
    bash "$ROOT/bin/omarchy-update-aur-pkgs" >"$test_tmp/out" 2>"$test_tmp/err"
}
GOFLAGS='-trimpath -tags=custom' run || fail "failed AUR build stays nonfatal"
[[ $(head -1 "$FAKE_CALLS") == '-trimpath -tags=custom -modcacherw' ]] || fail "yay receives existing Go flags plus writable-cache flag"
for layout in hyprmoncfg/src/go-mod standard/src/pkg/mod nested/src/gopath/pkg/mod; do
  for path in "$test_tmp/cache/yay/$layout" "$test_tmp/cache/yay/$layout/module/LICENSE"; do
    mode=$(stat -c %a "$path")
    (( (8#$mode & 0200) != 0 )) || fail "Go cache remains read-only: $layout"
  done
done
pass "all supported Go cache layouts become writable and GOFLAGS are preserved"
grep -q 'AUR package update failed' "$test_tmp/err" || fail "AUR failure prints a terminal warning"
grep -q 'AUR update needs attention' "$FAKE_NOTIFICATIONS" || fail "AUR failure sends a desktop notification"
pass "failed AUR update remains visible without aborting"
TEST_NOTIFICATION_STATUS=1 run || fail "notification failure must not abort the update"
pass "failed desktop notification leaves the terminal warning and remains nonfatal"
GOFLAGS='' TEST_YAY_STATUS=0 run || fail "successful AUR update succeeds"
[[ $(head -1 "$FAKE_CALLS") == '-modcacherw' && ! -s $FAKE_NOTIFICATIONS && ! -s $test_tmp/err ]] || fail "successful update adds flag without warning"
pass "successful AUR update emits no failure notification"
TEST_NO_AUR=1 run
[[ ! -s $FAKE_CALLS && ! -s $FAKE_NOTIFICATIONS ]] || fail "no foreign packages skips yay"
TEST_AUR_UNAVAILABLE=1 run
[[ ! -s $FAKE_CALLS && ! -s $FAKE_NOTIFICATIONS ]] || fail "unavailable AUR skips yay"
pass "missing packages and unavailable AUR do not report a build failure"
