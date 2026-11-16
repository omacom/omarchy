#!/bin/bash

set -euo pipefail

# Support pastes go to an unauthenticated URL. The scrubber has to drop
# credential-like values and leave ordinary diagnostic text in place, and the
# boot upload has to default to warnings and errors.

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command gawk

tmp=$(mktemp -d)
debug_log=/tmp/omarchy-debug.log
debug_backup=$(mktemp)
had_debug_log=false
if [[ -e $debug_log ]]; then
  had_debug_log=true
  cp -a "$debug_log" "$debug_backup"
fi
cleanup() {
  if [[ $had_debug_log == "true" ]]; then
    cp -a "$debug_backup" "$debug_log"
  else
    rm -f "$debug_log"
  fi
  rm -rf "$tmp"
  rm -f "$debug_backup"
}
trap cleanup EXIT

mkdir -p "$tmp/bin" "$tmp/work"

cat >"$tmp/bin/curl" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$CURL_LOG"
for arg in "$@"; do
  if [[ $arg == file=@* ]]; then
    cp "${arg#file=@}" "$CURL_CAPTURE"
  fi
done
printf '%s\n' "https://logs.omarchy.org/test-paste"
EOF

cat >"$tmp/bin/journalctl" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >"$JOURNAL_ARGS"
cat <<'LOG'
started fine
fetched https://internal.corp/secret/path?token=abc123&ok=1
Failed password for user from 1.2.3.4
https://user:s3cret@github.com/acme/repo.git
LOG
EOF

cat >"$tmp/bin/omarchy-cmd-present" <<'EOF'
#!/bin/bash
exit 1
EOF

cat >"$tmp/bin/sudo" <<'EOF'
#!/bin/bash
printf '%s\n' "sudo-dmesg"
EOF

cat >"$tmp/bin/inxi" <<'EOF'
#!/bin/bash
printf '%s\n' "Machine: stub"
EOF

cat >"$tmp/bin/pacman" <<'EOF'
#!/bin/bash
exit 0
EOF

cat >"$tmp/bin/expac" <<'EOF'
#!/bin/bash
exit 0
EOF

cat >"$tmp/bin/ping" <<'EOF'
#!/bin/bash
exit 0
EOF

cat >"$tmp/bin/gum" <<'EOF'
#!/bin/bash
printf '%s\n' "Upload log"
EOF

chmod +x "$tmp/bin/"*

export CURL_LOG="$tmp/curl-args"
export CURL_CAPTURE="$tmp/uploaded"
export JOURNAL_ARGS="$tmp/journal-args"

assert_contains() {
  local file=$1 needle=$2 description=$3
  grep -qF -- "$needle" "$file" || fail "$description" "$(cat "$file")"
}

assert_absent() {
  local file=$1 needle=$2 description=$3
  grep -qF -- "$needle" "$file" && fail "$description" "$(cat "$file")" || true
}

sample=$tmp/sample.txt
redacted=$tmp/sample.redacted
cat >"$sample" <<'EOF'
plain https://github.com/omacom/omarchy stays
https://user:s3cret@github.com/acme/repo.git
fetched https://internal.corp/secret/path?token=abc123&ok=1
Authorization: Bearer eyJhbGciOiJIUzI1NiJ9.payload.sig
Authorization: Basic dXNlcjpwYXNz
"password": "hunter2"
"!password": "disk-secret"
"encryption_password": "luks-secret"
"password_store": "gnome-libsecret"
'password': 'archinstall-secret'
"password": "a\"remaining-secret"
'password': 'a\'tail-secret'
Failed password for user from 1.2.3.4
password authentication failed
sudo: justin : PWD=/home/justin ; USER=root ; COMMAND=/usr/bin/true
"pwd": "quoted-pwd-secret"
psk=supersecretwifi
psk="supersecretwifi"
psk="wifi-secret" token=later-token-value
token='quoted-token-value'
password="secret with spaces"
password_store="gnome-libsecret"
PrivateKey = aGVsbG8td29ybGQtaGVsbG8td29ybGQtaGVsbG8td29y
ghp_abcdefghijklmnopqrstuvwxyz123456
npm_1234567890abcdef1234567890abcdef1234
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAA
-----END OPENSSH PRIVATE KEY-----
https://example.com:8443/path
boot 0001 ok
EOF

