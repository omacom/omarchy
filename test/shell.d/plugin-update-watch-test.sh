#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command git
require_command flock

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/bin" "$test_dir/home/.config/omarchy/plugins" "$test_dir/remote"
export CALL_LOG="$test_dir/calls"
export VALIDATE_STARTED="$test_dir/validate-started"
export VALIDATE_RELEASE="$test_dir/validate-release"
export OMARCHY_PLUGIN_UPDATE_LOCK="$test_dir/update.lock"
: >"$CALL_LOG"

cat >"$test_dir/bin/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$CALL_LOG"

if [[ $* == "shell ping" ]]; then
  exit ${SHELL_AVAILABLE:-0}
fi

if [[ $* == "shell setLocalPluginWatch false" && ${FAIL_SUSPEND:-0} == 1 ]]; then
  exit 1
fi

exit 0
SH

cat >"$test_dir/bin/omarchy-plugin-validate" <<'SH'
#!/bin/bash
if [[ ${BLOCK_VALIDATE:-0} == 1 && ! -e $VALIDATE_RELEASE ]]; then
  touch "$VALIDATE_STARTED"
  for _ in {1..500}; do
    [[ -e $VALIDATE_RELEASE ]] && break
    sleep 0.01
  done
fi
exit 0
SH

cat >"$test_dir/bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$test_dir/bin/"*

remote="$test_dir/remote/acme.watch.git"
git init -q --bare "$remote"

work="$test_dir/work"
mkdir -p "$work"
cat >"$work/manifest.json" <<'JSON'
{
  "schemaVersion": 1,
  "id": "acme.watch",
  "name": "Watch",
  "version": "1.0.0",
  "kinds": ["bar-widget"],
  "entryPoints": { "barWidget": "Widget.qml" },
  "barWidget": {
    "displayName": "Watch",
    "category": "Test",
    "allowMultiple": false
  }
}
JSON
printf 'import QtQuick\nItem {}\n' >"$work/Widget.qml"
git -C "$work" init -q
git -C "$work" add .
git -C "$work" -c user.name=Test -c user.email=test@example.com commit -qm "v1"
git -C "$work" branch -M main
git -C "$work" remote add origin "$remote"
git -C "$work" push -q origin main
git -C "$remote" symbolic-ref HEAD refs/heads/main

installed="$test_dir/home/.config/omarchy/plugins/acme.watch"
git clone -q -b main "$remote" "$installed"

advance_remote() {
  local n="$1"
  printf 'import QtQuick\nItem { readonly property int n: %s }\n' "$n" >"$work/Widget.qml"
  git -C "$work" add Widget.qml
  git -C "$work" -c user.name=Test -c user.email=test@example.com commit -qm "v$n"
  git -C "$work" push -q origin main
}

run_update() {
  HOME="$test_dir/home" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$ROOT/bin:$PATH" \
    XDG_RUNTIME_DIR="$test_dir" OMARCHY_PLUGIN_UPDATE_LOCK="$OMARCHY_PLUGIN_UPDATE_LOCK" \
    "$ROOT/bin/omarchy-plugin-update" acme.watch --yes
}

advance_remote 2
run_update >"$test_dir/out" 2>&1

mapfile -t calls <"$CALL_LOG"
[[ ${calls[0]} == "shell ping" ]] ||
  fail "update probes whether a live watcher exists before suspension" "$(cat "$CALL_LOG")"
[[ ${calls[1]} == "shell setLocalPluginWatch false" ]] ||
  fail "update suspends the local plugin watcher before mutation" "$(cat "$CALL_LOG")"
[[ ${calls[-2]} == "shell rescanPlugins" ]] ||
  fail "update rescans once after successful mutation" "$(cat "$CALL_LOG")"
[[ ${calls[-1]} == "shell setLocalPluginWatch true" ]] ||
  fail "update resumes the local plugin watcher after rescan" "$(cat "$CALL_LOG")"
grep -qF "Updated acme.watch." "$test_dir/out" ||
  fail "update reports success" "$(cat "$test_dir/out")"
pass "plugin update suspends, mutates, rescans, and resumes in order"

# A reachable shell that cannot suspend the watcher must fail before HEAD moves.
advance_remote 3
before=$(git -C "$installed" rev-parse HEAD)
: >"$CALL_LOG"
if FAIL_SUSPEND=1 run_update >"$test_dir/fail-out" 2>&1; then
  fail "update proceeds when a live shell rejects watcher suspension"
fi
after=$(git -C "$installed" rev-parse HEAD)
[[ $before == "$after" ]] ||
  fail "failed watcher suspension allowed the plugin checkout to mutate"
grep -qF "shell setLocalPluginWatch false" "$CALL_LOG" ||
  fail "fail-closed path did not attempt watcher suspension"
! grep -qF "shell rescanPlugins" "$CALL_LOG" ||
  fail "failed watcher suspension should not request a rescan"
pass "live-shell watcher suspension fails closed before mutation"

# Two update processes share one mutation/session lock. The second must not
# suspend or mutate while the first is blocked inside validation.
: >"$CALL_LOG"
rm -f "$VALIDATE_STARTED" "$VALIDATE_RELEASE"
BLOCK_VALIDATE=1 run_update >"$test_dir/first-out" 2>&1 &
first_pid=$!

for _ in {1..300}; do
  [[ -e $VALIDATE_STARTED ]] && break
  sleep 0.01
done
[[ -e $VALIDATE_STARTED ]] || {
  kill "$first_pid" 2>/dev/null || true
  fail "first updater did not reach the blocked mutation phase"
}

BLOCK_VALIDATE=0 run_update >"$test_dir/second-out" 2>&1 &
second_pid=$!
sleep 0.2

suspends=$(grep -cF "shell setLocalPluginWatch false" "$CALL_LOG" || true)
(( suspends == 1 )) ||
  fail "overlapping updater acquired watcher ownership before the first finished" "$(cat "$CALL_LOG")"

touch "$VALIDATE_RELEASE"
wait "$first_pid"
wait "$second_pid"

suspends=$(grep -cF "shell setLocalPluginWatch false" "$CALL_LOG" || true)
resumes=$(grep -cF "shell setLocalPluginWatch true" "$CALL_LOG" || true)
(( suspends == 1 && resumes == 1 )) ||
  fail "serialized updaters should produce one suspend/resume mutation cycle" "$(cat "$CALL_LOG")"
grep -qF "acme.watch is up to date." "$test_dir/second-out" ||
  fail "second updater did not observe the first updater's completed state" "$(cat "$test_dir/second-out")"
pass "overlapping plugin updates serialize before watcher ownership and mutation"
