#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1789091250.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
calls="$test_tmp/calls"
mkdir -p "$mock_bin"

# pacman answers for the real omarchy-pkg-present and omarchy-pkg-add.
cat >"$mock_bin/pacman" <<'SH'
#!/bin/bash
echo "pacman $*" >>"$OMARCHY_TEST_CALLS"
[[ $OMARCHY_TEST_T3_INSTALLED == "1" ]]
SH

cat >"$mock_bin/t3" <<'SH'
#!/bin/bash
echo "t3${*:+ $*}" >>"$OMARCHY_TEST_CALLS"
[[ $1 == "theme" && $2 == "set" && $3 == "omarchy" && $4 == "--base-dir" ]] || exit 1
palette="$5/userdata/themes/omarchy.json"
[[ -f $palette ]] || exit 1
! grep -q '{{' "$palette"
SH

for command in setsid uwsm-app gtk-launch; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash
echo "$(basename "$0")${*:+ $*}" >>"$OMARCHY_TEST_CALLS"
SH
done
chmod +x "$mock_bin"/*

run_migration() {
  local home=$1 installed=$2
  shift 2

  : >"$calls"
  env -u T3CODE_HOME HOME="$home" OMARCHY_PATH="$ROOT" PATH="$mock_bin:$ROOT/bin:$PATH" \
    OMARCHY_THEME_HEADLESS=1 XDG_RUNTIME_DIR="$test_tmp" \
    OMARCHY_TEST_CALLS="$calls" OMARCHY_TEST_T3_INSTALLED="$installed" "$@" \
    bash -euo pipefail "$migration" >"$test_tmp/output" 2>&1
}

assert_nothing_launched() {
  if grep -Eq '^(setsid|uwsm-app|gtk-launch)( |$)' "$calls" || grep -q 'Opening T3 Code' "$test_tmp/output"; then
    fail "$1" "$(cat "$test_tmp/output" "$calls")"
  fi
}

# An installed T3 Code with the palette already staged is only re-themed.
home="$test_tmp/staged"
mkdir -p "$home/.local/state/omarchy/current/theme"
echo '{"name":"Staged"}' >"$home/.local/state/omarchy/current/theme/t3code.json"
cp "$home/.local/state/omarchy/current/theme/t3code.json" "$test_tmp/staged-palette.json"

run_migration "$home" 1 || fail "the migration succeeds for an installed T3 Code" "$(cat "$test_tmp/output")"
assert_nothing_launched "the migration does not open T3 Code"
cmp -s "$test_tmp/staged-palette.json" "$home/.local/state/omarchy/current/theme/t3code.json" || \
  fail "a staged palette is not re-rendered"
cmp -s "$test_tmp/staged-palette.json" "$home/.t3/userdata/themes/omarchy.json" || \
  fail "the staged palette is published to T3 Code"
grep -qxF "t3 theme set omarchy --base-dir $home/.t3" "$calls" || fail "T3 Code selects the Omarchy theme" "$(cat "$calls")"
[[ -d $home/.t3/userdata ]] || fail "the T3 state directory exists for the palette to land in"
pass "an existing T3 Code install is themed without being launched"

# A palette staged before the template existed is rendered first, into a custom T3 home.
home="$test_tmp/unstaged"
t3_home="$test_tmp/custom t3 home"
state="$home/.local/state/omarchy/current"
mkdir -p "$state/theme"
echo 'tokyo-night' >"$state/theme.name"
cp "$ROOT/themes/tokyo-night/colors.toml" "$state/theme/colors.toml"

run_migration "$home" 1 T3CODE_HOME="$t3_home" || fail "the migration succeeds without a staged palette" "$(cat "$test_tmp/output")"
assert_nothing_launched "the migration does not open T3 Code without a staged palette"
[[ $(grep -v '^pacman ' "$calls") == "t3 theme set omarchy --base-dir $t3_home" ]] || \
  fail "the rendered palette is selected" "$(cat "$calls")"
[[ -f $state/theme/t3code.json ]] || fail "the missing palette is rendered from the current theme"
cmp -s "$state/theme/t3code.json" "$t3_home/userdata/themes/omarchy.json" || \
  fail "the rendered palette is published to T3 Code"
jq -e '.name == "Omarchy" and (.accent | test("^#[0-9a-fA-F]{6}$"))' "$state/theme/t3code.json" >/dev/null || \
  fail "the rendered palette contains resolved theme colors"
[[ -d $t3_home/userdata && ! -e $home/.t3 ]] || fail "the custom T3 home is respected"
pass "a missing palette is rendered before T3 Code is themed"

# Without T3 Code there is nothing to theme.
home="$test_tmp/absent"
mkdir -p "$home"

run_migration "$home" 0 || fail "the migration succeeds without T3 Code" "$(cat "$test_tmp/output")"
if grep -v '^pacman ' "$calls" | grep -q .; then
  fail "nothing is themed or launched without T3 Code" "$(cat "$calls")"
fi
[[ ! -e $home/.t3 ]] || fail "no T3 state directory is created without T3 Code"
pass "the migration leaves machines without T3 Code alone"
