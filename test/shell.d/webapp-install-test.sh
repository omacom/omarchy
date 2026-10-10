#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

home="$tmpdir/home"
mkdir -p "$home/.local/share/applications"

install_webapp() {
  HOME="$home" "$ROOT/bin/omarchy-webapp-install" "$@"
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
grep -Fxq 'X-Omarchy-WebApp=true' "$desktop" ||
  fail "webapp install marks the launcher as an Omarchy web app" "$(cat "$desktop")"
pass "webapp install writes an https desktop entry"

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

# Interactive installs ask how to open the app. Choosing the default browser
# must still leave an Omarchy web-app marker so remove menus keep finding it.
printf 'Browser\nhttps://example.com/\nDefault browser\n' >"$tmpdir/answers"
: >"$tmpdir/gum-count"
: >"$tmpdir/curl-log"

# Icon fetch should succeed so gum is not asked for an icon URL before the
# browser choice; answer curl with a tiny PNG when writing -o.
cat >"$stubs/curl" <<'CURL'
#!/bin/bash
out=""
prev=""
for arg in "$@"; do
  [[ $prev == "-o" ]] && out="$arg"
  prev="$arg"
done
if [[ -n $out ]]; then
  printf '%s' 'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAYAAAAfFcSJAAAADUlEQVR42mP8z8BQDwAEhQGAhKmMIQAAAABJRU5ErkJggg==' | base64 -d >"$out"
  exit 0
fi
exit 1
CURL
chmod +x "$stubs/curl"

if ! GUM_ANSWERS="$tmpdir/answers" GUM_COUNT="$tmpdir/gum-count" \
  PATH="$stubs:$PATH" HOME="$home" "$ROOT/bin/omarchy-webapp-install" \
  >"$tmpdir/out" 2>"$tmpdir/err"; then
  fail "interactive webapp install accepts default browser" "$(cat "$tmpdir/err")"
fi

browser_desktop=$(desktop_for Browser)
grep -Fxq 'Exec=xdg-open "https://example.com/"' "$browser_desktop" ||
  fail "interactive webapp install writes xdg-open for default browser" "$(cat "$browser_desktop")"
grep -Fxq 'X-Omarchy-WebApp=true' "$browser_desktop" ||
  fail "interactive default-browser install keeps the Omarchy web app marker" "$(cat "$browser_desktop")"
pass "interactive webapp install can open with the default browser"

# Remove must discover default-browser launchers via the marker, not Exec alone.
printf '#!/bin/bash\n:\n' >"$stubs/update-desktop-database"
printf '#!/bin/bash\n:\n' >"$stubs/omarchy-notification-send"
chmod +x "$stubs/update-desktop-database" "$stubs/omarchy-notification-send"

if ! HOME="$home" PATH="$stubs:$PATH" OMARCHY_REMOVE_NOTIFY=false \
  "$ROOT/bin/omarchy-webapp-remove" "Browser" >"$tmpdir/out" 2>"$tmpdir/err"; then
  fail "webapp remove finds a default-browser web app" "$(cat "$tmpdir/err")"
fi
[[ ! -e $browser_desktop ]] ||
  fail "webapp remove deletes a default-browser web app"
pass "webapp remove finds default-browser launchers via X-Omarchy-WebApp"
