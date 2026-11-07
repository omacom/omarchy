#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
server_pid=""
cleanup() {
  if [[ -n $server_pid ]] && kill -0 "$server_pid" 2>/dev/null; then
    kill "$server_pid" 2>/dev/null || true
    wait "$server_pid" 2>/dev/null || true
  fi
  rm -rf "$tmpdir"
}
trap cleanup EXIT

home="$tmpdir/home"
mkdir -p "$home/.local/share/applications"

install_webapp() {
  HOME="$home" PATH="$ROOT/bin:$PATH" "$ROOT/bin/omarchy-webapp-install" "$@"
}

desktop_for() {
  printf '%s' "$home/.local/share/applications/$1.desktop"
}

if install_webapp "Example" "https://example.com" "webapp" >"$tmpdir/out" 2>"$tmpdir/err"; then
  :
else
  fail "webapp install accepts an https URL" "$(cat "$tmpdir/err")"
fi

desktop=$(desktop_for Example)
[[ -f $desktop ]] || fail "webapp install writes a desktop file"
grep -Fxq 'Name=Example' "$desktop" || fail "webapp install writes the app name"
grep -Fxq 'Exec=omarchy-launch-webapp "https://example.com"' "$desktop" ||
  fail "webapp install launches the https URL" "$(cat "$desktop")"
pass "webapp install writes an https desktop entry"

grep -Fxq 'StartupWMClass=chrome-example.com__-Default' "$desktop" ||
  fail "webapp install names the window Chromium opens" "$(cat "$desktop")"
pass "webapp install names the window Chromium opens, so titlebars can show the app's name"

for case in \
  "https://web.whatsapp.com/|chrome-web.whatsapp.com__-Default" \
  "https://maps.google.com|chrome-maps.google.com__-Default" \
  "https://discord.com/channels/@me|chrome-discord.com__channels_@me-Default" \
  "https://Example.com:8443/a/b?x=1#y|chrome-example.com__a_b-Default"; do
  [[ $("$ROOT/bin/omarchy-webapp-window-class" "${case%%|*}") == "${case#*|}" ]] ||
    fail "the window class of ${case%%|*} is ${case#*|}" "$("$ROOT/bin/omarchy-webapp-window-class" "${case%%|*}")"
done
pass "web app window classes follow Chromium's host and path naming"

if install_webapp "Plain" "example.org/app" "webapp" >"$tmpdir/out" 2>"$tmpdir/err"; then
  :
else
  fail "webapp install prefixes a schemeless URL with https" "$(cat "$tmpdir/err")"
fi
grep -Fxq 'Exec=omarchy-launch-webapp "https://example.org/app"' "$(desktop_for Plain)" ||
  fail "webapp install stores the prefixed https URL" "$(cat "$(desktop_for Plain)")"
pass "webapp install prefixes a schemeless URL with https"

if install_webapp "Local" "https://localhost:47990" "webapp" "omarchy-launch-webapp https://localhost:47990 --ignore-certificate-errors" >"$tmpdir/out" 2>"$tmpdir/err"; then
  :
else
  fail "webapp install keeps a custom https exec" "$(cat "$tmpdir/err")"
fi
grep -Fxq 'Exec=omarchy-launch-webapp https://localhost:47990 --ignore-certificate-errors' "$(desktop_for Local)" ||
  fail "webapp install writes the custom exec" "$(cat "$(desktop_for Local)")"
grep -Fxq 'StartupWMClass=chrome-localhost__-Default' "$(desktop_for Local)" ||
  fail "a custom exec still names its window after the URL it opens" "$(cat "$(desktop_for Local)")"
pass "webapp install keeps a custom https exec"

for url in "javascript:alert(1)" "file:///etc/passwd" "data:text/html,hi" "ftp://example.com" "ext://x"; do
  if install_webapp "Bad" "$url" "webapp" >"$tmpdir/out" 2>"$tmpdir/err"; then
    fail "webapp install refuses '$url'"
  fi
  grep -Fq 'must be http or https' "$tmpdir/err" ||
    fail "webapp install names the scheme refusal for '$url'" "$(cat "$tmpdir/err")"
  [[ ! -e $(desktop_for Bad) ]] || fail "webapp install does not write a desktop file for '$url'"
