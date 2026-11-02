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

# A directory an elevated run left owned by root refuses the copy. Rather than
# cp's bare "Permission denied", the directory, its owner and the repair are
# named, and nothing is written. Root writes anywhere, so the case needs a user.
if (( EUID == 0 )); then
  skip "running as root, which every directory lets write; skipping the unwritable-directory check"
else
  mkdir -p "$home/.config/wireplumber" "$omarchy_path/config/wireplumber/wireplumber.conf.d"
  echo 'monitor.alsa.rules = []' >"$omarchy_path/config/wireplumber/wireplumber.conf.d/kef.conf"
  chmod 555 "$home/.config/wireplumber"
  # The directory can't be given to root here; stat answers as if it had been.
  mkdir -p "$tmpdir/bin"
  printf '#!/bin/bash\necho root\n' >"$tmpdir/bin/stat"
  chmod +x "$tmpdir/bin/stat"
  if PATH="$tmpdir/bin:$PATH" HOME="$home" OMARCHY_PATH="$omarchy_path" "$ROOT/bin/omarchy-refresh-config" \
    wireplumber/wireplumber.conf.d/kef.conf >"$tmpdir/out" 2>"$tmpdir/err"; then
    fail "refresh-config fails when the destination directory is not writable"
  fi
  grep -Fq "$home/.config/wireplumber is owned by root, so wireplumber/wireplumber.conf.d/kef.conf cannot be refreshed. Run: sudo chown -R $(id -un): \"$home/.config/wireplumber\"" "$tmpdir/err" ||
    fail "refresh-config names the root-owned directory and the chown that repairs it" "$(cat "$tmpdir/err")"
  [[ ! -e $home/.config/wireplumber/wireplumber.conf.d ]] || fail "refresh-config writes nothing into a directory it cannot write"
  chmod 755 "$home/.config/wireplumber"
  pass "refresh-config names a root-owned directory and its repair instead of failing on the copy"
fi
