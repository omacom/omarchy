#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export HOME="$test_tmp/home"
export TMPDIR="$test_tmp/tmp"
mkdir -p "$HOME" "$TMPDIR"

mock_bin="$test_tmp/bin"
mkdir -p "$mock_bin"

for stub in gtk-update-icon-cache omarchy-notification-send; do
  printf '#!/bin/bash\n:\n' >"$mock_bin/$stub"
  chmod +x "$mock_bin/$stub"
done

export PATH="$mock_bin:$PATH"

applications="$HOME/.local/share/applications"

install_tui() {
  bash "$ROOT/bin/omarchy-tui-install" "$@" >/dev/null
}

run_install() {
  bash "$ROOT/bin/omarchy-tui-install" "$@"
}

run_remove() {
  HOME="$HOME" PATH="$PATH" OMARCHY_REMOVE_NOTIFY=false \
    bash "$ROOT/bin/omarchy-tui-remove" "$@"
}

desktop_value() {
  sed -n "s/^$2=//p" "$1" | head -1
}

install_tui Example htop tile someicon
example_file="$applications/Example.desktop"

[[ -f $example_file ]] || fail "tui install writes a desktop entry"
(( $(grep -c '^Exec=' "$example_file") == 1 )) ||
  fail "a normal tui install writes exactly one Exec line" "$(cat "$example_file")"
[[ $(desktop_value "$example_file" Exec) == 'xdg-terminal-exec --app-id=TUI.tile -e htop' ]] ||
  fail "tui install writes the expected Exec line" "$(desktop_value "$example_file" Exec)"
pass "a normal tui install writes exactly one Exec line"

install_tui 'Quoted App' "bash -c 'dust; read -n 1 -s'" tile someicon
quoted_file="$applications/Quoted App.desktop"

(( $(grep -c '^Exec=' "$quoted_file") == 1 )) ||
  fail "a quoted command still yields exactly one Exec line" "$(cat "$quoted_file")"
[[ $(desktop_value "$quoted_file" Exec) == *"bash -c 'dust; read -n 1 -s'"* ]] ||
  fail "a quoted command keeps its quotes in Exec" "$(desktop_value "$quoted_file" Exec)"
pass "a quoted command keeps its quotes and one Exec line"

output=$(run_install "http://example.test/oops" htop tile someicon 2>&1) &&
  fail "tui install rejects a name containing a slash"
[[ $output == *"App name cannot contain '/'"* ]] ||
  fail "tui install says why it refused a slashed name" "$output"
[[ -e "$applications/http:" ]] &&
  fail "tui install does not create a directory from a slashed name"
pass "tui install rejects a name that would nest the launcher"

if run_install "../../../../escaped" htop tile someicon >/dev/null 2>&1; then
  fail "tui install rejects a name that climbs out of the applications directory"
fi
[[ -e "$test_tmp/escaped.desktop" ]] &&
  fail "tui install writes no launcher outside the applications directory"
pass "tui install refuses a name that would escape the applications directory"

inject_name=$(printf 'Inject\nExec=evil')
install_tui "$inject_name" htop tile someicon
inject_file="$applications/$inject_name.desktop"

(( $(grep -c '^Exec=' "$inject_file") == 1 )) ||
  fail "a newline in the app name cannot inject a second Exec" "$(cat "$inject_file")"
pass "a newline in the app name cannot inject a second Exec"

inject_exec=$(printf 'htop\nExec=evil')
install_tui 'Inject Exec' "$inject_exec" tile someicon
inject_exec_file="$applications/Inject Exec.desktop"

(( $(grep -c '^Exec=' "$inject_exec_file") == 1 )) ||
  fail "a newline in the command cannot inject a second Exec" "$(cat "$inject_exec_file")"
pass "a newline in the command cannot inject a second Exec"

inject_icon=$(printf 'someicon\nExec=evil')
install_tui 'Inject Icon' htop tile "$inject_icon"
inject_icon_file="$applications/Inject Icon.desktop"

(( $(grep -c '^Exec=' "$inject_icon_file") == 1 )) ||
  fail "a newline in the icon name cannot inject a second Exec" "$(cat "$inject_icon_file")"
pass "a newline in the icon name cannot inject a second Exec"

mkdir -p "$applications/http:/127.0.0.1:4000"
icons_dir="$HOME/.local/share/icons/hicolor/256x256/apps"
legacy_icon="http-127-0-0-1-4000"
mkdir -p "$icons_dir"
touch "$icons_dir/$legacy_icon.png"
cat >"$applications/http:/127.0.0.1:4000/.desktop" <<'DESKTOP'
[Desktop Entry]
Name=http://127.0.0.1:4000
Exec=xdg-terminal-exec --app-id=TUI.tile -e htop
Type=Application
DESKTOP

run_remove "127.0.0.1:4000" >/dev/null
[[ -f "$applications/http:/127.0.0.1:4000/.desktop" ]] &&
  fail "tui remove deletes a launcher left nested by an older install"
[[ -f "$icons_dir/$legacy_icon.png" ]] &&
  fail "tui remove deletes the icon named for the launcher's full Name field"
pass "tui remove reaches a nested legacy launcher and its icon"
