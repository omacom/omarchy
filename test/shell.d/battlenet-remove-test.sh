#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir="$(mktemp -d)"
trap 'rm -rf "$tmp_dir"' EXIT

mkdir -p "$tmp_dir/bin" "$tmp_dir/home"
export TEST_LOG="$tmp_dir/log"
export PATH="$tmp_dir/bin:$PATH"
export HOME="$tmp_dir/home"

cat >"$tmp_dir/bin/pkill" <<'SCRIPT'
#!/bin/bash
printf 'pkill:%s\n' "$*" >>"$TEST_LOG"
exit 0
SCRIPT

printf '#!/bin/bash\nexit 0\n' >"$tmp_dir/bin/sleep"

cat >"$tmp_dir/bin/gum" <<'SCRIPT'
#!/bin/bash
printf 'gum:%s\n' "$*" >>"$TEST_LOG"
exit 0
SCRIPT

cat >"$tmp_dir/bin/omarchy-i18n" <<'SCRIPT'
#!/bin/bash
echo "$*"
SCRIPT

cat >"$tmp_dir/bin/omarchy-pkg-present" <<'SCRIPT'
#!/bin/bash
printf 'omarchy-pkg-present:%s\n' "$*" >>"$TEST_LOG"
exit 0
SCRIPT

cat >"$tmp_dir/bin/omarchy-pkg-drop" <<'SCRIPT'
#!/bin/bash
printf 'omarchy-pkg-drop:%s\n' "$*" >>"$TEST_LOG"
exit 0
SCRIPT

cat >"$tmp_dir/bin/update-desktop-database" <<'SCRIPT'
#!/bin/bash
printf 'update-desktop-database:%s\n' "$*" >>"$TEST_LOG"
exit 0
SCRIPT

cat >"$tmp_dir/bin/omarchy-install-gaming-gpu-lib32" <<'SCRIPT'
#!/bin/bash
printf 'omarchy-install-gaming-gpu-lib32:%s\n' "$*" >>"$TEST_LOG"
exit 0
SCRIPT

cat >"$tmp_dir/bin/omarchy-pkg-add" <<'SCRIPT'
#!/bin/bash
printf 'omarchy-pkg-add:%s\n' "$*" >>"$TEST_LOG"
exit 0
SCRIPT

cat >"$tmp_dir/bin/curl" <<'SCRIPT'
#!/bin/bash
printf 'curl:%s\n' "$*" >>"$TEST_LOG"
exit 0
SCRIPT

cat >"$tmp_dir/bin/setsid" <<'SCRIPT'
#!/bin/bash
printf 'setsid:%s\n' "$*" >>"$TEST_LOG"
exit 0
SCRIPT

chmod +x "$tmp_dir/bin/"*

prefix="$HOME/Games/battlenet"
installer="$HOME/.cache/omarchy/Battle.net-Setup.exe"

# 1. Removing Battle.net stops both the prefix wine processes and the detached installer.
mkdir -p "$prefix/drive_c"
mkdir -p "$(dirname "$installer")"
touch "$installer"
mkdir -p "$HOME/.local/share/applications"
touch "$HOME/.local/share/applications/battlenet.desktop"

: >"$TEST_LOG"
"$ROOT/bin/omarchy-remove-gaming-battlenet"

grep -F -q "pkill:-f $prefix" "$TEST_LOG" ||
  fail "Battle.net removal stops running prefix processes" "pkill was not called for prefix path"
grep -F -q "pkill:-f $installer" "$TEST_LOG" ||
  fail "Battle.net removal stops the running installer" "pkill was not called for installer path"
[[ ! -e $prefix ]] ||
  fail "Battle.net removal deletes the prefix directory" "prefix directory still exists"
[[ ! -e $installer ]] ||
  fail "Battle.net removal deletes the cached installer" "cached installer still exists"
pass "Battle.net removal stops the running installer and removes the prefix"

# 2. Wiping a partial install during installation also stops any running installer.
mkdir -p "$prefix/drive_c"
touch "$prefix/drive_c/stale-marker"
mkdir -p "$(dirname "$installer")"
touch "$installer"

: >"$TEST_LOG"
"$ROOT/bin/omarchy-install-gaming-battlenet"

grep -F -q "pkill:-f $prefix" "$TEST_LOG" ||
  fail "Battle.net partial install wipe stops running prefix processes" "pkill was not called for prefix path"
grep -F -q "pkill:-f $installer" "$TEST_LOG" ||
  fail "Battle.net partial install wipe stops the running installer" "pkill was not called for installer path"
[[ ! -e $prefix/drive_c/stale-marker ]] ||
  fail "Battle.net partial install wipe deletes stale prefix contents" "stale marker still exists"
pass "Battle.net partial install wipe stops the running installer and wipes the prefix"
