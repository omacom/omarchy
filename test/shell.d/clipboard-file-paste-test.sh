#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin"
printf 'image-data' >"$tmp/image.png"

cat >"$tmp/bin/wl-copy" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$WL_COPY_ARGS"
cat >"$WL_COPY_OUT"
SH

cat >"$tmp/bin/wtype" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$WTYPE_OUT"
SH

chmod +x "$tmp/bin/wl-copy" "$tmp/bin/wtype"

PATH="$tmp/bin:$PATH" WL_COPY_ARGS="$tmp/wl-copy.args" WL_COPY_OUT="$tmp/copied" WTYPE_OUT="$tmp/wtype" \
  "$ROOT/bin/omarchy-clipboard-paste-file" image/png "$tmp/image.png"

[[ $(<"$tmp/copied") == image-data ]] || fail "clipboard image helper preserves image bytes"
[[ $(<"$tmp/wl-copy.args") == '--type image/png' ]] || fail "clipboard image helper keeps image MIME type"
[[ $(<"$tmp/wtype") == '-M ctrl -k v -m ctrl' ]] || fail "clipboard image helper sends Ctrl+V"
pass "clipboard image helper uses an image-capable paste shortcut"

rm -f "$tmp/wtype"
PATH="$tmp/bin:$PATH" WL_COPY_ARGS="$tmp/wl-copy.args" WL_COPY_OUT="$tmp/copied" WTYPE_OUT="$tmp/wtype" \
  "$ROOT/bin/omarchy-clipboard-paste-file" --copy-only image/png "$tmp/image.png"

[[ ! -e $tmp/wtype ]] || fail "clipboard image helper copy-only avoids synthetic paste"
pass "clipboard image helper copy-only remains copy-only"
