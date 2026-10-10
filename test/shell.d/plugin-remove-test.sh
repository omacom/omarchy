#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command jq

test_dir=$(mktemp -d)
trap 'rm -rf -- "$test_dir"' EXIT
stub_dir="$test_dir/stubs"
mkdir -p "$stub_dir"
cat >"$stub_dir/omarchy-shell" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$HOME/events"
case "$2" in
listPlugins) printf '[{"id":"acme.test","enabled":true}]\n' ;;
setPluginEnabled) echo "${DISABLE_RESULT:-ok}" ;;
rescanPlugins) echo ok ;;
esac
STUB
cat >"$stub_dir/gum" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$HOME/prompts"
exit "${GUM_STATUS:-0}"
STUB
chmod +x "$stub_dir/omarchy-shell" "$stub_dir/gum"

fixture() {
  test_home="$test_dir/$1"
  plugin="$test_home/.config/omarchy/plugins/acme.test"
  mkdir -p "$plugin/bin"
  printf '%s\n' '{"schemaVersion":1,"id":"acme.test","name":"Test","version":"1","kinds":["bar-widget"],"entryPoints":{"barWidget":"Widget.qml","uninstall":"bin/cleanup"}}' >"$plugin/manifest.json"
  touch "$plugin/Widget.qml" "$test_home/external-setup"
  cat >"$plugin/bin/cleanup" <<'HOOK'
#!/bin/bash
set -euo pipefail
[[ $PWD == "$OMARCHY_PLUGIN_DIR" && $OMARCHY_PLUGIN_REMOVAL_ID == "acme.test" ]]
[[ -f $OMARCHY_PLUGIN_DIR/manifest.json ]]
printf 'cleanup %s\n' "$*" >>"$HOME/events"
exit_code=${HOOK_STATUS:-0}
if (( exit_code == 0 )); then
  rm -- "$HOME/external-setup"
fi
exit "$exit_code"
HOOK
  chmod +x "$plugin/bin/cleanup"
}

remove_plugin() {
  HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-plugin-remove" acme.test "$@" 2>&1
}

fixture success
mkdir "$plugin/.git"
output=$(remove_plugin --yes) || fail "cleanup succeeds" "$output"
[[ ! -e $plugin && ! -e $test_home/external-setup ]] || fail "cleanup removes external setup before checkout removal"
grep -qFx 'cleanup --yes' "$test_home/events" || fail "explicit approval is forwarded to cleanup"
expected=$'shell listPlugins\nshell setPluginEnabled acme.test false\ncleanup --yes\nshell rescanPlugins'
[[ $(<"$test_home/events") == "$expected" ]] || fail "disable, cleanup, removal and rescan are ordered" "$(<"$test_home/events")"
grep -qF 'unsandboxed plugin code' <<<"$output" || fail "automation also sees the execution warning"
pass "approved cleanup runs in the plugin directory before removal and rescan"

fixture failure
output=$(HOOK_STATUS=7 remove_plugin --yes) && fail "failed cleanup aborts removal"
[[ -f $plugin/manifest.json && -f $test_home/external-setup ]] || fail "failed cleanup preserves files for retry"
! grep -qF rescanPlugins "$test_home/events" || fail "failed cleanup never reaches rescan"
grep -qF 'plugin files were kept' <<<"$output" || fail "failure explains retention"
output=$(remove_plugin --yes) || fail "cleanup can be retried" "$output"
[[ ! -e $plugin && ! -e $test_home/external-setup ]] || fail "retry finishes removal"
pass "failed cleanup keeps the plugin for retry and a retry completes"

fixture unconfirmed
output=$(remove_plugin </dev/null) && fail "non-interactive cleanup requires approval"
[[ -f $plugin/manifest.json && ! -e $test_home/prompts ]] || fail "unconfirmed removal preserves plugin"
! grep -qF cleanup "$test_home/events" || fail "unconfirmed cleanup never runs"
pass "non-interactive removal without --yes executes no plugin code"

fixture disable-failed
output=$(DISABLE_RESULT=failed remove_plugin --yes) && fail "failed widget unload aborts cleanup"
[[ -f $plugin/manifest.json && -f $test_home/external-setup ]] || fail "failed widget unload preserves setup"
! grep -qF cleanup "$test_home/events" || fail "failed widget unload never executes cleanup"
pass "IPC-level disable failure cannot be mistaken for successful unload"

