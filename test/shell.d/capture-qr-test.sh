#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT
mkdir -p "$TMPDIR/bin"

# Stub the capture chain so the helper runs headlessly. wl-copy records its
# argv rather than touching the real clipboard.
for stub in hyprpicker grim omarchy-notification-send; do
  printf '#!/bin/bash\nexit 0\n' >"$TMPDIR/bin/$stub"
done
cat >"$TMPDIR/bin/slurp" <<'SH'
#!/bin/bash
printf '0,0 100x100\n'
SH
cat >"$TMPDIR/bin/zbarimg" <<'SH'
#!/bin/bash
printf '%s' "$QR_PAYLOAD"
SH
cat >"$TMPDIR/bin/wl-copy" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$WL_COPY_ARGS_OUT"
cat >/dev/null
SH
cat >"$TMPDIR/bin/omarchy-i18n" <<'SH'
#!/bin/bash
printf '%s' "${1:-}"
SH
chmod +x "$TMPDIR/bin"/*

QR_PAYLOAD='{"ssid":"guest","password":"hunter2"}' \
WL_COPY_ARGS_OUT="$TMPDIR/copy-args" PATH="$TMPDIR/bin:$PATH" \
  "$ROOT/bin/omarchy-capture-qr"

args=$(<"$TMPDIR/copy-args")

[[ $args == *--sensitive* ]] || fail "QR copy stays sensitive" "wl-copy args: $args"
pass "QR copy stays sensitive"

[[ $args == *"--type text/plain;charset=utf-8"* ]] ||
  fail "QR copy advertises UTF-8 text" "wl-copy args: $args"
pass "QR copy advertises UTF-8 text"
