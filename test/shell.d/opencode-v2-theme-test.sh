#!/bin/bash
set -euo pipefail
source "$(dirname "$0")/base-test.sh"
require_command node
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
export HOME="$test_dir" OPENCODE_CONFIG_DIR="$test_dir/config" OMARCHY_PATH="$ROOT"
mkdir -p "$HOME/.local/state/omarchy/current/theme" "$OPENCODE_CONFIG_DIR"
printf '{}\n' >"$HOME/.local/state/omarchy/current/theme/opencode.json"
printf '{"theme":{"name":"custom","mode":"dark"},"plugins":["./herdr-opencode"]}\n' >"$OPENCODE_CONFIG_DIR/cli.json"
bash "$ROOT/bin/omarchy-theme-set-opencode"
jq -e '.theme == {name:"custom",mode:"dark"} and .plugins[0] == "./herdr-opencode" and (.plugins | length) == 2' "$OPENCODE_CONFIG_DIR/cli.json" >/dev/null
bash "$ROOT/bin/omarchy-theme-set-opencode" --activate
jq -e '.theme == {name:"omarchy",mode:"dark"} and (.plugins | length) == 2' "$OPENCODE_CONFIG_DIR/cli.json" >/dev/null
node --input-type=module <<'JS'
import fs from 'node:fs'
import path from 'node:path'
import assert from 'node:assert/strict'
import { pathToFileURL } from 'node:url'
const plugin = (await import(pathToFileURL(process.env.OPENCODE_CONFIG_DIR + '/omarchy-theme/tui.js'))).default
assert.equal(plugin.id, 'omarchy-theme')
let refreshes = 0
const listener = () => refreshes++
process.on('SIGUSR2', listener)
const cleanup = plugin.setup()
const dir = path.join(process.env.OPENCODE_CONFIG_DIR, 'themes')
fs.writeFileSync(path.join(dir, 'temporary'), '{}')
fs.renameSync(path.join(dir, 'temporary'), path.join(dir, 'omarchy.json'))
await new Promise(resolve => setTimeout(resolve, 600))
assert.equal(refreshes, 1, 'atomic replacement triggers one debounced local refresh')
cleanup()
fs.writeFileSync(path.join(dir, 'omarchy.json'), '{}')
await new Promise(resolve => setTimeout(resolve, 400))
assert.equal(refreshes, 1, 'disposed plugin stops watching')
process.off('SIGUSR2', listener)
JS
pass "OpenCode 2 theme activation, opt-out, Herdr preservation and watcher cleanup"

rm "$OPENCODE_CONFIG_DIR/cli.json"
bash "$ROOT/bin/omarchy-theme-set-opencode" --activate
jq -e '.theme.name == "omarchy" and (.plugins | length) == 1' "$OPENCODE_CONFIG_DIR/cli.json" >/dev/null
pass "fresh OpenCode 2 activation creates its configuration"

rm "$OPENCODE_CONFIG_DIR/cli.json"
printf '{"theme":"custom","keybinds":{}}\n' >"$OPENCODE_CONFIG_DIR/tui.json"
bash "$ROOT/bin/omarchy-theme-set-opencode" --activate
[[ ! -f $OPENCODE_CONFIG_DIR/cli.json ]] || fail "legacy preferences must migrate before cli.json is created"
pass "activation leaves legacy preference migration to OpenCode"

# Exercise the actual migration with a retained active copy whose source was
# removed. Missing optional application palettes must not stop the update queue.
mkdir -p "$test_dir/bin" "$test_dir/source/themes/available"
ln -s "$ROOT/bin/omarchy-theme-set-opencode" "$test_dir/bin/omarchy-theme-set-opencode"
cat >"$test_dir/bin/omarchy-theme-refresh" <<'SH'
#!/bin/bash
echo refreshed >>"$HOME/refresh-calls"
if [[ ${REBUILD_PALETTE:-0} == 1 ]]; then
  printf '{}\n' >"$HOME/.local/state/omarchy/current/theme/opencode.json"
fi
SH
chmod +x "$test_dir/bin/omarchy-theme-refresh"
export PATH="$test_dir/bin:$PATH" OMARCHY_PATH="$test_dir/source"
rm -f "$OPENCODE_CONFIG_DIR/tui.json" "$HOME/.local/state/omarchy/current/theme/opencode.json"
printf 'removed\n' >"$HOME/.local/state/omarchy/current/theme.name"
printf '{"theme":{"name":"custom"}}\n' >"$OPENCODE_CONFIG_DIR/cli.json"
bash -euo pipefail "$ROOT/migrations/1791923666.sh"
[[ ! -f $HOME/refresh-calls ]] || fail "a removed theme must not be refreshed"
jq -e '.theme.name == "custom" and .plugins == null' "$OPENCODE_CONFIG_DIR/cli.json" >/dev/null
pass "missing palette and removed theme source do not block migration or alter preferences"

printf 'available\n' >"$HOME/.local/state/omarchy/current/theme.name"
REBUILD_PALETTE=1 bash -euo pipefail "$ROOT/migrations/1791923666.sh"
[[ -f $HOME/refresh-calls ]] || fail "an installed theme must be refreshed"
jq -e '.theme.name == "omarchy" and (.plugins | length) == 1' "$OPENCODE_CONFIG_DIR/cli.json" >/dev/null
pass "migration rebuilds an available theme and activates its palette"

rm "$HOME/.local/state/omarchy/current/theme/opencode.json"
bash -euo pipefail "$ROOT/migrations/1791923666.sh"
pass "a refresh that produces no OpenCode palette also skips activation"
