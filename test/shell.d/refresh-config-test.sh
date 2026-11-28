#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

home="$tmpdir/home"
omarchy_path="$tmpdir/omarchy"

mkdir -p "$home/.config/hypr" "$omarchy_path/config/hypr"

cat >"$omarchy_path/config/hypr/bindings.lua" <<'EOF'
-- refreshed from OMARCHY_PATH
EOF

cat >"$home/.config/hypr/bindings.lua" <<'EOF'
-- existing user config
EOF

mkdir "$tmpdir/bin"
printf '#!/bin/bash\necho 1700000000\n' >"$tmpdir/bin/date"
chmod +x "$tmpdir/bin/date"

refresh_bindings() {
  PATH="$tmpdir/bin:$PATH" HOME="$home" OMARCHY_PATH="$omarchy_path" "$ROOT/bin/omarchy-refresh-config" hypr/bindings.lua
}

refresh_bindings >/dev/null || fail "initial config refresh"

cmp -s "$omarchy_path/config/hypr/bindings.lua" "$home/.config/hypr/bindings.lua" ||
  fail "refresh-config copies from OMARCHY_PATH/config"

backup=$(find "$home/.config/hypr" -name 'bindings.lua.bak.*' -print -quit)
[[ -n $backup ]] || fail "refresh-config backs up replaced user config"
grep -Fq -- '-- existing user config' "$backup" ||
  fail "refresh-config backup contains previous user config"

pass "refresh-config copies from OMARCHY_PATH/config and backs up existing files"

refresh_bindings >/dev/null || fail "refreshing an unchanged config"
grep -Fq -- '-- existing user config' "$backup" || fail "repeat refresh preserves the first backup"

live_config="$home/.config/hypr/bindings.lua"
echo 'second edit' >"$live_config"
refresh_bindings >/dev/null || fail "refreshing a second edit in the same second"
grep -Fq -- '-- existing user config' "$backup" || fail "second edit preserves the first backup"
grep -Fxq 'second edit' "$live_config".bak.* || fail "second edit gets its own backup"

pass "repeated refreshes preserve each version"

cat >"$tmpdir/bin/cp" <<'EOF'
#!/bin/bash
[[ ${!#} == *.bak.* ]] && exit 1
exec /usr/bin/cp "$@"
EOF
chmod +x "$tmpdir/bin/cp"

echo 'keep this edit' >"$live_config"
if refresh_bindings >/dev/null 2>&1; then
  fail "refresh-config reports a failed backup"
fi
grep -Fxq 'keep this edit' "$live_config" || fail "failed backup leaves the live config intact"

pass "refresh-config stops on backup failure"

cat >"$tmpdir/bin/cp" <<'EOF'
#!/bin/bash
[[ ${!#} != *.bak.* ]] && exit 1
exec /usr/bin/cp "$@"
EOF

if refresh_bindings >/dev/null 2>&1; then
  fail "refresh-config reports a failed replacement"
fi
grep -Fxq 'keep this edit' "$live_config".bak.* || fail "failed replacement preserves the completed backup"

pass "refresh-config preserves the backup on replacement failure"

if HOME="$home" OMARCHY_PATH="$omarchy_path" "$ROOT/bin/omarchy-refresh-config" hypr/missing.lua >"$tmpdir/out" 2>"$tmpdir/err"; then
  fail "refresh-config rejects configs missing from OMARCHY_PATH/config"
fi

grep -Fq 'Not a shipped user config: hypr/missing.lua' "$tmpdir/err" ||
  fail "refresh-config reports missing shipped config"

pass "refresh-config validates against OMARCHY_PATH/config"

# Both sides of a traversal have to exist for the escape to be live: without a
# mirrored source the pre-existing "Not a shipped user config" check rejects it
# anyway, and the test passes with the guard deleted.
escape="$home/escape"
echo "do not touch" >"$escape"
echo "-- traversal source" >"$omarchy_path/escape"

refuses() {
  local config_file="$1"

  if HOME="$home" OMARCHY_PATH="$omarchy_path" "$ROOT/bin/omarchy-refresh-config" "$config_file" >"$tmpdir/out" 2>"$tmpdir/err"; then
    fail "refresh-config rejects $config_file"
  fi

  grep -Fq "Invalid config path: $config_file" "$tmpdir/err" ||
    fail "refresh-config reports $config_file as an invalid config path" "$(cat "$tmpdir/err")"

  [[ $(cat "$escape") == "do not touch" ]] ||
    fail "refresh-config leaves files outside .config untouched: $config_file"
}

refuses ../escape
refuses hypr/../../escape
refuses ..
refuses hypr/..
refuses /etc/passwd

pass "refresh-config rejects paths escaping .config"
