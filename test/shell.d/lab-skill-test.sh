#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
skill="$ROOT/default/agents/skills/omarchy-lab"
test_tmp=$(mktemp -d)
trap 'rm -rf -- "$test_tmp"' EXIT

export HOME="$test_tmp/home with spaces"
export OMARCHY_PATH="$test_tmp/native with spaces"
mkdir -p "$HOME" "$OMARCHY_PATH/bin"
helper="$skill/scripts/lab"
[[ -x $helper ]] || fail "skill controller is executable"

# No controller must fail without offering installation or changing state.
if "$helper" health --json >"$test_tmp/out" 2>"$test_tmp/error"; then
  fail "missing controller was accepted"
fi
[[ ! -s $test_tmp/out ]] || fail "missing controller polluted machine output"

cat >"$OMARCHY_PATH/bin/omarchy-lab-viewer" <<'SH'
#!/bin/bash
printf 'native\n%s\n' "$OMARCHY_PATH"
printf '%s\n' "$@"
SH
chmod +x "$OMARCHY_PATH/bin/omarchy-lab-viewer"
"$helper" viewer status --json >"$test_tmp/native"
[[ $(head -1 "$test_tmp/native") == native ]] || fail "native fallback did not run"
[[ $(sed -n '2p' "$test_tmp/native") == "$OMARCHY_PATH" ]] || fail "native source environment changed"
[[ $(tail -2 "$test_tmp/native" | paste -sd ' ') == 'status --json' ]] || fail "native arguments changed"
if "$helper" ../viewer status >/dev/null 2>&1; then fail "native family path traversal accepted"; fi
pass "skill resolves native commands without rewriting the host source or allowing path traversal"

plugin="$HOME/.config/omarchy/plugins/acrogenesis.lab/bin"
mkdir -p "$plugin"
cat >"$plugin/omarchy-labctl" <<'SH'
#!/bin/bash
[[ ${1:-} == fail ]] && exit 17
printf 'standalone\n%s\n' "$OMARCHY_PATH"
printf '%s\n' "$@"
SH
chmod +x "$plugin/omarchy-labctl"
"$helper" checkout deploy 'branch with spaces' --json >"$test_tmp/standalone"
[[ $(head -1 "$test_tmp/standalone") == standalone ]] || fail "installed plugin not preferred"
[[ $(sed -n '2p' "$test_tmp/standalone") == "$OMARCHY_PATH" ]] || fail "standalone source environment changed"
[[ $(sed -n '5p' "$test_tmp/standalone") == 'branch with spaces' ]] || fail "standalone argument boundary changed"
result=0
"$helper" fail || result=$?
((result == 17)) || fail "controller failure was swallowed"
pass "skill prefers the installed plugin, preserves spaced arguments, and propagates failures"

run_node_test <<'JS'
const fs = require('fs')
const child = require('child_process')
const skill = path.join(root, 'default/agents/skills/omarchy-lab')
const text = fs.readFileSync(path.join(skill, 'SKILL.md'), 'utf8')
assert(text.startsWith('---\nname: omarchy-lab\ndescription:'), 'skill has discoverable metadata')
for (const match of text.matchAll(/```bash\n([^]*?)```/g)) {
  const result = child.spawnSync('bash', ['-n'], {input: match[1], encoding: 'utf8'})
  assertEqual(result.status, 0, 'skill command examples have valid shell syntax')
}
const agents = fs.readFileSync(path.join(root, 'AGENTS.md'), 'utf8')
assert(agents.includes('(default/agents/skills/omarchy-lab/SKILL.md)'), 'repository agents can discover the shipped skill')
JS