done
pass "webapp install refuses non-http(s) URLs"

# Raw whitespace is not valid URL data, and before Exec argument quoting it
# split browser flags or additional URLs into separate arguments.
for url in \
  " javascript:alert(1)" \
  " file:///etc/passwd" \
  "https://example.com data:text/html,hi" \
  "https://example.com/ --user-agent=INJECTION_PROOF_MARKER_12345"; do
  if install_webapp "Sneak" "$url" "webapp" >"$tmpdir/out" 2>"$tmpdir/err"; then
    fail "webapp install refuses whitespace in '$url'" "$(cat "$(desktop_for Sneak)")"
  fi
  grep -Fq 'must not contain whitespace' "$tmpdir/err" ||
    fail "webapp install names the whitespace refusal for '$url'" "$(cat "$tmpdir/err")"
  [[ ! -e $(desktop_for Sneak) ]] || fail "webapp install writes no desktop file for '$url'"
done
pass "webapp install refuses a URL carrying whitespace"

# Schemes are case-insensitive, and HTTPS://example.com installed before the
# scheme test existed.
if install_webapp "Upper" "HTTPS://example.com" "webapp" >"$tmpdir/out" 2>"$tmpdir/err"; then
  :
else
  fail "webapp install accepts an uppercase scheme" "$(cat "$tmpdir/err")"
fi
grep -Fxq 'Exec=omarchy-launch-webapp "HTTPS://example.com"' "$(desktop_for Upper)" ||
  fail "webapp install keeps the uppercase scheme" "$(cat "$(desktop_for Upper)")"
pass "webapp install accepts an uppercase http scheme"

# The interactive prompt fetches the site's icon, so a refused URL must be
# refused before anything dereferences it.
stubs="$tmpdir/stubs"
mkdir -p "$stubs"

cat >"$stubs/gum" <<'GUM'
#!/bin/bash
count=$(cat "$GUM_COUNT" 2>/dev/null || echo 0)
count=$((count + 1))
printf '%s\n' "$count" >"$GUM_COUNT"
sed -n "${count}p" "$GUM_ANSWERS"
GUM

cat >"$stubs/curl" <<'CURL'
#!/bin/bash
printf '%s\n' "$*" >>"$CURL_LOG"
exit 1
CURL

chmod +x "$stubs/gum" "$stubs/curl"

printf 'Evil\nfile:///etc/passwd\n' >"$tmpdir/answers"
: >"$tmpdir/gum-count"
: >"$tmpdir/curl-log"

if GUM_ANSWERS="$tmpdir/answers" GUM_COUNT="$tmpdir/gum-count" CURL_LOG="$tmpdir/curl-log" \
  PATH="$stubs:$PATH" HOME="$home" "$ROOT/bin/omarchy-webapp-install" \
  >"$tmpdir/out" 2>"$tmpdir/err"; then
  fail "interactive webapp install refuses a file: URL" "$(cat "$tmpdir/out")"
fi
grep -Fq 'must be http or https' "$tmpdir/err" ||
  fail "interactive webapp install names the scheme refusal" "$(cat "$tmpdir/err")"
[[ ! -s $tmpdir/curl-log ]] ||
  fail "interactive webapp install refuses before fetching the URL" "$(cat "$tmpdir/curl-log")"
[[ ! -e $(desktop_for Evil) ]] || fail "interactive webapp install writes no desktop file"
pass "interactive webapp install refuses a bad URL before fetching it"

cat >"$stubs/curl" <<'CURL'
#!/bin/bash
output=""
write_out=""
url=""
status=200
redirect=""
write_body() {
  if [[ $output == "-" ]]; then
    printf '%s' "$1"
  else
    printf '%s' "$1" >"$output"
  fi
}
while (( $# > 0 )); do
  case "$1" in
  -o)
    output=$2
    shift 2
    ;;
  -w)
    write_out=$2
    shift 2
    ;;
  http://* | https://*)
    url=$1
    shift
    ;;
  *) shift ;;
  esac
