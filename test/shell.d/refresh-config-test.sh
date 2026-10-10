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

HOME="$home" OMARCHY_PATH="$omarchy_path" "$ROOT/bin/omarchy-refresh-config" hypr/bindings.lua >/dev/null

cmp -s "$omarchy_path/config/hypr/bindings.lua" "$home/.config/hypr/bindings.lua" ||
  fail "refresh-config copies from OMARCHY_PATH/config"

backup=$(find "$home/.config/hypr" -name 'bindings.lua.bak.*' -print -quit)
[[ -n $backup ]] || fail "refresh-config backs up replaced user config"
grep -Fq -- '-- existing user config' "$backup" ||
  fail "refresh-config backup contains previous user config"

pass "refresh-config copies from OMARCHY_PATH/config and backs up existing files"

if HOME="$home" OMARCHY_PATH="$omarchy_path" "$ROOT/bin/omarchy-refresh-config" hypr/missing.lua >"$tmpdir/out" 2>"$tmpdir/err"; then
  fail "refresh-config rejects configs missing from OMARCHY_PATH/config"
fi

grep -Fq 'Not a shipped user config: hypr/missing.lua' "$tmpdir/err" ||
  fail "refresh-config reports missing shipped config"

pass "refresh-config validates against OMARCHY_PATH/config"

# Test copy failure returns non-zero status
mkdir -p "$home/.config/readonly" "$omarchy_path/config/readonly"
echo "data" >"$omarchy_path/config/readonly/file.conf"
chmod 555 "$home/.config/readonly"
if HOME="$home" OMARCHY_PATH="$omarchy_path" "$ROOT/bin/omarchy-refresh-config" readonly/file.conf >/dev/null 2>&1; then
  chmod 755 "$home/.config/readonly"
  fail "refresh-config fails when target cannot be written"
fi
chmod 755 "$home/.config/readonly"
pass "refresh-config propagates copy failures"

# shell.json permissions test (0600 on created file and backup)
mkdir -p "$home/.config/omarchy" "$omarchy_path/config/omarchy"
echo '{"version":1,"fresh":true}' >"$omarchy_path/config/omarchy/shell.json"
(
  umask 022
  HOME="$home" OMARCHY_PATH="$omarchy_path" "$ROOT/bin/omarchy-refresh-config" omarchy/shell.json >/dev/null
)
mode=$(stat -c '%a' "$home/.config/omarchy/shell.json")
[[ $mode == "600" ]] || fail "refresh-config creates shell.json with mode 0600 under umask 022" "mode: $mode"
pass "refresh-config creates shell.json with mode 0600"

# Now simulate existing shell.json with world-readable 0644 permissions being replaced and backed up
echo '{"version":1,"old":true}' >"$home/.config/omarchy/shell.json"
chmod 644 "$home/.config/omarchy/shell.json"
echo '{"version":1,"updated":true}' >"$omarchy_path/config/omarchy/shell.json"
(
  umask 022
  HOME="$home" OMARCHY_PATH="$omarchy_path" "$ROOT/bin/omarchy-refresh-config" omarchy/shell.json >/dev/null
)
mode_new=$(stat -c '%a' "$home/.config/omarchy/shell.json")
[[ $mode_new == "600" ]] || fail "refresh-config ensures updated shell.json has mode 0600" "mode: $mode_new"
backup_shell=$(find "$home/.config/omarchy" -name 'shell.json.bak.*' -print -quit)
[[ -n $backup_shell ]] || fail "refresh-config backs up previous shell.json"
mode_bak=$(stat -c '%a' "$backup_shell")
[[ $mode_bak == "600" ]] || fail "refresh-config ensures shell.json backup has mode 0600" "mode: $mode_bak"
pass "refresh-config secures updated shell.json and its backup with mode 0600"
