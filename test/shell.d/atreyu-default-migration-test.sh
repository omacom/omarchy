#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

migration="$ROOT/migrations/1789529710.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

mkdir -p "$test_dir/bin"
export INSTALLED_PACKAGES="$test_dir/installed" CALL_LOG="$test_dir/calls" SHELL_CALLS="$test_dir/shell-calls"

# Keep the real package helpers, but contain every pacman transaction here.
cat >"$test_dir/bin/pacman" <<'SH'
#!/bin/bash
case "$1" in
  -Q) grep -Fxq -- "$2" "$INSTALLED_PACKAGES" ;;
  -S)
    [[ ${FAIL_INSTALL:-0} == 0 ]] || exit 1
    shift 3 # -S --noconfirm --needed
    printf '%s\n' "$@" >>"$INSTALLED_PACKAGES"
    printf '%s\n' "$@" >>"$CALL_LOG"
    ;;
  *) exit 1 ;;
esac
SH
cat >"$test_dir/bin/sudo" <<'SH'
#!/bin/bash
[[ $1 == "pacman" ]] || exit 1
"$@"
SH
# The migration runs under a shell that predates the packaged root, or under
# none at all, so it must only ever ask the shell for best-effort refreshes.
cat >"$test_dir/bin/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$SHELL_CALLS"
[[ $1 != "-q" ]] || exit 0
exit "${SHELL_STATUS:-0}"
SH
chmod +x "$test_dir/bin/"*

home="$test_dir/home"
config="$home/.config/omarchy/shell.json"
mkdir -p "$home/.config/omarchy"

run_migration() {
  : >"$CALL_LOG"
  : >"$SHELL_CALLS"
  HOME="$home" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$ROOT/bin:$PATH" \
    bash -euo pipefail "$migration" >/dev/null
}

ids() {
  jq -c ".bar.layout.$1 | map(if type == \"object\" then .id else . end)" "$config"
}

# ------------------------------------------------------------ package install
: >"$INSTALLED_PACKAGES"
cat >"$config" <<'JSON'
{
  "version": 1,
  "bar": {
    "layout": {
      "left": [{ "id": "omarchy.menu" }],
      "center": [{ "id": "omarchy.clock", "format": "HH:mm" }],
      "right": [
        { "id": "omarchy.tray" },
        { "id": "omarchy.agents", "syncMode": "On" },
        { "id": "omarchy.power" }
      ]
    }
  },
  "plugins": []
}
JSON

run_migration
grep -Fxq atreyu "$CALL_LOG" || fail "migration installs the atreyu package" "$(cat "$CALL_LOG")"
pass "migration installs the atreyu package"

[[ $(ids right) == '["omarchy.tray","omarchy.atreyu","omarchy.agents","omarchy.power"]' ]] ||
  fail "migration puts the widget just before agents" "$(cat "$config")"
pass "migration puts the widget just before agents"

[[ $(jq -c '.bar.layout.right[2]' "$config") == '{"id":"omarchy.agents","syncMode":"On"}' ]] ||
  fail "migration keeps the settings of its neighbours" "$(cat "$config")"
[[ $(jq -c '.bar.layout.center[0]' "$config") == '{"format":"HH:mm","id":"omarchy.clock"}' ]] ||
  fail "migration leaves other sections alone" "$(cat "$config")"
pass "migration leaves the rest of the layout alone"

grep -q 'shell rescanPlugins' "$SHELL_CALLS" && grep -q 'shell reloadConfig' "$SHELL_CALLS" ||
  fail "migration asks the running shell to rescan and reload" "$(cat "$SHELL_CALLS")"
pass "migration asks the running shell to rescan and reload"

before=$(sha256sum "$config")
run_migration
[[ $before == $(sha256sum "$config") ]] || fail "migration is idempotent" "$(cat "$config")"
[[ ! -s $CALL_LOG ]] || fail "migration does not reinstall a present package" "$(cat "$CALL_LOG")"
pass "migration is idempotent"

# ------------------------------------------------------------- placements
cat >"$config" <<'JSON'
{
  "version": 1,
  "bar": { "layout": { "left": [], "center": ["omarchy.clock", "omarchy.agents"], "right": ["omarchy.tray"] } }
}
JSON
run_migration
[[ $(ids center) == '["omarchy.clock","omarchy.atreyu","omarchy.agents"]' && $(ids right) == '["omarchy.tray"]' ]] ||
  fail "migration follows agents into another section and reads string entries" "$(cat "$config")"
pass "migration follows agents into another section and reads string entries"

cat >"$config" <<'JSON'
{
  "version": 1,
  "bar": { "layout": { "left": [], "center": [], "right": [{ "id": "omarchy.tray" }, { "id": "omarchy.power" }] } }
}
JSON
run_migration
[[ $(ids right) == '["omarchy.tray","omarchy.atreyu","omarchy.power"]' ]] ||
  fail "migration falls back to the tray when agents is off the bar" "$(cat "$config")"
pass "migration falls back to the tray when agents is off the bar"

cat >"$config" <<'JSON'
{ "version": 1, "bar": { "layout": { "right": [{ "id": "omarchy.power" }] } } }
JSON
run_migration
[[ $(ids right) == '["omarchy.power","omarchy.atreyu"]' ]] ||
  fail "migration appends to the right section when neither neighbour is on the bar" "$(cat "$config")"
pass "migration appends to the right section when neither neighbour is on the bar"

cat >"$config" <<'JSON'
{
  "version": 1,
  "bar": { "layout": { "left": [{ "id": "omarchy.atreyu" }], "center": [], "right": [{ "id": "omarchy.tray" }, { "id": "omarchy.agents" }] } }
}
JSON
before=$(sha256sum "$config")
run_migration
[[ $before == $(sha256sum "$config") ]] ||
  fail "migration leaves a widget the user already placed where it is" "$(cat "$config")"
pass "migration leaves a widget the user already placed where it is"

# ------------------------------------------------------------- edge cases
rm -f "$config"
run_migration
[[ ! -e $config ]] || fail "migration writes no shell.json where the defaults apply" "$(cat "$config")"
pass "migration writes no shell.json where the defaults apply"

printf '{ not json' >"$config"
run_migration
[[ $(cat "$config") == '{ not json' ]] || fail "migration leaves an unparsable config untouched" "$(cat "$config")"
pass "migration leaves an unparsable config untouched"

cat >"$config" <<'JSON'
{ "version": 1, "bar": { "layout": { "right": [{ "id": "omarchy.tray" }, { "id": "omarchy.agents" }] } } }
JSON
SHELL_STATUS=1 run_migration
[[ $(ids right) == '["omarchy.tray","omarchy.atreyu","omarchy.agents"]' ]] ||
  fail "migration places the widget with no shell running" "$(cat "$config")"
pass "migration places the widget with no shell running"

# A package the mirror does not carry yet leaves the migration pending rather
# than half-done: the layout must not name a widget nothing can install.
: >"$INSTALLED_PACKAGES"
cat >"$config" <<'JSON'
{ "version": 1, "bar": { "layout": { "right": [{ "id": "omarchy.tray" }, { "id": "omarchy.agents" }] } } }
JSON
before=$(sha256sum "$config")
if FAIL_INSTALL=1 run_migration 2>/dev/null; then
  fail "a failed package installation must leave the migration pending"
fi
[[ $before == $(sha256sum "$config") ]] ||
  fail "a failed package installation leaves the layout untouched" "$(cat "$config")"
pass "a failed package installation is propagated and changes nothing"
