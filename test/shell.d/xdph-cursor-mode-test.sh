#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

MIGRATION="$ROOT/migrations/1792191856.sh"
DEFAULT_CONFIG="$ROOT/config/hypr/xdph.conf"

# The shipped default carries the fix, inside the screencopy block xdph reads.
grep -q '^[[:space:]]*cursor_mode[[:space:]]*=[[:space:]]*2[[:space:]]*$' "$DEFAULT_CONFIG" || fail "the shipped xdph.conf sets cursor_mode = 2"
awk '/^[[:space:]]*screencopy[[:space:]]*{/{block=1} block && /cursor_mode/{found=1} END{exit !found}' "$DEFAULT_CONFIG" || fail "cursor_mode sits inside the screencopy block"

run_migration() {
  local home="$1"
  local stub_bin="$home/stub-bin"
  mkdir -p "$stub_bin"
  # A stub systemctl keeps the test hermetic: the real migration restarts the
  # user's portal, which a test must never do.
  cat > "$stub_bin/systemctl" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >> "$SYSTEMCTL_LOG"
exit 0
STUB
  chmod +x "$stub_bin/systemctl"
  local log="$home/systemctl.log"
  HOME="$home" OMARCHY_PATH="$ROOT" XDG_CONFIG_HOME= SYSTEMCTL_LOG="$log" PATH="$stub_bin:$PATH" bash "$MIGRATION" >/dev/null
}

# A fresh user config: the migration copies the shipped default.
home=$(mktemp -d)
run_migration "$home"
[[ -f $home/.config/hypr/xdph.conf ]] || fail "a missing user config is created"
grep -q 'cursor_mode = 2' "$home/.config/hypr/xdph.conf" || fail "the created config carries cursor_mode"
rm -rf "$home"

# An existing config still on the old default: the setting is added to the
# screencopy block and nothing else changes.
home=$(mktemp -d)
mkdir -p "$home/.config/hypr"
cat > "$home/.config/hypr/xdph.conf" <<'CONF'
screencopy {
    allow_token_by_default = true
    custom_picker_binary = hyprland-preview-share-picker
}
CONF
run_migration "$home"
grep -q '^[[:space:]]*cursor_mode[[:space:]]*=[[:space:]]*2' "$home/.config/hypr/xdph.conf" || fail "an old config gains cursor_mode"
[[ $(grep -c 'cursor_mode' "$home/.config/hypr/xdph.conf") -eq 1 ]] || fail "the setting lands exactly once"
grep -q 'allow_token_by_default' "$home/.config/hypr/xdph.conf" || fail "the rest of the config is kept"
[[ $(grep -c 'allow_token_by_default' "$home/.config/hypr/xdph.conf") -eq 1 ]] || fail "no line is duplicated"

# The migration is idempotent: a second run changes nothing.
before=$(cat "$home/.config/hypr/xdph.conf")
run_migration "$home"
[[ $(cat "$home/.config/hypr/xdph.conf") == "$before" ]] || fail "a second run changes nothing"
rm -rf "$home"

# A config that already carries a cursor_mode of its own is left alone.
home=$(mktemp -d)
mkdir -p "$home/.config/hypr"
printf 'screencopy {\n    cursor_mode = 1\n}\n' > "$home/.config/hypr/xdph.conf"
run_migration "$home"
grep -q 'cursor_mode = 1' "$home/.config/hypr/xdph.conf" || fail "an explicit choice is left alone"
rm -rf "$home"

# A config without a screencopy block gets one appended.
home=$(mktemp -d)
mkdir -p "$home/.config/hypr"
printf 'screencopy:force_shm = false\n' > "$home/.config/hypr/xdph.conf"
run_migration "$home"
grep -q 'cursor_mode = 2' "$home/.config/hypr/xdph.conf" || fail "a config without a screencopy block gains one"
grep -q 'force_shm' "$home/.config/hypr/xdph.conf" || fail "the appended block keeps the old content"
rm -rf "$home"

pass "the shipped config, an old config, an explicit choice and a config without a screencopy block all end up right"
