#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

default_config="$ROOT/default/voxtype/config.toml"
fixtures="$ROOT/test/shell.d/fixtures/voxtype-shipped-configs"
migration=$(grep -l 'Paste voxtype dictation' "$ROOT"/migrations/*.sh)
test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

grep -Fxq 'mode = "paste"' "$default_config" || fail "New installs paste dictation"
grep -Fxq 'paste_keys = "shift+insert"' "$default_config" || fail "New installs paste with Shift+Insert"

mkdir -p "$test_dir/bin"

# Never touch the real daemon: record restarts and report a scripted status.
cat >"$test_dir/bin/systemctl" <<'STUB'
#!/bin/bash
[[ $* == *is-active* ]] && exit 0
echo "$*" >>"$RESTARTS"
STUB
cat >"$test_dir/bin/voxtype" <<'STUB'
#!/bin/bash
echo "$VOXTYPE_STATUS"
STUB
chmod +x "$test_dir/bin/"*

export RESTARTS="$test_dir/restarts"

home="$test_dir/home"
config="$home/.config/voxtype/config.toml"
mkdir -p "$(dirname "$config")"

run_migration() {
  : >"$RESTARTS"
  HOME="$home" XDG_CONFIG_HOME="$home/.config" OMARCHY_PATH="$ROOT" PATH="$test_dir/bin:$PATH" \
    VOXTYPE_STATUS="${1:-idle}" bash -euo pipefail "$migration" >/dev/null
}

# Every config Omarchy ever shipped, untouched, gets the new default.
for shipped in "$fixtures"/*.toml; do
  cp "$shipped" "$config"
  run_migration
  cmp -s "$config" "$default_config" || fail "Untouched $(basename "$shipped") gets the new default"
  grep -q 'restart voxtype.service' "$RESTARTS" || fail "An idle daemon restarts to apply the change"
done

# A second run changes nothing: the new default is not a shipped config.
run_migration
cmp -s "$config" "$default_config" || fail "A second run changes nothing"
[[ ! -s $RESTARTS ]] || fail "A second run does not restart the daemon"

# A busy daemon gets the new config but is not restarted mid-dictation.
cp "$fixtures/14552.toml" "$config"
run_migration recording
cmp -s "$config" "$default_config" || fail "A busy daemon still gets the new config"
[[ ! -s $RESTARTS ]] || fail "A busy daemon is not restarted mid-dictation"

# Any edit means someone chose their settings: a changed model, a changed
# comment, or a mode already switched by hand.
for edit in 's/^model = "base.en"/model = "small.en"/' 's/^# Fall back to clipboard/# fall back to clipboard/' 's/^mode = "type"/mode = "clipboard"/'; do
  sed "$edit" "$fixtures/14552.toml" >"$config"
  cmp -s "$config" "$fixtures/14552.toml" && fail "Fixture edit '$edit' changed nothing"
  cp "$config" "$test_dir/edited"
  run_migration
  cmp -s "$config" "$test_dir/edited" || fail "An edited config is left alone ($edit)"
done

rm "$config"
run_migration
[[ ! -e $config ]] || fail "A missing config is not created"

pass "Voxtype pastes dictation by default and untouched shipped configs switch once"