done

printf '%s\n' "$url" >>"$CURL_LOG"
if [[ $url == "https://example.com/app" ]]; then
  write_body $'<link rel="apple-touch-icon" href="http://127.0.0.1/private-action">\n'
elif [[ $url == "https://example.com/default-port" ]]; then
  write_body $'<link rel="apple-touch-icon" href="https://example.com:443/icon.png">\n'
elif [[ $url == "https://example.com:443/icon.png" ]]; then
  write_body 'image'
elif [[ $url == "http://[::1]/app" ]]; then
  write_body $'<link rel="apple-touch-icon" href="/ipv6-icon.png">\n'
elif [[ $url == "http://[::1]/ipv6-icon.png" ]]; then
  write_body 'image'
elif [[ $url == "https://User:Secret@example.com/credentialed" ]]; then
  write_body $'<link rel="apple-touch-icon" href="/credentialed-icon.png">\n'
elif [[ $url == "https://User:Secret@example.com/credentialed-icon.png" ]]; then
  write_body 'image'
elif [[ $url == "https://User:Secret@example.com/credentialed-redirect" ]]; then
  status=302
  redirect="https://example.com/after-credentialed-redirect"
elif [[ $url == "https://User:Secret@example.com/after-credentialed-redirect" ]]; then
  write_body $'<link rel="apple-touch-icon" href="/redirected-credentialed-icon.png">\n'
elif [[ $url == "https://User:Secret@example.com/redirected-credentialed-icon.png" ]]; then
  write_body 'image'
elif [[ $url == "https://User:Secret@example.com/credentialed-default-port-redirect" ]]; then
  status=302
  redirect="https://example.com:443/after-default-port-redirect"
elif [[ $url == "https://User:Secret@example.com:443/after-default-port-redirect" ]]; then
  write_body $'<link rel="apple-touch-icon" href="/default-port-credential-icon.png">\n'
elif [[ $url == "https://User:Secret@example.com:443/default-port-credential-icon.png" ]]; then
  write_body 'image'
elif [[ $url == "https://User:Secret@example.com/credentialed-www-redirect" ]]; then
  status=302
  redirect="https://www.example.com/no-credentials"
elif [[ $url == "https://www.example.com/no-credentials" ]]; then
  write_body $'<link rel="apple-touch-icon" href="/anonymous-icon.png">\n'
elif [[ $url == "https://www.example.com/anonymous-icon.png" ]]; then
  write_body 'image'
elif [[ $url == "https://User:Secret@example.com/credentialed-port-redirect" ]]; then
  status=302
  redirect="https://example.com:8443/no-credentials"
elif [[ $url == "https://example.com:8443/no-credentials" ]]; then
  write_body $'<link rel="apple-touch-icon" href="/port-icon.png">\n'
elif [[ $url == "https://example.com:8443/port-icon.png" ]]; then
  write_body 'image'
elif [[ $url == "http://User:Secret@example.com/credentialed-upgrade" ]]; then
  status=302
  redirect="https://example.com/no-upgrade-credentials"
elif [[ $url == "https://example.com/no-upgrade-credentials" ]]; then
  write_body $'<link rel="apple-touch-icon" href="/upgrade-icon.png">\n'
elif [[ $url == "https://example.com/upgrade-icon.png" ]]; then
  write_body 'image'
elif [[ $url == "https://example.com/www-redirect" ]]; then
  status=302
  redirect="https://www.example.com/apps/demo/"
elif [[ $url == "https://www.example.com/apps/demo/" ]]; then
  write_body $'<link rel="apple-touch-icon" href="icon.png">\n'
elif [[ $url == "https://www.example.com/apps/demo/icon.png" ]]; then
  write_body 'image'
elif [[ $url == "https://example.com/downgrade" ]]; then
  status=302
  redirect="http://example.com/insecure"
