#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT
stub_bin="$test_dir/bin"
calls="$test_dir/pacman-calls"
helper_calls="$test_dir/helper-calls"
mkdir -p "$stub_bin"

cat >"$stub_bin/pacman" <<'SH'
#!/bin/bash
if [[ ${1:-} == "-Slq" ]]; then
  printf '%s\n' ripgrep fd
else
  printf '<%s>\n' "$@" >"$PACMAN_CALLS"
fi
SH
cat >"$stub_bin/fzf" <<'SH'
#!/bin/bash
cat >/dev/null
printf '%s' "${FZF_OUTPUT:-}"
exit "${FZF_STATUS:-0}"
SH
cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH
cat >"$stub_bin/omarchy-sudo-keepalive" <<'SH'
#!/bin/bash
printf 'keepalive\n' >>"$HELPER_CALLS"
SH
cat >"$stub_bin/omarchy-show-done" <<'SH'
#!/bin/bash
printf 'done\n' >>"$HELPER_CALLS"
SH
chmod +x "$stub_bin"/*

run_picker() {
  : >"$calls"
  : >"$helper_calls"
  FZF_OUTPUT="$1" \
    FZF_STATUS="${2:-0}" \
    PACMAN_CALLS="$calls" \
    HELPER_CALLS="$helper_calls" \
    PATH="$stub_bin:$PATH" \
    bash -euo pipefail "$ROOT/bin/omarchy-pkg-install"
}

run_picker $'ripgrep\nfd\n'
expected=$'<-S>\n<--noconfirm>\n<-->\n<ripgrep>\n<fd>'
[[ $(cat "$calls") == "$expected" ]] || fail "selected packages are passed to pacman as separate targets" "$(cat "$calls")"
pass "selected packages are passed to pacman as separate targets"

run_picker $'--config\n/tmp/injected.conf\nextra package\n'
expected=$'<-S>\n<--noconfirm>\n<-->\n<--config>\n</tmp/injected.conf>\n<extra package>'
[[ $(cat "$calls") == "$expected" ]] || fail "picker output cannot become pacman options or extra arguments" "$(cat "$calls")"
pass "picker output cannot become pacman options or extra arguments"

run_picker "" 130 || fail "cancelling the picker exits cleanly"
[[ ! -s $calls && ! -s $helper_calls ]] ||
  fail "cancelling the picker does not invoke install helpers" "$(cat "$calls" "$helper_calls")"
pass "cancelling the picker exits cleanly without invoking install helpers"
