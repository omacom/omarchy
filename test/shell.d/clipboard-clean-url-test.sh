#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

stub=$(mktemp -d)
trap 'rm -rf "$stub"' EXIT

cat >"$stub/wl-copy" <<'EOF'
#!/bin/bash
cat >"$CLEAN_URL_COPY"
EOF
cat >"$stub/wl-paste" <<'EOF'
#!/bin/bash
exit 1
EOF
cat >"$stub/omarchy-notification-send" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$CLEAN_URL_NOTIFY"
EOF
chmod +x "$stub/wl-copy" "$stub/wl-paste" "$stub/omarchy-notification-send"

export PATH="$stub:$PATH"
export CLEAN_URL_COPY="$stub/copied"
export CLEAN_URL_NOTIFY="$stub/notified"
: >"$CLEAN_URL_NOTIFY"

clean=$ROOT/bin/omarchy-clipboard-clean-url

cafe=$(printf 'https://example.com/caf\303\251?utm_source=x&id=1')
expected=$(printf 'https://example.com/caf\303\251?id=1')
got=$("$clean" "$cafe")
[[ $got == "$expected" ]] || fail "non-ascii path is left as bytes" "got [$got]"
pass "non-ascii path is left as bytes"

got=$("$clean" "https://example.com/a?utm_source=x&id=1")
[[ $got == "https://example.com/a?id=1" ]] || fail "tracking params are dropped" "got [$got]"
pass "tracking params are dropped"

if "$clean" --copy "https://"; then
  fail "a bare scheme is rejected"
fi
grep -q "Link not cleaned" "$CLEAN_URL_NOTIFY" || fail "a rejected --copy notifies"
pass "a bare scheme is rejected"

: >"$CLEAN_URL_NOTIFY"
if "$clean" --copy "https://not a url"; then
  fail "a link with a space is rejected"
fi
grep -q "Link not cleaned" "$CLEAN_URL_NOTIFY" || fail "a spaced link notifies"
pass "a link with a space is rejected"

: >"$CLEAN_URL_NOTIFY"
"$clean" --copy "https://example.com/a?utm_source=x" >/dev/null
[[ $(cat "$CLEAN_URL_COPY") == "https://example.com/a" ]] || fail "copy writes the cleaned link"
grep -q "Link cleaned" "$CLEAN_URL_NOTIFY" || fail "copy reports success"
pass "copy writes the cleaned link and reports it"

: >"$CLEAN_URL_NOTIFY"
if "$clean" --copy; then
  fail "an empty clipboard is rejected"
fi
grep -q "No URL on the clipboard" "$CLEAN_URL_NOTIFY" || fail "an empty clipboard notifies"
pass "an empty clipboard notifies"