elif [[ $url == "https://www.127.0.0.1/page" ]]; then
  status=302
  redirect="https://127.0.0.1/private-page"
elif [[ $url == "https://www.127.0.0.1/apple-touch-icon.png" ]]; then
  write_body 'image'
elif [[ $url == "https://example.com/apple-touch-icon.png" ]]; then
  write_body 'image'
else
  exit 22
fi

if [[ -n $write_out ]]; then
  if [[ $write_out == *'%{stderr}'* ]]; then
    printf '%s\n%s\n' "$status" "$redirect" >&2
  else
    printf '%s\n%s\n' "$status" "$redirect"
  fi
fi
CURL

cat >"$stubs/file" <<'FILE'
#!/bin/bash
printf '%s\n' image/png
FILE

chmod +x "$stubs/curl" "$stubs/file"
: >"$tmpdir/curl-log"

if CURL_LOG="$tmpdir/curl-log" PATH="$stubs:$ROOT/bin:/usr/bin:/bin" HOME="$home" \
  "$ROOT/bin/omarchy-webapp-install" "Steered" "https://example.com/app" "" \
  >"$tmpdir/out" 2>"$tmpdir/err"; then
  :
else
  fail "webapp install falls back to a same-origin icon" "$(cat "$tmpdir/err")"
fi

grep -Fxq 'https://example.com/apple-touch-icon.png' "$tmpdir/curl-log" ||
  fail "webapp install tries the site's same-origin default icon" "$(cat "$tmpdir/curl-log")"
if grep -Fq '127.0.0.1' "$tmpdir/curl-log"; then
  fail "webapp install does not follow a page-provided icon to another origin" "$(cat "$tmpdir/curl-log")"
fi
pass "webapp install keeps automatic icon requests on the selected site's origin"

: >"$tmpdir/curl-log"
if CURL_LOG="$tmpdir/curl-log" PATH="$stubs:$ROOT/bin:/usr/bin:/bin" HOME="$home" \
  "$ROOT/bin/omarchy-webapp-install" "DefaultPort" "https://example.com/default-port" "" \
  >"$tmpdir/out" 2>"$tmpdir/err"; then
  :
else
  fail "webapp install accepts an explicit default port on a same-origin icon" "$(cat "$tmpdir/err")"
fi
grep -Fxq 'https://example.com:443/icon.png' "$tmpdir/curl-log" ||
  fail "webapp install normalizes default ports for origin comparison" "$(cat "$tmpdir/curl-log")"
pass "webapp install treats an explicit default port as the same origin"

: >"$tmpdir/curl-log"
if CURL_LOG="$tmpdir/curl-log" PATH="$stubs:$ROOT/bin:/usr/bin:/bin" HOME="$home" \
  "$ROOT/bin/omarchy-webapp-install" "IPv6" "http://[::1]/app" "" \
  >"$tmpdir/out" 2>"$tmpdir/err"; then
  :
else
  fail "webapp install keeps automatic IPv6 icons on their origin" "$(cat "$tmpdir/err" "$tmpdir/curl-log")"
fi
grep -Fxq 'http://[::1]/ipv6-icon.png' "$tmpdir/curl-log" ||
  fail "webapp install requests a same-origin IPv6 icon" "$(cat "$tmpdir/curl-log")"
pass "webapp install compares IPv6 origins literally"

: >"$tmpdir/curl-log"
if CURL_LOG="$tmpdir/curl-log" PATH="$stubs:$ROOT/bin:/usr/bin:/bin" HOME="$home" \
  "$ROOT/bin/omarchy-webapp-install" "Credentialed" "https://User:Secret@example.com/credentialed" "" \
  >"$tmpdir/out" 2>"$tmpdir/err"; then
  :
else
  fail "webapp install fetches an icon for a credentialed URL" "$(cat "$tmpdir/err")"
fi
grep -Fxq 'https://User:Secret@example.com/credentialed-icon.png' "$tmpdir/curl-log" ||
  fail "webapp install preserves credentials when constructing relative icon URLs" "$(cat "$tmpdir/curl-log")"
pass "webapp install preserves URL credentials in automatic icon requests"

