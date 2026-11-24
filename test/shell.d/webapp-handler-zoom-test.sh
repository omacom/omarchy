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

# [0-9] matches fullwidth and Arabic-Indic digits under a UTF-8 locale, so the
# handler spells the digits out instead of relying on a range.
assert_url "zoom handler refuses a fullwidth-digit meeting number" \
  'zoommtg://zoom.us/join?confno=１２３４５６７８' \
  'https://app.zoom.us/wc/home'

assert_url "zoom handler refuses an Arabic-Indic-digit meeting number" \
  'zoommtg://zoom.us/join?confno=١٢٣٤٥٦٧٨' \
  'https://app.zoom.us/wc/home'

assert_url "zoom handler refuses a meeting number longer than 20 digits" \
  'zoommtg://zoom.us/join?confno=123456789012345678901' \
  'https://app.zoom.us/wc/home'

# The handler URI-encodes the passcode while keeping existing percent escapes;
# "*" is not unreserved, so it becomes %2A and the decoded passcode is unchanged.
assert_url "zoom handler keeps a passcode with encoded characters" \
  'zoommtg://zoom.us/join?confno=123456789&pwd=ab*%3F9%2312' \
  'https://app.zoom.us/wc/join/123456789?pwd=ab%2A%3F9%2312'
