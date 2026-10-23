#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

migration="$ROOT/migrations/1786633468.sh"
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

mkdir -p "$test_dir/bin"

cat >"$test_dir/bin/herdr" <<'STUB'
#!/bin/bash

printf '%s\n' "$*" >>"$HERDR_CALLS"

if [[ $* == "config check" ]]; then
  (( ${HERDR_CHECK_STATUS:-0} == 0 )) || exit 1
  grep -q 'invalid = ' "$HERDR_CONFIG_PATH" && exit 1
fi

exit 0
STUB

cat >"$test_dir/bin/omarchy-restart-herdr" <<'STUB'
#!/bin/bash

echo restart >>"$HERDR_RESTARTS"
exit "${HERDR_RESTART_STATUS:-0}"
STUB

cat >"$test_dir/bin/date" <<'STUB'
#!/bin/bash

[[ ${1:-} == "+%s" ]] && echo 1234567890
STUB

chmod +x "$test_dir/bin/"*

export HERDR_CALLS="$test_dir/herdr-calls"
export HERDR_RESTARTS="$test_dir/herdr-restarts"

home="$test_dir/home"
config_file="$home/.config/herdr/config.toml"

reset_home() {
  rm -rf "$home"
  mkdir -p "$(dirname "$config_file")"
  : >"$HERDR_CALLS"
  : >"$HERDR_RESTARTS"
}

run_migration() {
  HOME="$home" OMARCHY_PATH="$ROOT" XDG_CONFIG_HOME="${TEST_XDG_CONFIG_HOME:-}" PATH="$test_dir/bin:$PATH" \
    bash -euo pipefail "$migration" >/dev/null
}

reset_home
cat >"$config_file" <<'EOF'
onboarding = false

[ui]
agent_panel_sort = "priority"

[theme]
name = "catppuccin-latte"
auto_switch = false

[experimental]
pane_history = true
EOF
cp "$config_file" "$test_dir/original-config"

run_migration

grep -Fxq 'name = "terminal"' "$config_file" ||
  fail "Herdr migration selects the terminal theme" "$(cat "$config_file")"
grep -q 'catppuccin-latte' "$config_file" &&
  fail "Herdr migration removes the pinned theme"
grep -Fxq 'agent_panel_sort = "priority"' "$config_file" ||
  fail "Herdr migration keeps UI preferences"
grep -Fxq 'pane_history = true' "$config_file" ||
  fail "Herdr migration keeps experimental preferences"
pass "Herdr migration selects the terminal theme and keeps other preferences"

backup="$config_file.bak.1234567890"
cmp -s "$test_dir/original-config" "$backup" ||
  fail "Herdr migration backs up the original config" "$(diff -u "$test_dir/original-config" "$backup" || true)"
validation_count=$(wc -l <"$HERDR_CALLS")
restart_count=$(wc -l <"$HERDR_RESTARTS")
(( validation_count == 1 )) || fail "Herdr migration validates once"
(( restart_count == 1 )) || fail "Herdr migration reloads once"
pass "Herdr migration validates, backs up, and reloads"

: >"$HERDR_CALLS"
: >"$HERDR_RESTARTS"
before=$(sha256sum "$config_file")
run_migration
[[ $before == $(sha256sum "$config_file") ]] || fail "Herdr migration is idempotent"
[[ ! -s $HERDR_CALLS ]] || fail "idempotent Herdr migration skips validation"
[[ ! -s $HERDR_RESTARTS ]] || fail "idempotent Herdr migration skips reload"
pass "Herdr migration is idempotent"

reset_home
cat >"$config_file" <<'EOF'
[theme]
auto_switch = false

[keys]
prefix = "ctrl+space"
EOF

run_migration
theme_name_count=$(sed -n '/^\[theme\]$/,/^\[/p' "$config_file" | grep -c '^name = "terminal"$' || true)
(( theme_name_count == 1 )) ||
  fail "Herdr migration adds a missing name inside the theme section" "$(cat "$config_file")"
grep -Fxq 'prefix = "ctrl+space"' "$config_file" || fail "Herdr migration keeps the following section"
pass "Herdr migration fills an existing theme section"

reset_home
cat >"$config_file" <<'EOF'
onboarding = false

[ui]
accent = "cyan"
EOF

run_migration
python3 - "$config_file" <<'PYTOML'
import sys, tomllib
with open(sys.argv[1], "rb") as file:
    config = tomllib.load(file)