: >"$tmpdir/curl-log"
if CURL_LOG="$tmpdir/curl-log" PATH="$stubs:$ROOT/bin:/usr/bin:/bin" HOME="$home" \
  "$ROOT/bin/omarchy-webapp-install" "CredentialedRedirect" \
  "https://User:Secret@example.com/credentialed-redirect" "" \
  >"$tmpdir/out" 2>"$tmpdir/err"; then
  :
else
  fail "webapp install keeps credentials through a same-host page redirect" "$(cat "$tmpdir/err" "$tmpdir/curl-log")"
fi
grep -Fxq 'https://User:Secret@example.com/after-credentialed-redirect' "$tmpdir/curl-log" ||
  fail "webapp install carries credentials to a same-host redirect" "$(cat "$tmpdir/curl-log")"
grep -Fxq 'https://User:Secret@example.com/redirected-credentialed-icon.png' "$tmpdir/curl-log" ||
  fail "webapp install resolves icons from the credentialed final page" "$(cat "$tmpdir/curl-log")"
pass "webapp install preserves credentials across same-host page redirects"

: >"$tmpdir/curl-log"
if CURL_LOG="$tmpdir/curl-log" PATH="$stubs:$ROOT/bin:/usr/bin:/bin" HOME="$home" \
  "$ROOT/bin/omarchy-webapp-install" "CredentialedDefaultPort" \
  "https://User:Secret@example.com/credentialed-default-port-redirect" "" \
  >"$tmpdir/out" 2>"$tmpdir/err"; then
  :
else
  fail "webapp install keeps credentials through an explicit default port" "$(cat "$tmpdir/err" "$tmpdir/curl-log")"
fi
grep -Fxq 'https://User:Secret@example.com:443/after-default-port-redirect' "$tmpdir/curl-log" ||
  fail "webapp install normalizes the default port before carrying credentials" "$(cat "$tmpdir/curl-log")"
pass "webapp install preserves credentials within the canonical origin"

: >"$tmpdir/curl-log"
if CURL_LOG="$tmpdir/curl-log" PATH="$stubs:$ROOT/bin:/usr/bin:/bin" HOME="$home" \
  "$ROOT/bin/omarchy-webapp-install" "CredentialBoundary" \
  "https://User:Secret@example.com/credentialed-www-redirect" "" \
  >"$tmpdir/out" 2>"$tmpdir/err"; then
  :
else
  fail "webapp install follows an apex-to-www redirect without credentials" "$(cat "$tmpdir/err" "$tmpdir/curl-log")"
fi
grep -Fxq 'https://www.example.com/no-credentials' "$tmpdir/curl-log" ||
  fail "webapp install requests the redirected host without credentials" "$(cat "$tmpdir/curl-log")"
if grep -Fq 'User:Secret@www.example.com' "$tmpdir/curl-log"; then
  fail "webapp install does not copy credentials to an apex or www alias" "$(cat "$tmpdir/curl-log")"
fi
pass "webapp install keeps redirect credentials on their exact hostname"

: >"$tmpdir/curl-log"
if CURL_LOG="$tmpdir/curl-log" PATH="$stubs:$ROOT/bin:/usr/bin:/bin" HOME="$home" \
  "$ROOT/bin/omarchy-webapp-install" "CredentialPortBoundary" \
  "https://User:Secret@example.com/credentialed-port-redirect" "" \
  >"$tmpdir/out" 2>"$tmpdir/err"; then
  :
else
  fail "webapp install follows a same-host port redirect without credentials" "$(cat "$tmpdir/err" "$tmpdir/curl-log")"
fi
grep -Fxq 'https://example.com:8443/no-credentials' "$tmpdir/curl-log" ||
  fail "webapp install requests the other port without credentials" "$(cat "$tmpdir/curl-log")"
if grep -Fq 'User:Secret@example.com:8443' "$tmpdir/curl-log"; then
  fail "webapp install does not copy credentials to another service on the same host" "$(cat "$tmpdir/curl-log")"
