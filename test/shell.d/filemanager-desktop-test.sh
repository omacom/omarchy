#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command uwsm
require_command xdg-mime
require_command python3
export FM_UWSM
FM_UWSM=$(command -v uwsm)

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
export XDG_CONFIG_HOME="$test_tmp/config" XDG_CONFIG_DIRS="$test_tmp/system-config"
export XDG_DATA_HOME="$test_tmp/data" XDG_DATA_DIRS="$test_tmp/system-data"
export XDG_CACHE_HOME="$test_tmp/cache" XDG_CURRENT_DESKTOP=OmarchyFilemanagerTest
export FM_ARGS="$test_tmp/args" FM_TERMINAL_ARGS="$test_tmp/terminal-args"
mkdir -p "$test_tmp/bin" "$XDG_CONFIG_HOME" "$XDG_CONFIG_DIRS" "$XDG_DATA_HOME/applications" "$XDG_DATA_DIRS"
export PATH="$test_tmp/bin:$ROOT/bin:$PATH"

# Keep UWSM's real desktop-entry and terminal resolution. Replace only the
# app-daemon transport and process supervision so no session or GUI is needed.
cat >"$test_tmp/bin/uwsm-app" <<'EOF'
#!/bin/bash
exec "$FM_UWSM" app -t scope "$@"
EOF
cat >"$test_tmp/bin/setsid" <<'EOF'
#!/bin/bash
exec "$@"
EOF
cat >"$test_tmp/bin/systemd-run" <<'EOF'
#!/bin/bash
while (($# > 0)) && [[ $1 != "--" ]]; do shift; done
[[ ${1:-} == "--" ]] || exit 2
shift
exec "$@"
EOF
cat >"$test_tmp/bin/fm-recorder" <<'EOF'
#!/bin/bash
printf '%s\0' "$@" >"$FM_ARGS"
EOF
cat >"$test_tmp/bin/fm-terminal" <<'EOF'
#!/bin/bash
printf '%s\0' "$@" >"$FM_TERMINAL_ARGS"
[[ $1 == "--terminal-fixed" && $2 == "--execute" ]] || exit 2
shift 2
exec "$@"
EOF
chmod +x "$test_tmp/bin/"*

cat >"$XDG_DATA_HOME/applications/org.example.Terminal.desktop" <<'EOF'
[Desktop Entry]
Type=Application
Name=Recording Terminal
Exec=fm-terminal --terminal-fixed
Categories=System;TerminalEmulator;
X-TerminalArgExec=--execute
EOF
echo org.example.Terminal.desktop >"$XDG_CONFIG_HOME/xdg-terminals.list"

directory="$test_tmp/a folder with 'quotes' and \$(literal)"
mkdir -p "$directory"
directory_uri=$(python3 -c 'from pathlib import Path; import sys; print(Path(sys.argv[1]).as_uri())' "$directory")

for terminal in false true; do
  for field in f F u U; do
    desktop_id="org.example.Files-$terminal-$field.desktop"
    cat >"$XDG_DATA_HOME/applications/$desktop_id" <<EOF
[Desktop Entry]
Type=Application
Name=Recording File Manager
Exec=fm-recorder --fixed "fixed argument" %$field
Terminal=$terminal
MimeType=inode/directory;
EOF
    omarchy-default-filemanager "$desktop_id"
    rm -f "$FM_ARGS" "$FM_TERMINAL_ARGS"
    omarchy-launch-filemanager "$directory"
    [[ -f $FM_ARGS ]] || fail "UWSM launches the recorder for %$field, Terminal=$terminal"
    mapfile -d '' -t actual <"$FM_ARGS"
    expected=$directory
    if [[ $field == "u" || $field == "U" ]]; then expected=$directory_uri; fi
    [[ ${#actual[@]} == 3 && ${actual[0]} == "--fixed" && ${actual[1]} == "fixed argument" && ${actual[2]} == "$expected" ]] ||
      fail "UWSM preserves fixed Exec arguments and the folder for %$field, Terminal=$terminal"
    if [[ $terminal == "true" ]]; then
      [[ -f $FM_TERMINAL_ARGS ]] || fail "Terminal=true goes through the selected terminal"
      mapfile -d '' -t terminal_actual <"$FM_TERMINAL_ARGS"
      [[ ${#terminal_actual[@]} == 6 && ${terminal_actual[2]} == "fm-recorder" && ${terminal_actual[5]} == "$expected" ]] ||
        fail "the terminal receives the recorder and folder as separate arguments"
    else
      [[ ! -e $FM_TERMINAL_ARGS ]] || fail "Terminal=false does not open a terminal"
    fi
    pass "real UWSM expands %$field with fixed Exec arguments and Terminal=$terminal"
  done
done