fixture skipped
printf 'not json\n' >"$plugin/manifest.json"
output=$(remove_plugin --yes --skip-cleanup) || fail "explicit bypass works even with a broken manifest" "$output"
[[ ! -e $plugin && -f $test_home/external-setup ]] || fail "bypass removes only plugin files"
! grep -qF cleanup "$test_home/events" || fail "bypass does not run plugin code"
grep -qF 'Local setup may remain' <<<"$output" || fail "bypass warns about retained setup"
pass "explicit cleanup bypass removes broken plugins without running code"

fixture no-hook
jq 'del(.entryPoints.uninstall)' "$plugin/manifest.json" >"$plugin/next.json"
mv "$plugin/next.json" "$plugin/manifest.json"
output=$(remove_plugin --yes) || fail "legacy removal remains supported" "$output"
[[ ! -e $plugin && -f $test_home/external-setup ]] || fail "legacy removal keeps external setup"
compgen -G "$test_home/.config/omarchy/plugins/.acme.test.bak.*" >/dev/null || fail "hand-made plugin is backed up"
pass "plugins without hooks retain existing backup behavior"

fixture symlink
mv "$plugin" "$test_home/source"
ln -s "$test_home/source" "$plugin"
output=$(remove_plugin --yes) || fail "symlink removal succeeds" "$output"
[[ ! -L $plugin && -f $test_home/source/manifest.json && -f $test_home/external-setup ]] || fail "symlink removal only unlinks"
! grep -qF cleanup "$test_home/events" || fail "symlink cleanup is not executed"
pass "symlinked plugins are unlinked without executing their code"

for entry in '"/tmp/outside"' '"../outside"' '"bin/../cleanup"' '"bin//cleanup"' '"bin/cleanup/"' '"bin/./cleanup"' '""' 'null' '[]' '123' '"bin/cleanup\n"' '"bin/cleanup\r"' '"bin/cleanup\u0000"'; do
  fixture invalid
  jq --argjson entry "$entry" '.entryPoints.uninstall = $entry' "$plugin/manifest.json" >"$plugin/next.json"
  mv "$plugin/next.json" "$plugin/manifest.json"
  output=$(remove_plugin --yes) && fail "unsafe hook path is rejected: $entry"
  [[ -f $plugin/manifest.json && -f $test_home/external-setup ]] || fail "invalid hook preserves files"
done
pass "unsafe paths, control characters and invalid hook types are rejected"

fixture linked-executable
mv "$plugin/bin/cleanup" "$test_home/cleanup"
ln -s "$test_home/cleanup" "$plugin/bin/cleanup"
output=$(remove_plugin --yes) && fail "symlinked executable is rejected"
[[ -f $test_home/external-setup ]] || fail "symlinked executable never runs"
fixture linked-parent
mv "$plugin/bin" "$test_home/outside"
ln -s "$test_home/outside" "$plugin/bin"
output=$(remove_plugin --yes) && fail "symlinked parent is rejected"
pass "both executable and parent symlinks are rejected"

fixture permissions
chmod -x "$plugin/bin/cleanup"
output=$(remove_plugin --yes) && fail "non-executable hook is rejected"
PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-plugin-validate" "$plugin" >/dev/null 2>&1 && fail "install validation rejects non-executable hook"
chmod +x "$plugin/bin/cleanup"
PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-plugin-validate" "$plugin" >/dev/null || fail "install validation accepts executable hook"
pass "install and removal enforce the same executable hook contract"

fixture recursive
output=$(OMARCHY_PLUGIN_REMOVAL_ID=acme.test remove_plugin --yes) && fail "recursive self-removal is rejected"
[[ -f $plugin/manifest.json ]] || fail "recursive removal preserves plugin"
pass "recursive self-removal fails before cleanup"

if script -qec true /dev/null >/dev/null 2>&1; then
  fixture canceled
  output=$(HOME="$test_home" OMARCHY_PATH="$ROOT" PATH="$stub_dir:$ROOT/bin:$PATH" GUM_STATUS=1 \
    script -qec 'omarchy-plugin-remove acme.test' /dev/null) && fail "cancellation aborts removal"
  [[ -f $plugin/manifest.json && -f $test_home/external-setup ]] || fail "cancellation preserves setup"
  grep -qF 'uninstall entry point' "$test_home/prompts" || fail "confirmation names the code to execute"
  ! grep -qF cleanup "$test_home/events" || fail "cancellation never executes cleanup"
  pass "interactive confirmation discloses execution and cancellation runs no code"
else
  pass "script -qec unavailable; skipping interactive confirmation case"
fi