fi
pass "webapp install keeps redirect credentials on their canonical origin"

: >"$tmpdir/curl-log"
if CURL_LOG="$tmpdir/curl-log" PATH="$stubs:$ROOT/bin:/usr/bin:/bin" HOME="$home" \
  "$ROOT/bin/omarchy-webapp-install" "CredentialSchemeBoundary" \
  "http://User:Secret@example.com/credentialed-upgrade" "" \
  >"$tmpdir/out" 2>"$tmpdir/err"; then
  :
else
  fail "webapp install follows an HTTP-to-HTTPS redirect without credentials" "$(cat "$tmpdir/err" "$tmpdir/curl-log")"
fi
grep -Fxq 'https://example.com/no-upgrade-credentials' "$tmpdir/curl-log" ||
  fail "webapp install requests the upgraded scheme without credentials" "$(cat "$tmpdir/curl-log")"
if grep -Fq 'User:Secret@example.com/no-upgrade-credentials' "$tmpdir/curl-log"; then
  fail "webapp install does not copy credentials across schemes" "$(cat "$tmpdir/curl-log")"
fi
pass "webapp install keeps redirect credentials within their scheme"

: >"$tmpdir/curl-log"
if CURL_LOG="$tmpdir/curl-log" PATH="$stubs:$ROOT/bin:/usr/bin:/bin" HOME="$home" \
  "$ROOT/bin/omarchy-webapp-install" "WwwRedirect" "https://example.com/www-redirect" "" \
  >"$tmpdir/out" 2>"$tmpdir/err"; then
  :
else
  fail "webapp install follows an apex-to-www page redirect" "$(cat "$tmpdir/err" "$tmpdir/curl-log")"
fi
grep -Fxq 'https://www.example.com/apps/demo/icon.png' "$tmpdir/curl-log" ||
  fail "webapp install resolves an icon against the redirected www page" "$(cat "$tmpdir/curl-log")"
pass "webapp install permits apex-to-www redirects and uses the final page URL"

: >"$tmpdir/curl-log"
if CURL_LOG="$tmpdir/curl-log" PATH="$stubs:$ROOT/bin:/usr/bin:/bin" HOME="$home" \
  "$ROOT/bin/omarchy-webapp-install" "Downgrade" "https://example.com/downgrade" "" \
  >"$tmpdir/out" 2>"$tmpdir/err"; then
  :
else
  fail "webapp install falls back after refusing an HTTPS downgrade" "$(cat "$tmpdir/err" "$tmpdir/curl-log")"
fi
if grep -Fxq 'http://example.com/insecure' "$tmpdir/curl-log"; then
  fail "webapp install does not follow an HTTPS page to HTTP" "$(cat "$tmpdir/curl-log")"
fi
pass "webapp install refuses HTTPS-to-HTTP page redirects"

: >"$tmpdir/curl-log"
if CURL_LOG="$tmpdir/curl-log" PATH="$stubs:$ROOT/bin:/usr/bin:/bin" HOME="$home" \
  "$ROOT/bin/omarchy-webapp-install" "NumericWww" "https://www.127.0.0.1/page" "" \
  >"$tmpdir/out" 2>"$tmpdir/err"; then
  :
else
  fail "webapp install falls back after refusing a numeric www redirect" "$(cat "$tmpdir/err" "$tmpdir/curl-log")"
fi
if grep -Fxq 'https://127.0.0.1/private-page' "$tmpdir/curl-log"; then
  fail "webapp install does not treat www on a numeric host as an apex alias" "$(cat "$tmpdir/curl-log")"
fi
pass "webapp install does not strip www into a numeric destination"

rm "$stubs/curl"
server_url_file="$tmpdir/server-url"
sink_log="$tmpdir/redirect-sink"
site_log="$tmpdir/site-requests"

python3 - "$server_url_file" "$sink_log" "$site_log" >/dev/null <<'PY' &
import sys
import threading
from http.server import BaseHTTPRequestHandler, ThreadingHTTPServer

url_file, sink_log, site_log = sys.argv[1:]

