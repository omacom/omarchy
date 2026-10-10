#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

export HOME="$test_tmp/home"
applications="$HOME/.local/share/applications"
mkdir -p "$applications"

# curl/file are unused when the icon is a plain name.
install_tui() {
  bash "$ROOT/bin/omarchy-tui-install" "$@" >/dev/null
}

desktop_value() {
  sed -n "s/^$2=//p" "$1" | head -1
}

# A slash in the name would write outside applications/ (e.g. into autostart).
if install_tui '../autostart/pwn' 'true' float someicon 2>"$test_tmp/slash.err"; then
  fail "tui install must refuse a name containing /"
fi
grep -F "App name cannot contain '/'" "$test_tmp/slash.err" >/dev/null ||
  fail "tui install explains a name containing /" "$(cat "$test_tmp/slash.err")"
pass "tui install refuses a name containing /"

# A newline in a value must not be able to start a second key line.
inject_name=$(printf 'Inject\nExec=evil')
install_tui "$inject_name" 'true' float someicon
inject_file="$applications/$inject_name.desktop"

(( $(grep -c '^Exec=' "$inject_file") == 1 )) ||
  fail "a newline in the app name cannot inject a second Exec" "$(cat "$inject_file")"
pass "a newline in the app name cannot inject a second Exec"

install_tui 'Quoted TUI' 'echo hi; id' float someicon
quoted_file="$applications/Quoted TUI.desktop"
exec_line=$(desktop_value "$quoted_file" Exec)

[[ $exec_line == *'"echo" "hi;" "id"'* ]] ||
  fail "Exec quotes each command argument separately" "$exec_line"
pass "Exec quotes each command argument separately"

require_command python3
commands=("/bin/echo hello" '/bin/echo "hello world"' "printf '%s\\n' '\$HOME'" 'bash -c "printf first; echo second"')
outputs=($'hello\n' $'hello world\n' $'$HOME\n' $'firstsecond\n')
commands+=("/bin/echo '%f'" "/bin/echo '\$(touch $test_tmp/unexpected)'")
outputs+=($'%f\n' "\$(touch $test_tmp/unexpected)"$'\n')
for index in "${!commands[@]}"; do
  install_tui "Parsed $index" "${commands[$index]}" float someicon
  python3 "$ROOT/test/shell.d/tui-exec-check.py" "$applications/Parsed $index.desktop" "${commands[$index]}" "${outputs[$index]}" ||
    fail "parsed desktop command executes with its intended arguments"
done
[[ ! -e $test_tmp/unexpected ]] || fail "quoted substitutions must not execute"
pass "GLib-parsed launch commands preserve arguments, quoting and shell syntax"

if install_tui 'Invalid command' 'echo "unterminated' float someicon 2>"$test_tmp/parse.err"; then
  fail "unbalanced command quotes must be rejected"
fi
[[ ! -e $applications/'Invalid command.desktop' ]] || fail "invalid command must not publish a launcher"
pass "malformed command quoting is rejected before publishing a launcher"

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"
cat >"$stub_bin/curl" <<'SH'
#!/bin/bash
while (( $# )); do
  if [[ $1 == -o ]]; then
    cp "$OMARCHY_TEST_ICON_INPUT" "$2"
    exit "${OMARCHY_TEST_CURL_EXIT:-0}"
  fi
  shift
done
exit 99
SH
printf '#!/bin/bash\nexit 0\n' >"$stub_bin/gtk-update-icon-cache"
chmod +x "$stub_bin/"*
export PATH="$stub_bin:$PATH"
export OMARCHY_TEST_ICON_INPUT="$test_tmp/icon-input"
printf 'not an image\n' >"$OMARCHY_TEST_ICON_INPUT"
icon_dir="$HOME/.local/share/icons/hicolor/256x256/apps"
mkdir -p "$icon_dir"
printf 'existing icon\n' >"$icon_dir/remote.png"
cp "$icon_dir/remote.png" "$test_tmp/old-icon"
if install_tui Remote true float https://example.invalid/icon.png; then
  fail "a non-image download must be rejected"
fi
cmp -s "$icon_dir/remote.png" "$test_tmp/old-icon" || fail "a rejected image must preserve the old icon"
[[ ! -e $applications/Remote.desktop ]] || fail "a rejected icon must not create a launcher"
pass "rejected downloaded images preserve existing icons"

if OMARCHY_TEST_CURL_EXIT=22 install_tui New true float https://example.invalid/icon.png; then
  fail "a partial failed download must be rejected"
fi
[[ ! -e $icon_dir/new.png ]] || fail "a failed download must not publish an icon"
(( $(find "$icon_dir" -type f | wc -l) == 1 )) || fail "download failures must remove their temporary files"
pass "failed downloads leave no orphaned icons or temporary files"

python3 - "$OMARCHY_TEST_ICON_INPUT" <<'PY'
import base64
import pathlib
import sys
pathlib.Path(sys.argv[1]).write_bytes(base64.b64decode('iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+jRZkAAAAASUVORK5CYII='))
PY
install_tui Remote true float https://example.invalid/icon.png
cmp -s "$icon_dir/remote.png" "$OMARCHY_TEST_ICON_INPUT" || fail "validated image content is published"
[[ -f $applications/Remote.desktop ]] || fail "valid downloaded icon permits the launcher"
pass "validated downloads replace the icon and create the launcher"
