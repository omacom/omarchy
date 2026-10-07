#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin" "$test_tmp/home/.local/share/applications"

for helper in omarchy-pkg-add omarchy-pkg-drop update-desktop-database; do
  cat > "$test_tmp/bin/$helper" <<'SH'
#!/bin/bash
printf '%s %s\n' "${0##*/}" "$*" >> "$TEST_LOG"
SH
  chmod +x "$test_tmp/bin/$helper"
done

launcher="$test_tmp/home/.local/share/applications/Disk Usage.desktop"
printf '[Desktop Entry]\nExec=dua i /\n' > "$launcher"

for (( attempt = 0; attempt < 2; attempt++ )); do
  env HOME="$test_tmp/home" OMARCHY_PATH="$ROOT" TEST_LOG="$test_tmp/log" PATH="$test_tmp/bin:$PATH" \
    bash -euo pipefail "$ROOT/migrations/1791345484.sh"
  [[ ! -e $launcher ]] || fail "the migration removes the old Disk Usage launcher"
done
pass "the Disktree migration removes the old launcher and can run twice"

expected="omarchy-pkg-add disktree-bin
omarchy-pkg-drop dua-cli
update-desktop-database $test_tmp/home/.local/share/applications"
[[ $(cat "$test_tmp/log") == "$expected"$'\n'"$expected" ]] || fail "the migration installs Disktree before removing dua and refreshing launchers"
pass "the migration installs Disktree before removing dua and refreshing launchers"

rm -r "$test_tmp/home/.local/share/applications"
env HOME="$test_tmp/home" OMARCHY_PATH="$ROOT" TEST_LOG="$test_tmp/log" PATH="$test_tmp/bin:$PATH" \
  bash -euo pipefail "$ROOT/migrations/1791345484.sh"
[[ ! -d $test_tmp/home/.local/share/applications ]] || fail "the migration relies on the packaged Disktree launcher"
pass "the migration relies on the packaged Disktree launcher when no local launchers exist"