def record(server_name, path):
  with open(site_log, "a", encoding="utf-8") as log:
    log.write(f"{server_name} {path}\n")

class SinkHandler(BaseHTTPRequestHandler):
  def log_message(self, *args):
    pass

  def do_GET(self):
    with open(sink_log, "a", encoding="utf-8") as log:
      log.write(self.path + "\n")
    self.send_response(200)
    self.end_headers()
    self.wfile.write(b"image")

sink = ThreadingHTTPServer(("127.0.0.1", 0), SinkHandler)
threading.Thread(target=sink.serve_forever, daemon=True).start()

class FinalHandler(BaseHTTPRequestHandler):
  def log_message(self, *args):
    pass

  def do_GET(self):
    record("final", self.path)
    if self.path == "/apps/demo/":
      self.send_response(200)
      self.end_headers()
      self.wfile.write(b'<link rel="apple-touch-icon" href="icon.png">')
    elif self.path == "/apps/demo/icon.png":
      self.send_response(302)
      self.send_header("Location", "/apps/demo/static/icon.png")
      self.end_headers()
    elif self.path == "/apps/demo/static/icon.png":
      self.send_response(200)
      self.end_headers()
      self.wfile.write(b"image")
    elif self.path == "/large-app":
      body = b'<link rel="apple-touch-icon" href="/large-icon.png">' + b"x" * 1100000
      self.send_response(200)
      self.send_header("Content-Length", str(len(body)))
      self.end_headers()
      try:
        self.wfile.write(body)
      except (BrokenPipeError, ConnectionResetError):
        pass
    elif self.path == "/large-icon.png":
      self.send_response(200)
      self.end_headers()
      self.wfile.write(b"image")
    elif self.path == "/":
      self.send_response(200)
      self.end_headers()
      self.wfile.write(f'<link rel="apple-touch-icon" href="127.0.0.1:{sink.server_port}/private-relative">'.encode())
    elif self.path == "/offsite-app":
      self.send_response(200)
      self.end_headers()
      self.wfile.write(b'<link rel="apple-touch-icon" href="/offsite-icon.png">')
    elif self.path == "/offsite-icon.png":
      self.send_response(302)
      self.send_header("Location", f"http://127.0.0.1:{sink.server_port}/private-icon")
      self.end_headers()
    elif self.path == "/apple-touch-icon.png":
      self.send_response(200)
      self.end_headers()
      self.wfile.write(b"image")
    else:
      self.send_response(404)
      self.end_headers()

final = ThreadingHTTPServer(("127.0.0.1", 0), FinalHandler)
threading.Thread(target=final.serve_forever, daemon=True).start()

class EntryHandler(BaseHTTPRequestHandler):
  def log_message(self, *args):
    pass

  def do_GET(self):
    record("entry", self.path)
    if self.path == "/app":
      self.send_response(302)
      self.send_header("Location", f"http://localhost:{final.server_port}/apps/demo/")
      self.end_headers()
    elif self.path == "/page-to-loopback":
      self.send_response(302)
      self.send_header("Location", f"http://127.0.0.1:{sink.server_port}/private-page")
      self.end_headers()
    elif self.path == "/apple-touch-icon.png":
      self.send_response(200)
      self.end_headers()
      self.wfile.write(b"image")
    else:
      self.send_response(404)
      self.end_headers()

entry = ThreadingHTTPServer(("127.0.0.1", 0), EntryHandler)
with open(url_file, "w", encoding="utf-8") as output:
  output.write(f"http://localhost:{entry.server_port}\n")
  output.write(f"http://localhost:{final.server_port}\n")
entry.serve_forever()
PY
server_pid=$!

for _ in {1..50}; do
  [[ -s $server_url_file ]] && break
  sleep 0.1
done
[[ -s $server_url_file ]] || fail "local redirect fixture starts"
mapfile -t server_urls <"$server_url_file"
entry_url=${server_urls[0]}
final_url=${server_urls[1]}

