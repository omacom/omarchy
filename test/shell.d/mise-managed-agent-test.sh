#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export HOME="$test_tmp/home"
mkdir -p "$test_tmp/bin"
export TEST_LOG="$test_tmp/log"
export PATH="$test_tmp/bin:$ROOT/bin:$PATH"
cat >"$test_tmp/bin/mise" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_LOG"
[[ $1 != where && ${TEST_MISE_FAIL:-0} != 1 ]]
STUB
cat >"$test_tmp/bin/omarchy-launch-floating-terminal-with-presentation" <<'STUB'
#!/bin/bash
printf 'install-terminal:%s\n' "$*" >>"$TEST_LOG"
STUB
cat >"$test_tmp/bin/omarchy-agent" <<'STUB'
#!/bin/bash
printf 'agent:%s\n' "$*" >>"$TEST_LOG"
STUB
cat >"$test_tmp/bin/omarchy-cmd-present" <<'STUB'
#!/bin/bash
exit 0
STUB
chmod +x "$test_tmp/bin/"*
omarchy-mise-install codex
: >"$TEST_LOG"
omarchy-default-agent codex
grep -Fx 'where codex' "$TEST_LOG" >/dev/null || fail "generated wrapper must probe its mise package"
grep -F 'install-terminal:omarchy-default-agent --install codex' "$TEST_LOG" >/dev/null || fail "a missing package must start installation before selecting the agent"
[[ ! -f $HOME/.config/omarchy/defaults/agent ]] || fail "a missing agent must not become the default"
# Existing read-only wrappers from the migration predate the explicit marker.
printf '#!/bin/bash\nexec mise x "codex" -- "codex" "$@"\n' >"$HOME/.local/bin/codex"
: >"$TEST_LOG"
omarchy-default-agent codex
grep -Fx 'where codex' "$TEST_LOG" >/dev/null || fail "legacy read-only wrappers must probe their package"
# A user's canonical-looking wrapper for another package must stay theirs.
printf '#!/bin/bash\nexec mise x "custom-codex" -- "custom-agent" "$@"\n' >"$HOME/.local/bin/codex"
: >"$TEST_LOG"
omarchy-default-agent codex
if grep -E '^(where|use) ' "$TEST_LOG" >/dev/null; then fail "foreign two-line launchers must not trigger mise installation"; fi
printf '#!/bin/bash\nexec mise x "codex" -- "codex" "$@"\n' >"$HOME/.local/bin/codex"
omarchy-default-agent --install codex
grep -Fx 'use -g codex' "$TEST_LOG" >/dev/null || fail "managed agent selection must restore the package pin"
[[ $(cat "$HOME/.config/omarchy/defaults/agent") == codex ]] || fail "successful installation must set the default"
TEST_MISE_FAIL=1 omarchy-update-mise >"$test_tmp/update" 2>&1 && fail "mise update failures must propagate"
TEST_MISE_FAIL=0 omarchy-update-mise >/dev/null
pass "managed wrappers restore missing mise packages and update failures propagate"
