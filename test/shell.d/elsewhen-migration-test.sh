#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command jq

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
mkdir -p "$test_dir/bin" "$test_dir/home"
export CALL_LOG="$test_dir/calls"

cat >"$test_dir/bin/omarchy-pkg-drop" <<'SH'
#!/bin/bash
printf 'drop %s\n' "$*" >>"$CALL_LOG"
exit "${PACKAGE_STATUS:-0}"
SH
cat >"$test_dir/bin/omarchy-shell" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"$CALL_LOG"
quiet=0
if [[ $1 == "-q" ]]; then
  quiet=1
  shift
fi
if [[ ${SHELL_ABSENT:-0} == 1 ]]; then
  (( quiet )) && exit 0
  echo "omarchy-shell is not running" >&2
  exit 1
fi
[[ $2 != "rescanPlugins" ]] || exit 0
printf '%s\n' "${TEST_PUT_RESULT:-ok}"
SH
cat >"$test_dir/bin/omarchy-restart-shell" <<'SH'
#!/bin/bash
echo 'migration must leave the restart to omarchy update' >&2
exit 1
SH
chmod +x "$test_dir/bin/"*

run() {
  : >"$CALL_LOG"
  env HOME="$test_dir/home" XDG_CACHE_HOME="$test_dir/home/.cache" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$ROOT/bin:$PATH" "$@" \
    bash -euo pipefail "$migration" >"$test_dir/output" 2>&1
}

[[ -f $ROOT/shell/plugins/panels/elsewhen/manifest.json ]] || fail "Elsewhen ships in the shell tree"
[[ $(jq -r .id "$ROOT/shell/plugins/panels/elsewhen/manifest.json") == "omarchy.elsewhen" ]] ||
  fail "Elsewhen uses the first-party namespace"
! grep -qx elsewhen "$ROOT/install/omarchy-base.packages" || fail "fresh installs do not install the retired package"
pass "Elsewhen ships in the shell tree as omarchy.elsewhen"

# Placement
migration="$ROOT/migrations/1790042972.sh"
expected=$'-q shell rescanPlugins\nshell putBarWidget omarchy.elsewhen {"before":"omarchy.clock"}'

run
[[ $(cat "$CALL_LOG") == "$expected" ]] || fail "scan and placement run in order" "$(cat "$CALL_LOG")"
pass "real bar helper places Elsewhen before the clock without restarting the shell"

run
[[ $(cat "$CALL_LOG") == "$expected" ]] || fail "placement can be rerun"
pass "placement can be rerun"

if run TEST_PUT_RESULT=unknown; then
  fail "an unknown widget must leave the migration pending"
fi
pass "an unknown widget leaves the migration pending"

# An update with no shell to ask, from a TTY or with the shell down, still
# finishes; the update restarts the shell afterwards.
run SHELL_ABSENT=1 OMARCHY_SHELL_ABSENT_ATTEMPTS=1 || fail "an absent shell must not fail the migration" "$(cat "$test_dir/output")"
grep -q "omarchy.elsewhen was not put on the bar" "$test_dir/output" || fail "an absent shell is reported" "$(cat "$test_dir/output")"
pass "an absent shell leaves the update running"

# An entry under the legacy id is left for the rename, not joined by a second widget.
mkdir -p "$test_dir/home/.config/omarchy"
printf '{"bar":{"layout":{"center":[{"id":"omacom.elsewhen","zones":"Tokyo|Asia/Tokyo"},"omarchy.clock"]}}}\n' \
  >"$test_dir/home/.config/omarchy/shell.json"
run
[[ $(cat "$CALL_LOG") == "-q shell rescanPlugins" ]] || fail "a legacy entry skips placement" "$(cat "$CALL_LOG")"
migration="$ROOT/migrations/1790528634.sh"
run
[[ $(jq -c '[.bar.layout.center[] | if type == "object" then .id else . end]' "$test_dir/home/.config/omarchy/shell.json") == '["omarchy.elsewhen","omarchy.clock"]' ]] ||
  fail "the legacy entry becomes the only Elsewhen" "$(cat "$test_dir/home/.config/omarchy/shell.json")"
