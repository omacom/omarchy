#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin"

for stub in omarchy-pkg-add omarchy-pkg-drop omarchy-tui-install omarchy-tui-remove; do
  cat >"$tmp_dir/bin/$stub" <<SCRIPT
#!/bin/bash
printf '%s:%s\n' "$stub" "\$*" >>"\$TEST_LOG"
SCRIPT
  chmod +x "$tmp_dir/bin/$stub"
done

export TEST_LOG="$tmp_dir/log"
export PATH="$tmp_dir/bin:$PATH"
export OMARCHY_PATH="$ROOT"
export HOME="$tmp_dir/home"
mkdir -p "$HOME/.config/tql"
touch "$HOME/.config/tql/tql.sqlite"

"$ROOT/bin/omarchy-install-tql" >/dev/null

grep -qxF "omarchy-pkg-add:tql" "$TEST_LOG" || fail "tql install adds the tql package" "$(cat "$TEST_LOG")"
pass "tql install adds the tql package"

grep -qxF "omarchy-tui-install:tql tql tile $ROOT/applications/icons/tql.png" "$TEST_LOG" || fail "tql install creates a launcher with the bundled icon" "$(cat "$TEST_LOG")"
pass "tql install creates a launcher with the bundled icon"

[[ -f $ROOT/applications/icons/tql.png ]] || fail "tql ships its launcher icon"
pass "tql ships its launcher icon"

: >"$TEST_LOG"
"$ROOT/bin/omarchy-remove-tql" >/dev/null

grep -qxF "omarchy-pkg-drop:tql" "$TEST_LOG" || fail "tql removal drops the tql package" "$(cat "$TEST_LOG")"
pass "tql removal drops the tql package"

grep -qxF "omarchy-tui-remove:tql" "$TEST_LOG" || fail "tql removal removes its launcher" "$(cat "$TEST_LOG")"
pass "tql removal removes its launcher"

[[ -f $HOME/.config/tql/tql.sqlite ]] || fail "tql removal keeps the saved connections"
pass "tql removal keeps the saved connections"
