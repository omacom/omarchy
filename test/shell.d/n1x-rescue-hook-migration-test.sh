#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin"
export CALL_LOG="$tmp_dir/calls" OMARCHY_N1X_RESCUE_HOOK="$tmp_dir/zz-omarchy-n1x-rescue.hook"
export PATH="$tmp_dir/bin:$PATH"

cat > "$tmp_dir/bin/sudo" <<'SH'
#!/bin/bash
"$@"
SH
cat > "$tmp_dir/bin/limine-entry-tool" <<'SH'
#!/bin/bash
echo "limine-entry-tool $*" >> "$CALL_LOG"
SH
chmod +x "$tmp_dir/bin/"*

migration=$(grep -lF 'zz-omarchy-n1x-rescue.hook' "$ROOT"/migrations/*.sh)
run() { : > "$CALL_LOG"; bash -euo pipefail "$migration" >/dev/null; }

# An install that ran the n1x-xps16 branch: its hook and its rescue entry.
printf '[Action]\nExec = /usr/bin/omarchy-refresh-n1x-rescue\n' > "$OMARCHY_N1X_RESCUE_HOOK"
run
[[ ! -e $OMARCHY_N1X_RESCUE_HOOK ]] || fail "the rescue hook is removed"
grep -Fxq 'limine-entry-tool --remove-uki linux-omarchy-n1x-rescue --quiet' "$CALL_LOG" ||
  fail "the rescue entry is removed" "$(cat "$CALL_LOG")"
pass "an install with the old rescue hook loses the hook and its entry"

run
[[ ! -s $CALL_LOG ]] || fail "the migration does nothing once the hook is gone" "$(cat "$CALL_LOG")"
pass "the migration is idempotent"
