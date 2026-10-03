#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

desktop="$ROOT/default/alacritty/Alacritty.desktop"
exec_count=$(grep -c '^Exec=omarchy-launch-alacritty$' "$desktop")
[[ $exec_count == 2 ]] || fail "shipped Alacritty desktop launches through omarchy-launch-alacritty" "count: $exec_count"
pass "shipped Alacritty desktop uses omarchy-launch-alacritty"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
log="$test_tmp/alacritty.log"
mkdir -p "$mock_bin"

cat >"$mock_bin/alacritty" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >>"${ALACRITTY_LOG:?}"
if [[ ${1:-} == msg && ${2:-} == create-window ]]; then
  exit "${ALACRITTY_MSG_RC:-0}"
fi
exit 0
SH
chmod +x "$mock_bin/alacritty"

run_launch() {
  rm -f "$log"
  PATH="$mock_bin:$PATH" ALACRITTY_LOG="$log" ALACRITTY_MSG_RC="$1" \
    "$ROOT/bin/omarchy-launch-alacritty" "${@:2}"
}

run_launch 0 --working-directory /tmp -e htop
[[ $(cat "$log") == "msg create-window --working-directory /tmp -e htop" ]] ||
  fail "launcher creates a window on the existing process" "$(cat "$log")"
pass "launcher uses msg create-window when an instance is running"

run_launch 1 --working-directory /tmp -e htop
mapfile -t lines <"$log"
[[ ${lines[0]} == "msg create-window --working-directory /tmp -e htop" ]] ||
  fail "launcher tries create-window first when no instance is running" "${lines[0]:-}"
[[ ${lines[1]} == "--working-directory /tmp -e htop" ]] ||
  fail "launcher falls back to starting Alacritty" "${lines[1]:-}"
pass "launcher starts Alacritty when create-window fails"

migration="$ROOT/migrations/1788799152.sh"
home="$test_tmp/home"
omarchy_path="$test_tmp/omarchy"
mkdir -p "$home/.local/share/applications" "$omarchy_path/default/alacritty"
printf 'NEW-LAUNCHER\n' >"$omarchy_path/default/alacritty/Alacritty.desktop"
printf 'OLD-LAUNCHER\n' >"$home/.local/share/applications/Alacritty.desktop"

HOME="$home" OMARCHY_PATH="$omarchy_path" bash -euo pipefail "$migration" >/dev/null
[[ $(cat "$home/.local/share/applications/Alacritty.desktop") == "NEW-LAUNCHER" ]] ||
  fail "migration refreshes an existing Alacritty desktop"
pass "migration refreshes the Alacritty desktop when present"

rm -f "$home/.local/share/applications/Alacritty.desktop"
HOME="$home" OMARCHY_PATH="$omarchy_path" bash -euo pipefail "$migration" >/dev/null
[[ ! -e $home/.local/share/applications/Alacritty.desktop ]] ||
  fail "migration does not create an Alacritty desktop that was not there"
pass "migration skips a missing Alacritty desktop"