count=$("$ROOT/bin/omarchy-upload-log" --redact "$sample" "$redacted")
(( count > 0 )) || fail "redaction reports how many values it removed" "$count"
assert_contains "$redacted" "https://github.com/omacom/omarchy stays" "a normal repository URL stays"
assert_contains "$redacted" "https://[REDACTED]@github.com/acme/repo.git" "URL userinfo is removed"
assert_contains "$redacted" "token=[REDACTED]&ok=1" "a query token is removed and the rest of the URL stays"
assert_contains "$redacted" "Authorization: Bearer [REDACTED]" "a bearer token is removed"
assert_contains "$redacted" "Authorization: Basic [REDACTED]" "basic auth material is removed"
assert_contains "$redacted" '"password": "[REDACTED]"' "a JSON password is removed"
assert_contains "$redacted" '"!password": "[REDACTED]"' "an install config password is removed"
assert_contains "$redacted" '"encryption_password": "[REDACTED]"' "a disk encryption password is removed"
assert_absent "$redacted" "disk-secret" "the install config password value is gone"
assert_absent "$redacted" "luks-secret" "the disk encryption password value is gone"
assert_contains "$redacted" '"password_store": "gnome-libsecret"' "a password-store setting is not a secret"
assert_contains "$redacted" "'password': '[REDACTED]'" "an install-log password is removed"
assert_absent "$redacted" "remaining-secret" "an escaped quote does not leave the rest of a JSON password"
assert_absent "$redacted" "tail-secret" "an escaped quote does not leave the rest of a single-quoted password"
assert_contains "$redacted" "Failed password for user from 1.2.3.4" "an sshd failure line stays"
assert_contains "$redacted" "password authentication failed" "a failure sentence stays"
assert_contains "$redacted" "PWD=/home/justin ; USER=root ; COMMAND=/usr/bin/true" "a sudo working directory is not a password"
assert_contains "$redacted" '"pwd": "[REDACTED]"' "a quoted pwd key is removed"
assert_absent "$redacted" "quoted-pwd-secret" "a quoted pwd value is gone"
assert_contains "$redacted" "psk=[REDACTED]" "a Wi-Fi PSK is removed"
assert_absent "$redacted" "supersecretwifi" "a quoted Wi-Fi PSK is removed"
assert_absent "$redacted" "wifi-secret" "a quoted PSK beside another assignment is removed"
assert_absent "$redacted" "later-token-value" "an unquoted token after a quoted assignment is removed"
assert_contains "$redacted" "token=[REDACTED]" "a single-quoted token is removed"
assert_absent "$redacted" "quoted-token-value" "a single-quoted token value is gone"
assert_absent "$redacted" "secret with spaces" "a quoted password keeps its spaces inside the match"
assert_contains "$redacted" 'password_store="gnome-libsecret"' "a quoted password-store setting is not a secret"
assert_contains "$redacted" "PrivateKey=[REDACTED]" "a WireGuard private key is removed"
assert_absent "$redacted" "ghp_abcdefghijklmnopqrstuvwxyz123456" "a GitHub token is removed"
assert_absent "$redacted" "npm_1234567890abcdef1234567890abcdef1234" "an npm token is removed"
assert_absent "$redacted" "b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAAA" "a private key body is removed"
assert_contains "$redacted" "-----BEGIN OPENSSH PRIVATE KEY-----" "a private key header marks that a key was present"
assert_contains "$redacted" "https://example.com:8443/path" "a port is not treated as userinfo"
assert_contains "$redacted" "boot 0001 ok" "digits are not treated as secrets"
cmp -s "$sample" "$redacted" && fail "redaction changes the sample" || true
pass "credential-like values are removed and diagnostic text stays"

output=$("$ROOT/bin/omarchy-upload-log" --redact "$tmp/missing" "$tmp/nowhere" 2>&1) &&
  fail "redact refuses a missing file" "$output"
[[ -e $tmp/nowhere ]] && fail "redact does not create a destination for a missing file"
pass "redact refuses a missing file"

output=$("$ROOT/bin/omarchy-upload-log" --redact "$sample" 2>&1) &&
  fail "redact requires a destination" "$output"
pass "redact requires a destination"

run_upload() {
  PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-upload-log" "$@"
}

PATH="$tmp/bin:$PATH"
[[ $(command -v curl) == "$tmp/bin/curl" ]] || fail "curl stub is first on PATH"
[[ $(command -v journalctl) == "$tmp/bin/journalctl" ]] || fail "journalctl stub is first on PATH"

