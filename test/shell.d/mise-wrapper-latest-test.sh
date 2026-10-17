#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

home="$test_dir/home"
mkdir -p "$home/.local/bin"

HOME="$home" PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-mise-install" claude
wrapper="$home/.local/bin/claude"

grep -qF 'mise use -g --quiet "claude@latest" || exit 1' "$wrapper" ||
  fail "mise wrapper pins the tool at @latest" "$(cat "$wrapper")"
grep -qF 'exec mise x "claude@latest" -- "claude" "$@"' "$wrapper" ||
  fail "mise wrapper executes the @latest spec" "$(cat "$wrapper")"
pass "mise wrapper refreshes to @latest on each run"

HOME="$home" PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-mise-install" "npm:@kitlangton/ghui" ghui
grep -qF 'mise use -g --quiet "npm:@kitlangton/ghui@latest" || exit 1' "$home/.local/bin/ghui" ||
  fail "mise wrapper appends @latest after a scoped npm package" "$(cat "$home/.local/bin/ghui")"
pass "mise wrapper appends @latest after a scoped npm package"

HOME="$home" PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-mise-install" "claude@1.2.3" claude-pinned
grep -qF 'mise use -g --quiet "claude@1.2.3" || exit 1' "$home/.local/bin/claude-pinned" ||
  fail "mise wrapper leaves an already-versioned spec alone" "$(cat "$home/.local/bin/claude-pinned")"
if grep -q 'claude@1.2.3@latest' "$home/.local/bin/claude-pinned"; then
  fail "mise wrapper does not append @latest onto a pinned version"
fi
pass "mise wrapper leaves an already-versioned spec alone"

HOME="$home" PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-mise-install" "claude@latest" claude-latest
grep -qF 'mise use -g --quiet "claude@latest" || exit 1' "$home/.local/bin/claude-latest" ||
  fail "mise wrapper does not double @latest" "$(cat "$home/.local/bin/claude-latest")"
pass "mise wrapper does not double @latest"

HOME="$home" PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-mise-install" \
  "http:muse[url=https://example.test/muse.sh,bin=muse]" muse
grep -qF 'mise use -g --quiet "http:muse[url=https://example.test/muse.sh,bin=muse]@latest" || exit 1' "$home/.local/bin/muse" ||
  fail "mise wrapper appends @latest after a backend spec's options" "$(cat "$home/.local/bin/muse")"

HOME="$home" PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-mise-install" \
  "http:tool[url=https://example.test/@releases/tool.sh]" tool
grep -qF 'mise use -g --quiet "http:tool[url=https://example.test/@releases/tool.sh]@latest" || exit 1' "$home/.local/bin/tool" ||
  fail "mise wrapper does not read an @ inside the options as a version" "$(cat "$home/.local/bin/tool")"

HOME="$home" PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-mise-install" \
  "http:tool[url=https://example.test/@releases/tool.sh]@1.2.3" tool-pinned
grep -qF 'mise use -g --quiet "http:tool[url=https://example.test/@releases/tool.sh]@1.2.3" || exit 1' "$home/.local/bin/tool-pinned" ||
  fail "mise wrapper leaves a version after the options alone" "$(cat "$home/.local/bin/tool-pinned")"
pass "mise wrapper appends @latest after a backend spec's options"

migration="$ROOT/migrations/1789093830.sh"
[[ -f $migration ]] || fail "a migration rewrites existing mise wrappers onto @latest"
pass "a migration rewrites existing mise wrappers onto @latest"

bin_dir="$home/.local/bin"
cat >"$bin_dir/codex" <<'EOF'
#!/bin/bash
export MISE_MINIMUM_RELEASE_AGE=0
mise use -g --quiet "codex" || exit 1
exec mise x "codex" -- "codex" "$@"
EOF
chmod +x "$bin_dir/codex"

cat >"$bin_dir/muse" <<'EOF'
#!/bin/bash
export MISE_MINIMUM_RELEASE_AGE=0
mise use -g --quiet "http:muse[url=https://example.test/muse.sh,bin=muse]" || exit 1
exec mise x "http:muse[url=https://example.test/muse.sh,bin=muse]" -- "muse" "$@"
EOF
chmod +x "$bin_dir/muse"

HOME="$home" PATH="$ROOT/bin:$PATH" bash -euo pipefail "$migration" >/dev/null

grep -qF 'mise use -g --quiet "codex@latest" || exit 1' "$bin_dir/codex" ||
  fail "migration rewrites a quiet wrapper onto @latest" "$(cat "$bin_dir/codex")"
grep -qF 'exec mise x "http:muse[url=https://example.test/muse.sh,bin=muse]@latest" -- "muse" "$@"' "$bin_dir/muse" ||
  fail "migration rewrites a wrapper whose spec carries options" "$(cat "$bin_dir/muse")"
pass "migration rewrites a quiet wrapper onto @latest"

before=$(cat "$bin_dir/codex")
HOME="$home" PATH="$ROOT/bin:$PATH" bash -euo pipefail "$migration" >/dev/null
[[ $(cat "$bin_dir/codex") == "$before" ]] || fail "latest-wrapper migration is idempotent"
pass "latest-wrapper migration is idempotent"