assert config["theme"]["name"] == "terminal"
assert config["ui"]["accent"] == "cyan"
PYTOML
pass "Herdr migration adds a missing theme section"

reset_home
cat >"$config_file" <<'EOF'
[theme]
name = "terminal"
EOF

before=$(sha256sum "$config_file")
run_migration
[[ $before == $(sha256sum "$config_file") ]] || fail "terminal config remains unchanged"
[[ ! -e $config_file.bak.1234567890 ]] || fail "terminal config gets no needless backup"
[[ ! -s $HERDR_CALLS && ! -s $HERDR_RESTARTS ]] || fail "terminal config gets no needless work"
pass "Herdr migration skips an already integrated config"

reset_home
run_migration
[[ ! -e $config_file ]] || fail "Herdr migration does not create an unowned config"
[[ ! -s $HERDR_CALLS && ! -s $HERDR_RESTARTS ]] || fail "missing Herdr config gets no work"
pass "Herdr migration leaves a missing config to the install path"

reset_home
TEST_XDG_CONFIG_HOME="$home/custom-config"
xdg_config_file="$TEST_XDG_CONFIG_HOME/herdr/config.toml"
mkdir -p "$(dirname "$xdg_config_file")"
cat >"$xdg_config_file" <<'EOF'
[theme]
name = "nord"
EOF

run_migration
grep -Fxq 'name = "terminal"' "$xdg_config_file" || fail "Herdr migration ignores XDG_CONFIG_HOME"
[[ ! -e $config_file ]] || fail "Herdr migration writes the fallback config when XDG_CONFIG_HOME is set"
pass "Herdr migration follows Herdr's XDG-aware config lookup"
unset TEST_XDG_CONFIG_HOME

reset_home
mkdir -p "$home/dotfiles"
cat >"$home/dotfiles/herdr.toml" <<'EOF'
[theme]
name = "nord"
EOF
ln -s "$home/dotfiles/herdr.toml" "$config_file"

run_migration
[[ -L $config_file ]] || fail "Herdr migration preserves a config symlink"
symlink_target=$(readlink "$config_file")
[[ $symlink_target == $home/dotfiles/herdr.toml ]] || fail "Herdr migration preserves the symlink target"
grep -Fxq 'name = "terminal"' "$home/dotfiles/herdr.toml" || fail "Herdr migration writes through the symlink"
pass "Herdr migration preserves dotfile symlinks"

reset_home
cat >"$config_file" <<'EOF'
invalid = value

[theme]
name = "dracula"
EOF
cp "$config_file" "$test_dir/invalid-config"

if run_migration; then fail "invalid Herdr config must leave the migration pending"; fi
cmp -s "$test_dir/invalid-config" "$config_file" || fail "failed validation leaves the config untouched"
[[ ! -e $config_file.bak.1234567890 ]] || fail "failed validation creates no misleading backup"
[[ ! -s $HERDR_RESTARTS ]] || fail "failed validation does not reload Herdr"
pass "Herdr migration fails closed when validation rejects the candidate"

reset_home
cat >"$config_file" <<'EOF'
[theme]
name = "rose-pine"
EOF

HERDR_RESTART_STATUS=1 run_migration
grep -Fxq 'name = "terminal"' "$config_file" || fail "reload failure keeps the valid migration"
[[ -f $config_file.bak.1234567890 ]] || fail "reload failure keeps the migration backup"
pass "Herdr migration survives a transient live reload failure"

for header in '["theme"]' "['theme']" '["th\u0065me"]'; do
  reset_home
  printf '%s\n"name" = "nord"\nauto_switch = false\n' "$header" >"$config_file"
  run_migration
  python3 - "$config_file" <<'PYTOML'
import sys, tomllib
with open(sys.argv[1], "rb") as file:
    config = tomllib.load(file)
assert config["theme"] == {"name": "terminal", "auto_switch": False}
PYTOML
done
pass "Herdr migration accepts equivalent quoted and escaped table headers"

reset_home
printf '["theme"]\nname = "nord"\n' >"$config_file"
cp "$config_file" "$test_dir/rejected-original"
if HERDR_CHECK_STATUS=1 run_migration; then fail "Herdr rejection must leave the migration pending"; fi
cmp -s "$config_file" "$test_dir/rejected-original" || fail "Herdr rejection changed the original"
[[ ! -s $HERDR_RESTARTS ]] || fail "Herdr rejection restarted the server"
pass "Herdr validation failure is retryable and preserves the original"
