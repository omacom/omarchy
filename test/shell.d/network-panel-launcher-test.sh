#!/bin/bash
#
# The network panel must stay reachable when the bar widget is gone: Setup >
# Network needs a Wi-Fi row, Apps needs a Wi-Fi launcher, and the migration
# must copy that launcher for existing users without clobbering one they already
# have.

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

desktop="$ROOT/applications/Wi-Fi.desktop"
menu="$ROOT/default/omarchy/omarchy-menu.jsonc"
migration="$ROOT/migrations/1788865922.sh"

[[ -f $desktop ]] || fail "Wi-Fi launcher is part of default application refresh"
grep -F 'Name=Wi-Fi' "$desktop" >/dev/null || fail "Wi-Fi launcher is named Wi-Fi"
grep -F 'Exec=omarchy-shell shell summon omarchy.network' "$desktop" >/dev/null || fail "Wi-Fi launcher summons the network panel"

wifi_row=$(grep '^  "setup.network.wifi":' "$menu") || fail "Setup > Network includes a Wi-Fi row"
[[ $wifi_row == *'omarchy-shell shell summon omarchy.network'* ]] || fail "Wi-Fi menu row summons the network panel"
[[ $wifi_row != *aliases* ]] || fail "new Wi-Fi menu row has no aliases"
pass "menu and desktop launch the network panel"

[[ -f $migration ]] || fail "existing installs get a Wi-Fi launcher migration"
if grep -q '^#!/' "$migration"; then
  fail "migration has no shebang"
fi

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

home="$test_dir/home"
omarchy_path="$test_dir/omarchy"
stub_bin="$test_dir/bin"
mkdir -p "$home/.local/share/applications" "$omarchy_path/applications" "$stub_bin"
cp "$desktop" "$omarchy_path/applications/Wi-Fi.desktop"

cat >"$stub_bin/update-desktop-database" <<'STUB'
#!/bin/bash
echo "$@" >>"${UPDATE_DESKTOP_CALLS:?}"
STUB
chmod +x "$stub_bin/update-desktop-database"

dest="$home/.local/share/applications/Wi-Fi.desktop"
update_calls="$test_dir/update-desktop-calls"

run_migration() {
  HOME="$home" OMARCHY_PATH="$omarchy_path" UPDATE_DESKTOP_CALLS="$update_calls" \
    PATH="$stub_bin:$PATH" \
    bash -euo pipefail "$migration"
}

rm -f "$dest" "$update_calls"
run_migration >/dev/null || fail "migration copies the Wi-Fi launcher when missing"
[[ -f $dest ]] || fail "migration installs Wi-Fi.desktop"
diff -q "$omarchy_path/applications/Wi-Fi.desktop" "$dest" >/dev/null || fail "migration copies the packaged launcher"
grep -F "$home/.local/share/applications" "$update_calls" >/dev/null || fail "migration refreshes the desktop database"
pass "migration installs the Wi-Fi launcher when it is missing"

printf 'KEEP\n' >"$dest"
rm -f "$update_calls"
run_migration >/dev/null || fail "migration is idempotent when the launcher already exists"
[[ $(cat "$dest") == KEEP ]] || fail "migration must not clobber an existing Wi-Fi launcher"
[[ ! -f $update_calls ]] || fail "migration must not refresh the desktop database when nothing changed"
pass "migration leaves an existing Wi-Fi launcher alone"