rm "$test_dir/home/.config/omarchy/shell.json"
migration="$ROOT/migrations/1790042972.sh"
pass "a legacy entry is renamed rather than duplicated"

# The first run of this migration was under 1789581661.sh, before a later
# repair existed; that marker must not stop the renamed file from running there.
state="$test_dir/state"
mkdir -p "$state"
touch "$state/1789581661.sh"
OMARCHY_MIGRATION_STATE="$state" OMARCHY_PATH="$ROOT" "$ROOT/bin/omarchy-migrate" --pending >"$test_dir/pending" || true
grep -qx "$(basename "$migration")" "$test_dir/pending" || fail "the old marker must not satisfy the renamed migration" "$(cat "$test_dir/pending")"
pass "a machine that applied the placement under its old name runs it again"

# Package retirement
migration="$ROOT/migrations/1790528634.sh"
plugin="$test_dir/home/.config/omarchy/plugins/omacom.elsewhen"
mkdir -p "${plugin%/*}"

mkdir -p "$test_dir/home/.cache/omacom-elsewhen"
touch "$test_dir/home/.cache/omacom-elsewhen/data.json"
run
[[ $(cat "$CALL_LOG") == "drop elsewhen" ]] || fail "the package is dropped" "$(cat "$CALL_LOG")"
[[ ! -e $test_dir/home/.config/omarchy/shell.json ]] || fail "a missing config is not created"
[[ ! -e $test_dir/home/.cache/omacom-elsewhen ]] || fail "the old cache is removed"
pass "the retired package and its old cache are removed"

config="$test_dir/home/.config/omarchy/shell.json"
cat >"$config" <<'JSON'
{
  "bar": {
    "centerAnchor": "omacom.elsewhen",
    "layout": {
      "left": ["omarchy.menu"],
      "center": [{ "id": "omacom.elsewhen", "zones": "Tokyo|Asia/Tokyo" }, { "id": "omarchy.clock" }],
      "right": ["omacom.elsewhen"]
    }
  },
  "plugins": [{ "id": "someone.else" }],
  "disabledPlugins": ["omacom.elsewhen", "omarchy.battery"]
}
JSON
run
expected_config='{"bar":{"centerAnchor":"omarchy.elsewhen","layout":{"left":["omarchy.menu"],"center":[{"id":"omarchy.elsewhen","zones":"Tokyo|Asia/Tokyo"},{"id":"omarchy.clock"}],"right":["omarchy.elsewhen"]}},"plugins":[{"id":"someone.else"}],"disabledPlugins":["omarchy.elsewhen","omarchy.battery"]}'
[[ $(jq -c . "$config") == "$expected_config" ]] || fail "bar entries are renamed with their settings" "$(jq -c . "$config")"
run
[[ $(jq -c . "$config") == "$expected_config" ]] || fail "the rename can be rerun"
pass "bar entries, the center anchor and plugin lists move to omarchy.elsewhen with their settings"

printf 'not json' >"$config"
if run; then
  fail "an unreadable config must leave the migration pending"
fi
[[ $(cat "$config") == "not json" ]] || fail "an unreadable config is left untouched"
pass "an unreadable config leaves the migration pending and the file untouched"
rm "$config"

for target in /usr/share/omarchy/shell/plugins/omacom.elsewhen /usr/share/omarchy/plugins/omacom.elsewhen; do
  ln -sfn "$target" "$plugin"
  run
  [[ ! -e $plugin && ! -L $plugin ]] || fail "a link to the packaged plugin is removed ($target)"
done
pass "dev links to the packaged plugin are removed, including the stranded old path"

ln -s "$test_dir/custom-plugin" "$plugin"
run
[[ $(readlink "$plugin") == "$test_dir/custom-plugin" ]] || fail "a link the user made is preserved"
rm "$plugin"
mkdir "$plugin"
printf 'local work\n' >"$plugin/notes"
run
[[ $(cat "$plugin/notes") == "local work" ]] || fail "a local checkout is preserved"
pass "user links and checkouts are preserved"

if run PACKAGE_STATUS=1; then
  fail "a failed removal must leave the migration pending"
fi
pass "a failed removal leaves the migration pending"
