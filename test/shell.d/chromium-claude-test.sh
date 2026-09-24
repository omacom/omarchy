#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Exercise the privileged installer without writing to the host's /usr/share.
if ! command -v bwrap >/dev/null || ! bwrap --ro-bind / / --unshare-user --uid 0 --gid 0 true 2>/dev/null; then
  skip "user namespaces unavailable; skipping isolated Claude extension installation"
  exit 0
fi

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/share" "$test_tmp/bin"
installer="$ROOT/bin/omarchy-install-chromium-claude"
extension_id=fcoeoabgfenejglbffodgkkbkcdhcgfn
sandbox=(bwrap --ro-bind / / --bind "$test_tmp" "$test_tmp" --dev /dev --proc /proc --unshare-user)

"${sandbox[@]}" --uid 0 --gid 0 --bind "$test_tmp/share" /usr/share bash "$installer"
for browser in chromium google-chrome microsoft-edge; do
  file="$test_tmp/share/$browser/extensions/$extension_id.json"
  jq -e '.external_update_url == "https://clients2.google.com/service/update2/crx"' "$file" >/dev/null ||
    fail "$browser registers the official Claude Web Store extension"
  [[ $(stat -c '%a' "$file") == "644" ]] || fail "$browser extension registration is readable"
done
pass "Claude extension installer registers all supported browser families"

cat >"$test_tmp/bin/pkexec" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$AUTH_LOG"
exit 42
SH
chmod +x "$test_tmp/bin/pkexec"
export AUTH_LOG="$test_tmp/auth-log"
export PATH="$test_tmp/bin:$PATH"

# A read-only /usr/share and a failing auth stub prove that a repeated run
# neither rewrites the files nor requests authentication.
"${sandbox[@]}" --uid 1000 --gid 1000 --ro-bind "$test_tmp/share" /usr/share bash "$installer" </dev/null
[[ ! -e $AUTH_LOG ]] || fail "configured Claude extensions need no authentication"
pass "configured Claude extensions need neither writes nor authentication"

rm "$test_tmp/share/google-chrome/extensions/$extension_id.json"
status=0
"${sandbox[@]}" --uid 1000 --gid 1000 --ro-bind "$test_tmp/share" /usr/share bash "$installer" </dev/null || status=$?
[[ $status == 42 ]] || fail "Claude extension installer propagates authentication failure"
[[ $(cat "$AUTH_LOG") == "/usr/bin/omarchy-install-chromium-claude" ]] ||
  fail "menu installation elevates only the packaged installer"
pass "missing registration uses pkexec and propagates authentication failure"
