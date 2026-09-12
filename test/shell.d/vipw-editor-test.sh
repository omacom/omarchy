#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

launch_editor="$ROOT/bin/omarchy-launch-editor"
sudoers_file="$ROOT/etc/sudoers.d/omarchy-vipw"
rule='Defaults!/usr/bin/vipw,/usr/bin/vigr env_keep += "EDITOR"'

# vipw and vigr fall back to /usr/bin/vi, which Omarchy does not ship, so the
# caller's EDITOR has to survive sudo for exactly these two commands.
rules=$(grep -vE '^[[:space:]]*(#|$)' "$sudoers_file")
[[ $rules == "$rule" ]] ||
  fail "vipw sudoers file keeps EDITOR for vipw and vigr and nothing else" "got: $rules"

if command -v visudo >/dev/null; then
  visudo -cf "$sudoers_file" >/dev/null || fail "vipw sudoers rule parses"
fi

pass "vipw sudoers rule keeps EDITOR for vipw and vigr"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin" "$test_tmp/home"

printf '#!/bin/bash\necho "inline $*"\n' >"$stub_bin/nvim"
printf '#!/bin/bash\necho "window $*"\n' >"$stub_bin/omarchy-launch-tui"
printf '#!/bin/bash\nexit 0\n' >"$stub_bin/omarchy-cmd-present"
chmod +x "$stub_bin"/*

launch() {
  HOME="$test_tmp/home" PATH="$stub_bin:$PATH" bash "$launch_editor" "$@"
}

# vipw and vigr keep only the first word of EDITOR, so the --inline flag is
# lost by the time the script runs as root; the missing session has to stand in
# for it.
result=$(WAYLAND_DISPLAY= launch /etc/group)
[[ $result == "inline /etc/group" ]] ||
  fail "launch-editor edits inline when there is no Wayland session" "got: $result"

result=$(WAYLAND_DISPLAY=wayland-1 launch /etc/group)
[[ $result == "window nvim /etc/group" ]] ||
  fail "launch-editor still opens a window inside a session" "got: $result"

result=$(WAYLAND_DISPLAY=wayland-1 launch --inline /etc/group)
[[ $result == "inline /etc/group" ]] ||
  fail "launch-editor still honors --inline inside a session" "got: $result"

pass "launch-editor falls back to inline editing without a Wayland session"
