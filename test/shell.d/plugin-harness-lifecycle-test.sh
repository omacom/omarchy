#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
home="$test_tmp/home"
plugins="$home/.config/omarchy/plugins"
agent_file="$home/.config/omarchy/defaults/agent"
mock_bin="$test_tmp/bin"
mkdir -p "$plugins" "$(dirname "$agent_file")" "$mock_bin"
SHELL_CALLS="$test_tmp/shell-calls"
touch "$SHELL_CALLS"

cat >"$mock_bin/omarchy-shell" <<'SH'
#!/bin/bash
case "$*" in
  "shell listPlugins") echo "${SHELL_PLUGINS:-[]}" ;;
  *) printf '%s\n' "$*" >>"$SHELL_CALLS"; echo ok ;;
esac
SH
cat >"$mock_bin/omarchy-plugin-validate" <<'SH'
#!/bin/bash
exec "$OMARCHY_PATH/bin/omarchy-plugin-validate" "$@"
SH
cat >"$mock_bin/omarchy-agent-catalog" <<'SH'
#!/bin/bash
exec "$OMARCHY_PATH/bin/omarchy-agent-catalog" "$@"
SH
chmod +x "$mock_bin"/*

export HOME="$home"
export OMARCHY_PATH="$ROOT"
export SHELL_CALLS
export PATH="$mock_bin:$ROOT/bin:$PATH"

write_manifest() {
  local dir="$1"
  local harness="$2"
  jq -n --arg id "$(basename "$dir")" --arg harness "$harness" '
    {
      schemaVersion: 1,
      id: $id,
      name: "Test integration",
      version: "1.0.0",
      kinds: [],
      entryPoints: {},
      agentHarness: {
        id: $harness,
        name: "Test Agent",
        install: {type: "mise", package: "npm:test-agent", command: "test-agent"},
        launch: {mode: "terminal", command: ["test-agent"]}
      }
    }
  ' >"$dir/manifest.json"
}

selected="$plugins/acme.selected"
ignored_duplicate="$plugins/zeta.ignored"
mkdir -p "$selected" "$ignored_duplicate"
write_manifest "$selected" "duplicate-agent"
write_manifest "$ignored_duplicate" "duplicate-agent"
printf '%s\n' duplicate-agent >"$agent_file"
omarchy-plugin-remove zeta.ignored --yes >/dev/null
[[ $(<"$agent_file") == duplicate-agent ]] || fail "plugin removal clears a default backed by an earlier duplicate harness"
pass "plugin removal preserves a selected harness when removing an ignored duplicate"

removed="$plugins/acme.removed"
mkdir -p "$removed"
write_manifest "$removed" "removed-agent"
printf '%s\n' removed-agent >"$agent_file"
omarchy-plugin-remove acme.removed --yes >/dev/null
[[ ! -e $agent_file ]] || fail "plugin removal preserves a removed default harness"
pass "plugin removal clears its selected harness"

origin="$test_tmp/origin"
seed="$test_tmp/seed"
mkdir -p "$origin" "$seed"
git init --quiet "$seed"
git -C "$seed" config user.email test@example.com
git -C "$seed" config user.name Test
write_manifest "$seed" "stable-agent"
jq '.kinds = ["service"] | .entryPoints = {service: "Service.qml"}' "$seed/manifest.json" >"$seed/updated.json"
mv "$seed/updated.json" "$seed/manifest.json"
touch "$seed/Service.qml"
git -C "$seed" add manifest.json
git -C "$seed" add Service.qml
git -C "$seed" commit --quiet -m initial
git init --bare --quiet "$origin"
git -C "$origin" symbolic-ref HEAD refs/heads/main
git -C "$seed" remote add origin "$origin"
git -C "$seed" push --quiet -u origin HEAD:main

git clone --quiet "$origin" "$plugins/acme.updated"
git -C "$plugins/acme.updated" checkout --quiet main
printf '%s\n' stable-agent >"$agent_file"
export SHELL_PLUGINS='[{"id":"acme.updated","enabled":true}]'

write_manifest "$seed" "changed-agent"
git -C "$seed" add manifest.json
git -C "$seed" commit --quiet -m change-harness
git -C "$seed" push --quiet origin HEAD:main
omarchy-plugin-update acme.updated --yes >/dev/null
[[ ! -e $agent_file ]] || fail "plugin update preserves a changed default harness"
pass "plugin update clears a changed selected harness"
grep -Fqx 'shell setPluginEnabled acme.updated false' "$SHELL_CALLS" ||
  fail "plugin update leaves an enabled plugin active after it becomes metadata-only"
pass "plugin update disables an enabled plugin that becomes metadata-only"

printf '%s\n' unrelated-agent >"$agent_file"
write_manifest "$seed" "changed-agent"
jq '.version = "1.0.1"' "$seed/manifest.json" >"$seed/updated.json"
mv "$seed/updated.json" "$seed/manifest.json"
git -C "$seed" add manifest.json
git -C "$seed" commit --quiet -m unrelated-change
git -C "$seed" push --quiet origin HEAD:main
omarchy-plugin-update acme.updated --yes >/dev/null
[[ $(<"$agent_file") == unrelated-agent ]] || fail "plugin update clears an unrelated default harness"
pass "plugin update preserves an unrelated default harness"

before=$(git -C "$plugins/acme.updated" rev-parse HEAD)
printf '%s\n' afk >"$agent_file"
write_manifest "$seed" "conflicting-agent"
jq '.agentHarness.aliases = ["afk"]' "$seed/manifest.json" >"$seed/updated.json"
mv "$seed/updated.json" "$seed/manifest.json"
git -C "$seed" add manifest.json
git -C "$seed" commit --quiet -m conflict
git -C "$seed" push --quiet origin HEAD:main
if omarchy-plugin-update acme.updated --yes >/dev/null 2>&1; then
  fail "plugin update accepts a conflicting harness"
fi
[[ $(git -C "$plugins/acme.updated" rev-parse HEAD) == "$before" ]] || fail "plugin update does not restore the previous commit after rejection"
[[ $(jq -r '.agentHarness.id' "$plugins/acme.updated/manifest.json") == changed-agent ]] || fail "plugin update does not restore the previous manifest after rejection"
[[ $(<"$agent_file") == afk ]] || fail "plugin update changes the default after rejection"
pass "plugin update restores rejected harness changes"