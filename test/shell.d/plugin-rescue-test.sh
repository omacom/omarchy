#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

BIN="$ROOT/bin/omarchy-plugin-rescue"
TESTROOT=""

cleanup() {
  [[ -n ${TESTROOT:-} ]] && rm -rf "$TESTROOT"
}
trap cleanup EXIT

new_env() {
  cleanup
  TESTROOT=$(mktemp -d)
  export HOME="$TESTROOT/home"
  export XDG_STATE_HOME="$TESTROOT/state"
  mkdir -p "$HOME/.config/omarchy/plugins"
}

assert_jq() {
  local description=$1 expression=$2 file=$3
  jq -e "$expression" "$file" >/dev/null || fail "$description"
  pass "$description"
}

assert_same_file() {
  local description=$1 expected=$2 actual=$3
  cmp -s "$expected" "$actual" || fail "$description"
  pass "$description"
}

new_env
cat >"$HOME/.config/omarchy/shell.json" <<'JSON'
{
  "version": 1,
  "idle": {"lock": 333},
  "bar": {
    "id": "third.bar",
    "centerAnchor": "third.widget",
    "layout": {
      "left": [{"id":"omarchy.menu"},{"id":"third.widget","x":1}],
      "center": [{"id":"omarchy.clock"}],
      "right": ["third.stale", {"id":"omarchy.power"}]
    }
  },
  "plugins": [{"id":"third.service","setting":true},{"id":"omarchy.settings"}],
  "disabledPlugins": ["omarchy.weather"]
}
JSON
for id in third.bar third.widget third.service; do
  mkdir -p "$HOME/.config/omarchy/plugins/$id"
  printf '{"schemaVersion":1,"id":"%s"}\n' "$id" >"$HOME/.config/omarchy/plugins/$id/manifest.json"
done
cp "$HOME/.config/omarchy/shell.json" "$TESTROOT/original.json"

"$BIN" rescue --no-restart >/dev/null
assert_jq "third-party full bar falls back to the built-in bar" '(.bar.id? // "") == ""' "$HOME/.config/omarchy/shell.json"
assert_jq "third-party layout references are removed, including stale ids" '[.bar.layout.left[],.bar.layout.center[],.bar.layout.right[] | (if type=="object" then .id else . end)] | all(.[]; startswith("third.")|not)' "$HOME/.config/omarchy/shell.json"
assert_jq "third-party services are removed" '[.plugins[].id] | index("third.service") == null' "$HOME/.config/omarchy/shell.json"
assert_jq "unrelated shell configuration is preserved" '.idle.lock == 333 and (.disabledPlugins | index("omarchy.weather") != null) and ([.plugins[].id] | index("omarchy.settings") != null)' "$HOME/.config/omarchy/shell.json"

"$BIN" restore --no-restart >/dev/null
assert_same_file "restore returns the exact original shell.json" "$TESTROOT/original.json" "$HOME/.config/omarchy/shell.json"

new_env
cat >"$HOME/.config/omarchy/shell.json" <<'JSON'
{
  "version":1,
  "bar": {
    "centerAnchor":"example.clock",
    "layout":{"left":[],"center":[{"id":"example.clock","format":"HH:mm:ss"}],"right":[]}
  },
  "plugins":[],
  "disabledPlugins":["omarchy.clock","omarchy.weather"],
  "cloneSourceRestores":["example.clock"]
}
JSON
mkdir -p "$HOME/.config/omarchy/plugins/example.clock"
cat >"$HOME/.config/omarchy/plugins/example.clock/manifest.json" <<'JSON'
{"schemaVersion":1,"id":"example.clock","omarchy":{"clonedFrom":"omarchy.clock"}}
JSON

