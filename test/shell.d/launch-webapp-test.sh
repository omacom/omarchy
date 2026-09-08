#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mkdir -p "$mock_bin" "$test_home/.local/share/applications"

cat >"$test_home/.local/share/applications/chromium.desktop" <<'EOF'
[Desktop Entry]
Exec=chromium %U
EOF

cat >"$mock_bin/xdg-settings" <<'SH'
#!/bin/bash
echo chromium.desktop
SH
cat >"$mock_bin/setsid" <<'SH'
#!/bin/bash
exec "$@"
SH
cat >"$mock_bin/uwsm-app" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"$OMARCHY_TEST_WEBAPP_LAUNCH"
SH
chmod +x "$mock_bin"/*

launch_log="$test_tmp/launch"

HOME="$test_home" PATH="$mock_bin:$PATH" OMARCHY_TEST_WEBAPP_LAUNCH="$launch_log" \
  bash "$ROOT/bin/omarchy-launch-webapp" "https://example.test/app"

grep -F -- '--app=https://example.test/app' "$launch_log" >/dev/null ||
  fail "webapp launcher passes the URL as --app" "$(cat "$launch_log")"
pass "webapp launcher launches an https app URL"

HOME="$test_home" PATH="$mock_bin:$PATH" OMARCHY_TEST_WEBAPP_LAUNCH="$launch_log" \
  bash "$ROOT/bin/omarchy-launch-webapp" "https://localhost:47990" --ignore-certificate-errors

grep -F -- '--ignore-certificate-errors' "$launch_log" >/dev/null ||
  fail "webapp launcher keeps a local-dev certificate ignore flag" "$(cat "$launch_log")"
pass "webapp launcher keeps --ignore-certificate-errors for local apps"

for url in "javascript:alert(1)" "file:///etc/passwd" "data:text/html,hi" "--gpu-launcher=/tmp/evil"; do
  if HOME="$test_home" PATH="$mock_bin:$PATH" OMARCHY_TEST_WEBAPP_LAUNCH="$launch_log" \
    bash "$ROOT/bin/omarchy-launch-webapp" "$url" 2>"$test_tmp/err"; then
    fail "webapp launcher refuses '$url'"
  fi
  grep -Fq 'must be http or https' "$test_tmp/err" ||
    fail "webapp launcher names the scheme refusal for '$url'" "$(cat "$test_tmp/err")"
done
pass "webapp launcher refuses non-http(s) URLs and leading-dash flags"

if HOME="$test_home" PATH="$mock_bin:$PATH" OMARCHY_TEST_WEBAPP_LAUNCH="$launch_log" \
  bash "$ROOT/bin/omarchy-launch-webapp" "https://example.test" --gpu-launcher=/tmp/evil 2>"$test_tmp/err"; then
  fail "webapp launcher refuses --gpu-launcher extra flags"
fi
grep -Fq 'refuses extra Chromium process flags' "$test_tmp/err" ||
  fail "webapp launcher names the process-flag refusal" "$(cat "$test_tmp/err")"
pass "webapp launcher refuses extra Chromium process flags"

install="$ROOT/bin/omarchy-webapp-install"
grep -Fq -- "--proto '=https,http'" "$install" || fail "webapp icon fetch pins http(s) protocols"
grep -Fq -- "--proto-redir '=https,http'" "$install" || fail "webapp icon fetch refuses file:// redirects"
grep -Fq 'file:* | javascript:* | data:*' "$install" || fail "webapp icon discovery drops non-http hrefs"
pass "webapp install does not follow icon URLs off http(s)"

