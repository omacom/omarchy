#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command base64
require_command file
require_command id

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

home="$tmpdir/home"
mkdir -p "$home/.local/share/applications"

stubs="$tmpdir/stubs"
mkdir -p "$stubs"

# curl logs every invocation so a test can read the URL it was asked for.
# Page fetches carry no -o and answer with nothing, which sends the icon chain
# on to Google's favicon service; -o fetches write a real 1x1 PNG, which is
# what download_icon's mime check demands, unless the fail marker exists --
# that lets a test drive the chain all the way to its last resort.
cat >"$stubs/curl" <<'CURL'
#!/bin/bash
printf '%s\n' "$*" >>"$CURL_LOG"

out=
while (($#)); do
  case $1 in
    -o)
      out=$2
      shift 2
      ;;
    *)
      shift
      ;;
  esac
done

if [[ -n $out ]]; then
  if [[ -e $CURL_FAIL_MARKER ]]; then
    exit 1
  fi
  # A real 1x1 PNG: download_icon rejects anything libmagic does not call
  # image/*, so a shorter stand-in would fail the check this is meant to pass.
  printf '%s' 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==' |
    base64 -d >"$out"
fi
CURL

chmod +x "$stubs/curl"

install_webapp() {
  CURL_LOG="$tmpdir/curl-log" CURL_FAIL_MARKER="$tmpdir/fail-downloads" \
    PATH="$stubs:$PATH" HOME="$home" "$ROOT/bin/omarchy-webapp-install" "$@"
}

desktop_for() {
  printf '%s' "$home/.local/share/applications/$1.desktop"
}

# Pointing a web app at the machine in front of you is ordinary use, not an
# attack: Home Assistant on the LAN, a dev server on localhost, a NAS panel.
# Refusing those makes the command fail outright for the people it is for.
: >"$tmpdir/curl-log"

for url in "http://192.168.1.10:8123" "http://localhost:3000" "http://10.0.0.5/"; do
  if install_webapp "Local Web App" "$url" "" >"$tmpdir/out" 2>"$tmpdir/err"; then
    :
  else
    fail "webapp install fetches an icon from $url" "$(cat "$tmpdir/out" "$tmpdir/err")"
  fi

  desktop=$(desktop_for "Local Web App")
  [[ -e $desktop ]] || fail "webapp install writes a desktop entry for $url"
done
pass "webapp install fetches icons from LAN and localhost URLs"

grep -Fq -- '--max-redirs 3' "$tmpdir/curl-log" ||
  fail "the icon page fetch caps redirects" "$(cat "$tmpdir/curl-log")"
pass "the icon page fetch limits redirects"

# Nothing in the URL the user typed belongs to Google. Credentials, tokens and
# the port all stay here; the favicon service gets the hostname and nothing
# else, even though this is the path where the site's own downloads failed.
: >"$tmpdir/curl-log"
touch "$tmpdir/fail-downloads"

if install_webapp "Token App" "https://user:password@example.com:8443?token=SECRET_TOKEN" "" \
  >"$tmpdir/out" 2>"$tmpdir/err"; then
  fail "an install whose icon downloads fail reports the failure"
fi

google_line=$(grep -F 'google.com/s2/favicons' "$tmpdir/curl-log" || true)
[[ -n $google_line ]] ||
  fail "the icon chain reaches the Google fallback" "$(cat "$tmpdir/curl-log")"

[[ $google_line == *'domain=example.com&sz=256'* ]] ||
  fail "the Google fallback is built from the bare hostname" "$google_line"

for secret in user:password SECRET_TOKEN example.com:8443; do
  if [[ $google_line == *"$secret"* ]]; then
    fail "the Google fallback leaks '$secret'" "$google_line"
  fi
done

rm -f "$tmpdir/fail-downloads"
pass "the Google favicon fallback sends only the hostname"

# A query can hold an @ while no / precedes the ?, so the extraction has to
# cut the query before it strips userinfo. Stripping first, ##*@ being
# greedy, hands Google everything up to the last @ in the URL.
: >"$tmpdir/curl-log"
touch "$tmpdir/fail-downloads"

if install_webapp "Query App" "https://example.com?next=me@mail.example.org" "" \
  >"$tmpdir/out" 2>"$tmpdir/err"; then
  fail "an install whose icon downloads fail reports the failure"
fi

google_line=$(grep -F 'google.com/s2/favicons' "$tmpdir/curl-log" || true)
[[ -n $google_line ]] ||
  fail "the icon chain reaches the Google fallback for a query URL" "$(cat "$tmpdir/curl-log")"

[[ $google_line == *'domain=example.com&sz=256'* ]] ||
  fail "the Google fallback cuts the query before the userinfo" "$google_line"

if [[ $google_line == *'mail.example.org'* ]]; then
  fail "the Google fallback used an @ from the query as the userinfo delimiter" "$google_line"
fi

rm -f "$tmpdir/fail-downloads"
pass "the Google favicon fallback cuts the query before the userinfo"

# The same extraction has to survive a bracketed IPv6 host, where the port
# separator is ]: and not just the first colon inside the address.
: >"$tmpdir/curl-log"
touch "$tmpdir/fail-downloads"

if install_webapp "IPv6 App" "http://[::1]:8080" "" >"$tmpdir/out" 2>"$tmpdir/err"; then
  fail "an IPv6 install whose icon downloads fail reports the failure"
fi

google_line=$(grep -F 'google.com/s2/favicons' "$tmpdir/curl-log" || true)
[[ -n $google_line ]] ||
  fail "the icon chain reaches the Google fallback for an IPv6 host" "$(cat "$tmpdir/curl-log")"

[[ $google_line == *'domain=[::1]&sz=256'* ]] ||
  fail "the Google fallback keeps a bracketed IPv6 host intact" "$google_line"

rm -f "$tmpdir/fail-downloads"
pass "the Google favicon fallback keeps a bracketed IPv6 host intact"

# A hostname is data, never code. It used to be read into
# (( a >= 16 && a <= 31 )), where bash parses a hostname label as an array
# subscript and runs whatever the subscript contains.
: >"$tmpdir/curl-log"

if install_webapp "Hostile" 'http://172.x[$(id>&2)].example/' "" >"$tmpdir/out" 2>"$tmpdir/err"; then
  :
else
  fail "webapp install handles a hostname containing shell syntax" "$(cat "$tmpdir/out" "$tmpdir/err")"
fi

if grep -Fq 'uid=' "$tmpdir/out" "$tmpdir/err"; then
  fail "webapp install never evaluates the hostname as shell code" "$(cat "$tmpdir/err")"
fi
pass "webapp install leaves shell syntax in a hostname inert"
