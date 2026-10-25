#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

if [[ ! -f /sys/power/image_size ]]; then
  skip "hibernation is unavailable; skipping setup prompt test"
  exit 0
fi

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT
mkdir -p "$tmpdir/bin"

cat >"$tmpdir/bin/omarchy-cmd-missing" <<'EOF'
#!/bin/bash
exit 1
EOF

cat >"$tmpdir/bin/grep" <<'EOF'
#!/bin/bash
exit 1
EOF

cat >"$tmpdir/bin/free" <<'EOF'
#!/bin/bash
if [[ ${LC_ALL:-} == "C" ]]; then
  printf 'Mem: 31Gi 1Gi 30Gi\n'
else
  printf '内存： 31Gi 1Gi 30Gi\n'
fi
EOF

cat >"$tmpdir/bin/gum" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >"$PROMPT_LOG"
exit 1
EOF

chmod +x "$tmpdir/bin/"*

env -u LC_ALL PROMPT_LOG="$tmpdir/prompt" PATH="$tmpdir/bin:$PATH" \
  "$ROOT/bin/omarchy-hibernation-setup"

[[ $(<"$tmpdir/prompt") == "confirm Use 31Gi on boot drive to make hibernation available?" ]] ||
  fail "hibernation setup reads memory size independently of the user's locale"
pass "hibernation setup reads memory size independently of the user's locale"
