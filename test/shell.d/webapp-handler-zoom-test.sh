#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin"

cat >"$tmp_dir/bin/omarchy-launch-webapp" <<'STUB'
#!/bin/bash
printf '%s\n' "$1"
STUB
chmod +x "$tmp_dir/bin/omarchy-launch-webapp"

run_handler() {
  PATH="$tmp_dir/bin:$PATH" "$ROOT/bin/omarchy-webapp-handler-zoom" "$1"
}

assert_url() {
  local description=$1 url=$2 expected=$3 actual
  actual=$(run_handler "$url")
  [[ $actual == "$expected" ]] || fail "$description" "got: $actual"
  pass "$description"
}

assert_url "zoom handler joins a numeric meeting with a password" \
  'zoommtg://zoom.us/join?confno=123456789&pwd=abcDEF123' \
  'https://app.zoom.us/wc/join/123456789?pwd=abcDEF123'

# The meeting number used to be pasted straight into the URL path, so a value
# with slashes or a query separator changed which page opened.
assert_url "zoom handler refuses a meeting number with path segments" \
  'zoommtg://zoom.us/join?confno=../../other-path/&pwd=abc' \
  'https://app.zoom.us/wc/home'

assert_url "zoom handler refuses a meeting number that opens a query string" \
  'zoommtg://zoom.us/join?confno=123?injected=1' \
  'https://app.zoom.us/wc/home'

assert_url "zoom handler refuses a meeting number with encoded separators" \
  'zoommtg://zoom.us/join?confno=123%26injected=1' \
  'https://app.zoom.us/wc/home'

# Zoom passcodes may contain *, and ones with ? or # arrive percent-encoded;
# encoded, a separator is part of the value and never a new parameter, so a
# passcode is passed through instead of being matched against an allowlist.
assert_url "zoom handler keeps a passcode with * and encoded characters" \
  'zoommtg://zoom.us/join?confno=123456789&pwd=ab*%3F9%2312' \
  'https://app.zoom.us/wc/join/123456789?pwd=ab*%3F9%2312'
