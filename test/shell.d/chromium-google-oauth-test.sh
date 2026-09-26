#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

installer="$ROOT/bin/omarchy-install-chromium-google-account"
packaged_env="$ROOT/default/chromium/google-oauth.env"
tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

file_mode() {
  if stat -f %Lp "$1" >/dev/null 2>&1; then
    stat -f %Lp "$1"
  else
    stat -c %a "$1"
  fi
}

[[ -f $packaged_env ]] || fail "missing packaged Chromium Google OAuth env"
grep -Eq '^OAUTH2_CLIENT_ID=' "$packaged_env" || fail "packaged env missing OAUTH2_CLIENT_ID"
grep -Eq '^OAUTH2_CLIENT_SECRET=' "$packaged_env" || fail "packaged env missing OAUTH2_CLIENT_SECRET"

if grep -Eq 'OTJgUOQcT7lO7GsGZq2G4IlT|oauth2-client-secret=OTJg' "$installer"; then
  fail "installer still embeds the OAuth client secret"
fi
grep -Fq 'chromium-google-oauth.env' "$installer" ||
  fail "installer must load chromium-google-oauth.env"
grep -Fq 'chmod 600' "$installer" ||
  fail "installer must restrict chromium-flags.conf after writing the secret"
grep -Fq 'omarchy-refresh-chromium' "$installer" ||
  fail "missing-flags hint must point at omarchy-refresh-chromium"
grep -Fq "oauth2-client-(id|secret)" "$installer" ||
  fail "installer must clear prior OAuth flag lines before appending"
pass "OAuth credentials live in overrideable env files, not the installer"

mkdir -p "$tmpdir/config" "$tmpdir/share/omarchy/default/chromium"
cp "$packaged_env" "$tmpdir/share/omarchy/default/chromium/google-oauth.env"
: >"$tmpdir/config/chromium-flags.conf"

HOME="$tmpdir" XDG_CONFIG_HOME="$tmpdir/config" OMARCHY_PATH="$tmpdir/share/omarchy" \
  "$installer"

grep -Fq -- '--oauth2-client-id=77185425430.apps.googleusercontent.com' \
  "$tmpdir/config/chromium-flags.conf" || fail "client id was not written"
grep -Fq -- '--oauth2-client-secret=OTJgUOQcT7lO7GsGZq2G4IlT' \
  "$tmpdir/config/chromium-flags.conf" || fail "client secret was not written"
[[ $(file_mode "$tmpdir/config/chromium-flags.conf") == 600 ]] ||
  fail "chromium-flags.conf must be mode 600 after writing secrets"
pass "installer writes OAuth flags from the packaged env and tightens mode"

mkdir -p "$tmpdir/config/omarchy"
cat >"$tmpdir/config/omarchy/chromium-google-oauth.env" <<'EOF'
OAUTH2_CLIENT_ID=override-id.apps.googleusercontent.com
OAUTH2_CLIENT_SECRET=override-secret
EOF
: >"$tmpdir/config/chromium-flags.conf"

HOME="$tmpdir" XDG_CONFIG_HOME="$tmpdir/config" OMARCHY_PATH="$tmpdir/share/omarchy" \
  "$installer"

grep -Fq -- '--oauth2-client-id=override-id.apps.googleusercontent.com' \
  "$tmpdir/config/chromium-flags.conf" || fail "user drop-in client id was ignored"
grep -Fq -- '--oauth2-client-secret=override-secret' \
  "$tmpdir/config/chromium-flags.conf" || fail "user drop-in client secret was ignored"
pass "user chromium-google-oauth.env overrides packaged defaults"

# Re-run with the packaged defaults without truncating the flags file: prior
# override lines must be replaced, not left as earlier occurrences Chromium ignores.
rm -f "$tmpdir/config/omarchy/chromium-google-oauth.env"
HOME="$tmpdir" XDG_CONFIG_HOME="$tmpdir/config" OMARCHY_PATH="$tmpdir/share/omarchy" \
  "$installer"

grep -Fq -- '--oauth2-client-id=77185425430.apps.googleusercontent.com' \
  "$tmpdir/config/chromium-flags.conf" || fail "re-run did not restore packaged client id"
grep -Fq -- '--oauth2-client-secret=OTJgUOQcT7lO7GsGZq2G4IlT' \
  "$tmpdir/config/chromium-flags.conf" || fail "re-run did not restore packaged client secret"
if grep -Fq -- '--oauth2-client-id=override-id.apps.googleusercontent.com' \
  "$tmpdir/config/chromium-flags.conf"; then
  fail "re-run left the previous override client id in chromium-flags.conf"
fi
if grep -Fq -- '--oauth2-client-secret=override-secret' \
  "$tmpdir/config/chromium-flags.conf"; then
  fail "re-run left the previous override secret in chromium-flags.conf"
fi
pass "re-run replaces prior OAuth flag lines when credentials change"
