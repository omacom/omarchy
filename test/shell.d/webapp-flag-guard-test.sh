#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

launcher="$ROOT/bin/omarchy-launch-webapp"
migration="$ROOT/migrations/1790062793.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

stub_bin="$test_dir/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/xdg-settings" <<'STUB'
#!/bin/bash
echo chromium.desktop
STUB
# The dispatch is recorded rather than performed, so the assertions are about
# what would reach the browser.
cat >"$stub_bin/setsid" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"${DISPATCH:?}"
STUB
chmod +x "$stub_bin"/*

dispatch="$test_dir/dispatch"

launch() {
  rm -f "$dispatch"
  : >"$dispatch"
  DISPATCH="$dispatch" PATH="$stub_bin:$PATH" bash "$launcher" "$@" 2>"$test_dir/err" && return 0
  return 1
}

# Chromium's POSIX parser accepts one or two dashes and an optional "=value",
# and trims surrounding ASCII whitespace before reading the switch name. Every
# spelling that reaches it as a session-wide downgrade has to be refused.
for spelling in \
  "--ignore-certificate-errors" \
  "-ignore-certificate-errors" \
  "--no-sandbox=1" \
  " --ignore-certificate-errors" \
  "--ignore-certificate-errors " \
  "  -no-sandbox  "; do
  if launch https://example.com "$spelling"; then
    fail "launcher refuses $(printf '%q' "$spelling")" "$(cat "$dispatch")"
  fi
  grep -q "refusing" "$test_dir/err" ||
    fail "launcher explains why it refused $(printf '%q' "$spelling")" "$(cat "$test_dir/err")"
done
pass "launcher refuses every spelling of a session-wide switch, including whitespace-padded"

# A different switch that merely shares a prefix is not the refused one.
launch https://example.com "--ignore-certificate-errors-spki-list=abc" ||
  fail "launcher forwards a differently-named switch" "$(cat "$test_dir/err")"
grep -q -- "--ignore-certificate-errors-spki-list=abc" "$dispatch" ||
  fail "launcher forwards a differently-named switch unchanged" "$(cat "$dispatch")"
pass "launcher forwards a switch that only shares a prefix"

# Whitespace is trimmed for the comparison only; the argument itself is passed
# through exactly as given.
launch https://example.com " --window-size=800,600" ||
  fail "launcher forwards an unrelated padded argument" "$(cat "$test_dir/err")"
grep -qF -- " --window-size=800,600" "$dispatch" ||
  fail "launcher forwards an unrelated argument byte-for-byte" "$(cat "$dispatch")"
pass "launcher forwards unrelated arguments unchanged"

# --- the migration repairs only the entry it inspected ---

desktop_dir="$test_dir/home/.local/share/applications"
mkdir -p "$desktop_dir"
desktop="$desktop_dir/Sunshine Admin.desktop"

write_desktop() {
  cat >"$desktop" <<DESKTOP
[Desktop Entry]
Name=Sunshine Admin
Exec=omarchy-launch-webapp https://localhost:47990 --ignore-certificate-errors
Type=Application
Actions=Documentation;

[Desktop Action Documentation]
Name=Documentation
Exec=omarchy-launch-webapp https://docs.lizardbyte.dev/projects/sunshine/
DESKTOP
}

write_desktop
HOME="$test_dir/home" bash "$migration" >/dev/null 2>&1

grep -qxF "Exec=omarchy-launch-webapp https://localhost:47990" "$desktop" ||
  fail "migration strips the flag from the entry's own Exec line" "$(cat "$desktop")"
pass "migration strips the flag from the entry's own Exec line"

grep -qxF "Exec=omarchy-launch-webapp https://docs.lizardbyte.dev/projects/sunshine/" "$desktop" ||
  fail "migration leaves a desktop action's Exec line alone" "$(cat "$desktop")"
pass "migration leaves a desktop action's Exec line alone"

# Rerunning must not change a file it has already repaired.
before=$(cat "$desktop")
HOME="$test_dir/home" bash "$migration" >/dev/null 2>&1
[[ $before == "$(cat "$desktop")" ]] ||
  fail "migration is idempotent" "$(diff <(printf '%s' "$before") "$desktop" || true)"
pass "migration is idempotent"