: >"$CURL_LOG"
rm -f "$CURL_CAPTURE" "$JOURNAL_ARGS"
output=$(run_upload this-boot)
[[ $(cat "$JOURNAL_ARGS") == "-b 0 -p warning --no-pager" ]] ||
  fail "this-boot asks journalctl for warnings and errors" "$(cat "$JOURNAL_ARGS")"
assert_absent "$CURL_CAPTURE" "abc123" "the uploaded boot log does not contain the query token"
assert_absent "$CURL_CAPTURE" "user:s3cret" "the uploaded boot log does not contain URL userinfo"
assert_contains "$CURL_CAPTURE" "started fine" "the uploaded boot log keeps ordinary lines"
assert_contains "$CURL_CAPTURE" "Failed password for user from 1.2.3.4" "the uploaded boot log keeps sshd failures"
grep -q "logs.omarchy.org" "$CURL_LOG" || fail "the upload posts to logs.omarchy.org" "$(cat "$CURL_LOG")"
grep -q "public for 24 hours" <<<"$output" || fail "the upload says the paste is public" "$output"
grep -q "warnings and errors" <<<"$output" || fail "the upload names the default scope" "$output"
grep -q "Removed" <<<"$output" || fail "the upload reports that values were removed" "$output"
pass "this-boot uploads a redacted warning journal"

: >"$CURL_LOG"
rm -f "$CURL_CAPTURE" "$JOURNAL_ARGS"
output=$(run_upload --full this-boot)
[[ $(cat "$JOURNAL_ARGS") == "-b 0 --no-pager" ]] ||
  fail "--full asks for the complete boot journal" "$(cat "$JOURNAL_ARGS")"
assert_absent "$CURL_CAPTURE" "abc123" "--full still removes the query token"
grep -q "complete boot journal" <<<"$output" || fail "--full names its scope" "$output"
pass "--full uploads the complete journal with the same redaction"

rm -f "$JOURNAL_ARGS"
run_upload last-boot >/dev/null
[[ $(cat "$JOURNAL_ARGS") == "-b -1 -p warning --no-pager" ]] ||
  fail "last-boot asks journalctl for warnings and errors" "$(cat "$JOURNAL_ARGS")"
pass "last-boot uses the same warning scope"

cat >"$tmp/bin/mv" <<'EOF'
#!/bin/bash
printf '%s\n' "mv refused" >&2
exit 1
EOF
chmod +x "$tmp/bin/mv"
: >"$CURL_LOG"
rm -f "$CURL_CAPTURE"
if output=$(run_upload this-boot 2>&1); then
  fail "a failed replacement does not upload" "$output"
fi
[[ -e $CURL_CAPTURE ]] && fail "a failed replacement does not post the log" "$(cat "$CURL_CAPTURE")"
grep -q "failed to replace the log" <<<"$output" || fail "a failed replacement reports the error" "$output"
grep -q "Removed" <<<"$output" && fail "a failed replacement does not claim values were removed" "$output" || true
pass "a failed replacement does not upload the original log"
rm -f "$tmp/bin/mv"

# omarchy-debug writes a fixed path. Restore whatever was there on the way out.
: >"$CURL_LOG"
rm -f "$CURL_CAPTURE" "$JOURNAL_ARGS"
output=$(PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-debug")
assert_contains "$debug_log" "token=abc123" "the local debug log keeps the query token"
assert_contains "$debug_log" "user:s3cret" "the local debug log keeps URL userinfo"
assert_absent "$CURL_CAPTURE" "abc123" "the uploaded debug log removes the query token"
assert_absent "$CURL_CAPTURE" "user:s3cret" "the uploaded debug log removes URL userinfo"
assert_contains "$CURL_CAPTURE" "started fine" "the uploaded debug log keeps ordinary lines"
grep -q "file=@$debug_log" "$CURL_LOG" && fail "debug does not upload the local log path" "$(cat "$CURL_LOG")" || true
grep -q "local log is unchanged" <<<"$output" || fail "debug says the local log is unchanged" "$output"
grep -q "public for 24 hours" <<<"$output" || fail "debug says the paste is public" "$output"
[[ $(stat -c '%a' "$debug_log") == "600" ]] || fail "the local debug log is not world-readable" "$(stat -c '%a' "$debug_log")"
pass "omarchy-debug uploads a redacted copy and leaves the local log intact"
