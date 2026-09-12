#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

stubs="$tmpdir/stubs"
mkdir -p "$stubs"

cat >"$stubs/omarchy-launch-webapp" <<'SH'
#!/bin/bash
printf '<%s>\n' "$@"
SH
chmod +x "$stubs/omarchy-launch-webapp"

handler="$ROOT/bin/omarchy-webapp-handler-slack"

check_handler() {
  local description="$1"
  local expected="$2"
  local url="$3"
  local actual

  actual=$(PATH="$stubs:$PATH" "$handler" "$url")
  [[ $actual == "<$expected>" ]] || fail "$description" "$actual"
  pass "$description"
}

check_handler "Slack handler opens the requested workspace" \
  "https://app.slack.com/client/T123ABC456" \
  "slack://open?team=T123ABC456"
check_handler "Slack handler opens a channel" \
  "https://app.slack.com/client/T123ABC456/C123ABC456" \
  "slack://channel?team=T123ABC456&id=C123ABC456"
check_handler "Slack handler opens an Enterprise Grid channel" \
  "https://app.slack.com/client/E123ABC456/C123ABC456" \
  "slack://channel?team=E123ABC456&id=C123ABC456"
check_handler "Slack handler opens a message" \
  "https://app.slack.com/client/T123ABC456/C123ABC456/1234567890.123456" \
  "slack://channel?team=T123ABC456&id=C123ABC456&message=1234567890.123456"
check_handler "Slack handler opens a direct message" \
  "https://app.slack.com/client/T123ABC456/U123ABC456" \
  "slack://user?team=T123ABC456&id=U123ABC456"
check_handler "Slack handler opens an app" \
  "https://app.slack.com/client/T123ABC456/A123ABC456" \
  "slack://app?team=T123ABC456&id=A123ABC456&tab=home"

for url in \
  '' \
  'https://example.com/?team=T123ABC456&id=C123ABC456' \
  'slack://channel?team=../../tmp&id=C123ABC456' \
  'slack://channel?team=T123ABC456&id=C123/../../tmp' \
  'slack://channel?team=T123ABC456&id=C123ABC456&message=javascript'; do
  actual=$(PATH="$stubs:$PATH" "$handler" "$url")
  [[ $actual == '<https://app.slack.com/client>' || $actual == '<https://app.slack.com/client/T123ABC456/C123ABC456>' ]] ||
    fail "Slack handler contains untrusted values for '$url'" "$actual"
done
pass "Slack handler contains malformed links to app.slack.com"

cat >"$stubs/omarchy-webapp-install" <<'SH'
#!/bin/bash
printf '<%s>\n' "$@" >"$INSTALL_LOG"
SH
cat >"$stubs/update-desktop-database" <<'SH'
#!/bin/bash
printf '<%s>\n' "$@" >"$UPDATE_LOG"
SH
cat >"$stubs/omarchy-webapp-remove" <<'SH'
#!/bin/bash
printf '<%s>\n' "$@" >"$REMOVE_LOG"
SH
chmod +x "$stubs/omarchy-webapp-install" "$stubs/update-desktop-database" "$stubs/omarchy-webapp-remove"

install_log="$tmpdir/install.log"
update_log="$tmpdir/update.log"
home="$tmpdir/home"
mkdir -p "$home/.local/share/applications"
INSTALL_LOG="$install_log" UPDATE_LOG="$update_log" HOME="$home" PATH="$stubs:$PATH" \
  "$ROOT/bin/omarchy-install-service-slack" >/dev/null

mapfile -t install_args <"$install_log"
[[ ${install_args[*]} == '<Slack> <https://app.slack.com/client> <https://cdn.jsdelivr.net/gh/homarr-labs/dashboard-icons/png/slack.png> <omarchy-webapp-handler-slack %u> <x-scheme-handler/slack>' ]] ||
  fail "Slack installer passes the launcher, handler, and scheme to webapp install" "${install_args[*]}"
[[ $(cat "$update_log") == "<$home/.local/share/applications>" ]] ||
  fail "Slack installer refreshes the desktop database" "$(cat "$update_log")"
pass "Slack service installer registers the web app and protocol handler"

remove_log="$tmpdir/remove.log"
REMOVE_LOG="$remove_log" PATH="$stubs:$PATH" "$ROOT/bin/omarchy-remove-service-slack"
[[ $(cat "$remove_log") == '<Slack>' ]] || fail "Slack remover removes the installed web app"
pass "Slack service remover mirrors installation"

menu="$ROOT/default/omarchy/omarchy-menu.jsonc"
grep -Fq '"install.service.slack"' "$menu" || fail "Slack is available under Install > Service"
grep -Fq '"remove.service.slack"' "$menu" || fail "Slack is available under Remove > Services"
pass "Slack service is wired into both menu paths"
