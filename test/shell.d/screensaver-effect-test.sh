#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

# Only "matrix" is a real effect here; anything else fails --help the way an
# unrecognized ttfx subcommand would.
cat >"$stub_bin/ttfx" <<'STUB'
#!/bin/bash
[[ $1 == "matrix" && $2 == "--help" ]]
STUB
chmod +x "$stub_bin/ttfx"

notify_log="$test_tmp/notify.log"
cat >"$stub_bin/omarchy-notification-send" <<STUB
#!/bin/bash
printf '%s\n' "\$*" >>"$notify_log"
STUB
chmod +x "$stub_bin/omarchy-notification-send"

fake_home="$test_tmp/home"
fake_omarchy_path="$test_tmp/omarchy-path"
mkdir -p "$fake_home/.config/omarchy" "$fake_omarchy_path/config/omarchy"

cat >"$fake_omarchy_path/config/omarchy/shell.json" <<'JSON'
{
  "version": 1,
  "idle": { "screensaver": 150, "lock": 300 }
}
JSON

resolve_effect() {
  rm -f "$notify_log"
  HOME="$fake_home" OMARCHY_PATH="$fake_omarchy_path" PATH="$stub_bin:$PATH" \
    "$ROOT/bin/omarchy-screensaver-effect"
}

# No screensaverEffect configured anywhere: falls back to random, silently.
rm -f "$fake_home/.config/omarchy/shell.json"
[[ -z $(resolve_effect) ]] || fail "screensaver effect defaults to random when unset"
[[ ! -s $notify_log ]] || fail "screensaver effect stays quiet when unset"
pass "screensaver effect defaults to random when unset"

# A recognized effect is resolved and printed as-is.
cat >"$fake_home/.config/omarchy/shell.json" <<'JSON'
{
  "version": 1,
  "idle": { "screensaver": 150, "lock": 300, "screensaverEffect": "matrix" }
}
JSON
[[ $(resolve_effect) == "matrix" ]] || fail "screensaver effect resolves a configured effect"
[[ ! -s $notify_log ]] || fail "screensaver effect stays quiet for a valid effect"
pass "screensaver effect resolves a configured effect"

# An unrecognized effect name falls back to random and notifies why.
cat >"$fake_home/.config/omarchy/shell.json" <<'JSON'
{
  "version": 1,
  "idle": { "screensaver": 150, "lock": 300, "screensaverEffect": "not-a-real-effect" }
}
JSON
[[ -z $(resolve_effect) ]] || fail "screensaver effect falls back to random for an unknown effect"
grep -q "not-a-real-effect" "$notify_log" || fail "screensaver effect notifies about the unknown effect"
pass "screensaver effect falls back to random and notifies for an unknown effect"