"$BIN" --no-restart >/dev/null
assert_jq "an active clone returns to its trusted built-in source with settings intact" '.bar.centerAnchor == "omarchy.clock" and .bar.layout.center[0].id == "omarchy.clock" and .bar.layout.center[0].format == "HH:mm:ss"' "$HOME/.config/omarchy/shell.json"
assert_jq "the restored built-in clone source is temporarily re-enabled" '(.disabledPlugins | index("omarchy.clock")) == null and (.disabledPlugins | index("omarchy.weather")) != null' "$HOME/.config/omarchy/shell.json"

new_env
cat >"$HOME/.config/omarchy/shell.json" <<'JSON'
{"version":1,"bar":{"layout":{"left":[{"id":"evil.clone"}],"center":[],"right":[]}},"plugins":[]}
JSON
mkdir -p "$HOME/.config/omarchy/plugins/evil.clone"
cat >"$HOME/.config/omarchy/plugins/evil.clone/manifest.json" <<'JSON'
{"schemaVersion":1,"id":"evil.clone","entryPoints":{"service":"payload.sh"},"omarchy":{"clonedFrom":"evil.other"}}
JSON
cat >"$HOME/.config/omarchy/plugins/evil.clone/payload.sh" <<EOF
#!/bin/bash
touch "$TESTROOT/executed"
EOF
chmod +x "$HOME/.config/omarchy/plugins/evil.clone/payload.sh"

"$BIN" rescue --no-restart >/dev/null
[[ ! -e $TESTROOT/executed ]] || fail "plugin rescue never executes third-party plugin code"
pass "plugin rescue never executes third-party plugin code"
assert_jq "untrusted clonedFrom metadata cannot activate another third-party id" '.bar.layout.left | length == 0' "$HOME/.config/omarchy/shell.json"

new_env
cat >"$HOME/.config/omarchy/shell.json" <<'JSON'
{"version":1,"bar":{"layout":{"left":[],"center":[],"right":[]}},"plugins":[{"id":"broken.plugin"}]}
JSON
mkdir -p "$HOME/.config/omarchy/plugins/broken.plugin"
printf '{not-json' >"$HOME/.config/omarchy/plugins/broken.plugin/manifest.json"

"$BIN" rescue --no-restart >/dev/null 2>/dev/null
assert_jq "a stale config id is rescued even when its manifest is malformed" '.plugins | length == 0' "$HOME/.config/omarchy/shell.json"

new_env
cat >"$HOME/.config/omarchy/shell.json" <<'JSON'
{"version":1,"bar":{"layout":{"left":[{"id":"third.widget"}],"center":[],"right":[]}},"plugins":[]}
JSON
"$BIN" rescue --no-restart >/dev/null
jq '.idle={"lock":999}' "$HOME/.config/omarchy/shell.json" >"$TESTROOT/changed"
mv "$TESTROOT/changed" "$HOME/.config/omarchy/shell.json"

if "$BIN" restore --no-restart >/dev/null 2>&1; then
  fail "restore refuses to overwrite shell.json changed during rescue mode"
fi
pass "restore refuses to overwrite shell.json changed during rescue mode"

"$BIN" restore --force --no-restart >/dev/null 2>&1
assert_jq "forced restore returns the exact pre-rescue reference" '.bar.layout.left[0].id == "third.widget"' "$HOME/.config/omarchy/shell.json"

new_env
cat >"$HOME/.config/omarchy/shell.json" <<'JSON'
{"version":1,"bar":{"layout":{"left":[{"id":"third.widget"}],"center":[],"right":[]}},"plugins":[]}
JSON
mkdir -p "$TESTROOT/bin"
cat >"$TESTROOT/bin/omarchy-restart-shell" <<'STUB'
#!/bin/bash
jq -e '.bar.layout.left | length == 0' "$HOME/.config/omarchy/shell.json" >/dev/null
STUB
chmod +x "$TESTROOT/bin/omarchy-restart-shell"

PATH="$TESTROOT/bin:$PATH" "$BIN" rescue >/dev/null || fail "safe config is installed before shell restart is attempted"
pass "safe config is installed before shell restart is attempted"