PATH="$stubs:$ROOT/bin:/usr/bin:/bin" HOME="$home" \
  "$ROOT/bin/omarchy-webapp-install" "Redirected" "$entry_url/app" "" \
  >"$tmpdir/out" 2>"$tmpdir/err" ||
  fail "webapp install follows a same-site page redirect" "$(cat "$tmpdir/err" "$site_log")"

for request in \
  "entry /app" \
  "final /apps/demo/" \
  "final /apps/demo/icon.png" \
  "final /apps/demo/static/icon.png"; do
  grep -Fxq "$request" "$site_log" ||
    fail "webapp install requests $request" "$(cat "$site_log")"
done
pass "webapp install resolves relative icons against the final page and follows same-origin redirects"

: >"$site_log"
PATH="$stubs:$ROOT/bin:/usr/bin:/bin" HOME="$home" \
  "$ROOT/bin/omarchy-webapp-install" "LargePage" "$final_url/large-app" "" \
  >"$tmpdir/out" 2>"$tmpdir/err" ||
  fail "webapp install reads a bounded prefix from a large page" "$(cat "$tmpdir/err" "$site_log")"
grep -Fxq "final /large-icon.png" "$site_log" ||
  fail "webapp install discovers an early icon on a large page" "$(cat "$site_log")"
pass "webapp install keeps bounded-prefix icon discovery for large pages"

: >"$sink_log"
: >"$site_log"
PATH="$stubs:$ROOT/bin:/usr/bin:/bin" HOME="$home" \
  "$ROOT/bin/omarchy-webapp-install" "PageRedirect" "$entry_url/page-to-loopback" "" \
  >"$tmpdir/out" 2>"$tmpdir/err" ||
  fail "webapp install falls back after refusing a page redirect off-site" "$(cat "$tmpdir/err" "$site_log")"
[[ ! -s $sink_log ]] ||
  fail "webapp install does not follow a page redirect to loopback" "$(cat "$sink_log")"
grep -Fxq "entry /apple-touch-icon.png" "$site_log" ||
  fail "webapp install uses the selected site's fallback after refusing its redirect" "$(cat "$site_log")"
pass "webapp install refuses page redirects to another host before requesting them"

: >"$sink_log"
: >"$site_log"
PATH="$stubs:$ROOT/bin:/usr/bin:/bin" HOME="$home" \
  "$ROOT/bin/omarchy-webapp-install" "IconRedirect" "$final_url/offsite-app" "" \
  >"$tmpdir/out" 2>"$tmpdir/err" ||
  fail "webapp install falls back after refusing an icon redirect off-origin" "$(cat "$tmpdir/err" "$site_log")"
grep -Fxq "final /offsite-icon.png" "$site_log" ||
  fail "webapp install requests the discovered icon before checking its redirect" "$(cat "$site_log")"
[[ ! -s $sink_log ]] ||
  fail "webapp install does not follow a discovered icon redirect off-origin" "$(cat "$sink_log")"
pass "webapp install refuses off-origin icon redirects after requesting the discovered icon"

# A pathless URL with an uppercase scheme still resolves a relative href as a
# path on the page's origin, never as a host of its own.
: >"$sink_log"
: >"$site_log"
PATH="$stubs:$ROOT/bin:/usr/bin:/bin" HOME="$home" \
  "$ROOT/bin/omarchy-webapp-install" "UppercaseScheme" "HTTP://${final_url#http://}" "" \
  >"$tmpdir/out" 2>"$tmpdir/err" ||
  fail "webapp install falls back after resolving a relative icon on an uppercase URL" "$(cat "$tmpdir/err" "$site_log")"
grep -Eq '^final /127\.0\.0\.1:[0-9]+/private-relative$' "$site_log" ||
  fail "webapp install resolves a relative icon against the uppercase page URL" "$(cat "$site_log")"
[[ ! -s $sink_log ]] ||
  fail "webapp install does not turn a relative icon into another host" "$(cat "$sink_log")"
pass "webapp install resolves relative icons on an uppercase scheme against the page"

kill "$server_pid" 2>/dev/null || true
wait "$server_pid" 2>/dev/null || true
server_pid=""
