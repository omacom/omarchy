#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

stubs="$tmpdir/stubs"
mkdir -p "$stubs"

cat >"$stubs/omarchy-launch-webapp" <<'SH'
#!/bin/bash
printf '<%s>\n' "$@"
SH
chmod +x "$stubs/omarchy-launch-webapp"

handler="$ROOT/bin/omarchy-webapp-handler-whatsapp"

actual=$(PATH="$stubs:$PATH" "$handler" 'whatsapp://send?phone=15551234567&text=Hello%20there')
[[ $actual == '<https://web.whatsapp.com/send?phone=15551234567&text=Hello%20there>' ]] ||
  fail "WhatsApp handler preserves phone and encoded message parameters" "$actual"
pass "WhatsApp handler translates send links"

actual=$(PATH="$stubs:$PATH" "$handler" 'whatsapp://send/?phone=15551234567#ignored')
[[ $actual == '<https://web.whatsapp.com/send?phone=15551234567>' ]] ||
  fail "WhatsApp handler strips URL fragments" "$actual"
pass "WhatsApp handler accepts the send slash variant"

for url in '' 'whatsapp://' 'whatsapp://settings' 'https://example.com/?phone=15551234567'; do
  actual=$(PATH="$stubs:$PATH" "$handler" "$url")
  [[ $actual == '<https://web.whatsapp.com/>' ]] ||
    fail "WhatsApp handler falls back safely for '$url'" "$actual"
done
pass "WhatsApp handler falls back to the WhatsApp home page"

desktop="$ROOT/applications/WhatsApp.desktop"
grep -Fxq 'Exec=omarchy-webapp-handler-whatsapp %u' "$desktop" ||
  fail "WhatsApp desktop entry routes protocol links through the handler"
grep -Fxq 'MimeType=x-scheme-handler/whatsapp' "$desktop" ||
  fail "WhatsApp desktop entry registers the whatsapp scheme"
pass "WhatsApp desktop entry registers the protocol handler"

migration="$ROOT/migrations/1788836249.sh"
home="$tmpdir/home"
mkdir -p "$home/.local/share/applications"

cat >"$stubs/update-desktop-database" <<'SH'
#!/bin/bash
printf '%s\n' "$1" >>"$UPDATE_LOG"
SH
chmod +x "$stubs/update-desktop-database"

update_log="$tmpdir/update.log"
touch "$home/.local/share/applications/WhatsApp.desktop"
HOME="$home" OMARCHY_PATH="$ROOT" UPDATE_LOG="$update_log" PATH="$stubs:$PATH" \
  bash -euo pipefail "$migration" >/dev/null
cmp -s "$ROOT/applications/WhatsApp.desktop" "$home/.local/share/applications/WhatsApp.desktop" ||
  fail "WhatsApp migration refreshes an installed launcher"
[[ $(wc -l <"$update_log") == 1 ]] || fail "WhatsApp migration refreshes the desktop database"
pass "WhatsApp migration upgrades an existing launcher"

rm -f "$home/.local/share/applications/WhatsApp.desktop"
: >"$update_log"
HOME="$home" OMARCHY_PATH="$ROOT" UPDATE_LOG="$update_log" PATH="$stubs:$PATH" \
  bash -euo pipefail "$migration" >/dev/null
[[ ! -e $home/.local/share/applications/WhatsApp.desktop ]] ||
  fail "WhatsApp migration does not restore a removed preinstall"
[[ ! -s $update_log ]] || fail "WhatsApp migration skips the desktop database when no launcher exists"
pass "WhatsApp migration preserves a removed preinstall"
