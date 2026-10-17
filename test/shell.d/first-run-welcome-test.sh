#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The keybindings welcome greets first login, unless the platform's setup-user
# marked it not applicable (a phone has no keyboard-first workflow).

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/bin" "$tmp/home"
cat >"$tmp/bin/omarchy-notification-send" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$SENT"
SH
chmod +x "$tmp/bin/omarchy-notification-send"

welcome() {
  rm -f "$tmp/sent"
  HOME="$tmp/home" SENT="$tmp/sent" PATH="$tmp/bin:$ROOT/bin:$PATH" \
    bash "$ROOT/install/user/first-run/welcome.sh"
}

welcome || fail "welcome runs"
grep -q "Learn Keybindings" "$tmp/sent" 2>/dev/null || fail "welcome sends the keybindings toast"
pass "welcome sends the keybindings toast by default"

HOME="$tmp/home" "$ROOT/bin/omarchy-done" mark welcome-keybindings-not-applicable
welcome || fail "welcome runs when marked not applicable"
[[ ! -e $tmp/sent ]] || fail "welcome skips the toast when marked not applicable" "$(cat "$tmp/sent")"
pass "welcome skips the toast when the platform marked it not applicable"
