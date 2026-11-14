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

assert_url "zoom handler joins a numeric meeting with a URL-safe password" \
  'zoommtg://zoom.us/join?confno=123456789&pwd=abcDEF123' \
  'https://app.zoom.us/wc/join/123456789?pwd=abcDEF123'

assert_url "zoom handler joins a numeric meeting without a password" \
  'zoomus://zoom.us/join?confno=987654321' \
  'https://app.zoom.us/wc/join/987654321'

# The meeting number used to be pasted straight into the URL path, so a value
# with slashes or dots could leave the join page or open another path.
assert_url "zoom handler refuses a meeting number with path segments" \
  'zoommtg://zoom.us/join?confno=../../other-path/&pwd=abc' \
  'https://app.zoom.us/wc/home'

assert_url "zoom handler refuses a meeting number that opens a query string" \
  'zoommtg://zoom.us/join?confno=123?injected=1' \
  'https://app.zoom.us/wc/home'

assert_url "zoom handler refuses a meeting number with encoded separators" \
  'zoommtg://zoom.us/join?confno=123%26injected=1' \
  'https://app.zoom.us/wc/home'

# The password was appended to the query string verbatim. A value carrying a
# separator or an encoded one must not become another parameter.
assert_url "zoom handler keeps only the password before an extra separator" \
  'zoommtg://zoom.us/join?confno=123456789&pwd=abc&action=join' \
  'https://app.zoom.us/wc/join/123456789?pwd=abc'

assert_url "zoom handler drops a password with encoded separators" \
  'zoommtg://zoom.us/join?confno=123456789&pwd=abc%26injected=1' \
  'https://app.zoom.us/wc/join/123456789'

assert_url "zoom handler ignores a non-Zoom protocol" \
  'https://example.test/join?confno=123456789' \
  'https://app.zoom.us/wc/home'
