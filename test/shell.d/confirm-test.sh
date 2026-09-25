#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

grep -Fq 'omarchy-confirm "Continue with update?"' "$ROOT/bin/omarchy-update-confirm" ||
  fail "update confirm uses the mouse-capable helper"
if grep -Fq 'gum confirm' "$ROOT/bin/omarchy-update-confirm"; then
  fail "update confirm no longer calls gum confirm"
fi
pass "update confirm uses the mouse-capable helper"

grep -Fq 'omarchy-confirm "$1"' "$ROOT/bin/omarchy-update-restart" ||
  fail "update restart prompt uses the mouse-capable helper"
if grep -Fq 'gum confirm' "$ROOT/bin/omarchy-update-restart"; then
  fail "update restart prompt no longer calls gum confirm"
fi
pass "update restart prompt uses the mouse-capable helper"

helper="$ROOT/bin/omarchy-confirm"
grep -Fq -- '--bind "left-click:accept"' "$helper" ||
  fail "confirm binds left-click to accept"
grep -Fq -- '--no-input' "$helper" ||
  fail "confirm hides the fzf query line"
grep -Fq -- '--height=6' "$helper" ||
  fail "confirm stays inline so script(1) does not log a fullscreen TUI"
pass "confirm is an inline fzf widget with mouse accept"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

cat >"$stub_bin/fzf" <<'SH'
#!/bin/bash
printf '%s\n' "$@" >"$FZF_ARGS"
if [[ ${FZF_EXIT:-0} != 0 ]]; then
  exit "$FZF_EXIT"
fi
printf '%s\n' "${FZF_CHOICE:-Yes}"
SH
chmod +x "$stub_bin/fzf"

run_confirm() {
  OMARCHY_PATH="$ROOT" PATH="$stub_bin:$PATH" FZF_ARGS="$test_tmp/args" \
    "$ROOT/bin/omarchy-confirm" "$@"
}

FZF_CHOICE=Yes run_confirm "Continue with update?" >/dev/null
grep -Fq -- '--bind' "$test_tmp/args" || fail "confirm passes bind flags to fzf"
grep -Fq -- 'left-click:accept' "$test_tmp/args" || fail "confirm asks fzf to accept a left click"
grep -Fq -- '--no-input' "$test_tmp/args" || fail "confirm disables the fzf query line"
grep -Fq -- 'start:pos(1)' "$test_tmp/args" || fail "confirm starts on Yes by default"
pass "confirm launches fzf with mouse accept and Yes selected"

set +e
FZF_CHOICE=No run_confirm "Continue?" >/dev/null
status=$?
set -e
(( status == 1 )) || fail "confirm exits 1 when No is chosen" "status=$status"
pass "confirm exits 1 when No is chosen"

set +e
FZF_EXIT=130 run_confirm "Continue?" >/dev/null
status=$?
set -e
(( status == 130 )) || fail "confirm maps fzf abort to 130" "status=$status"
pass "confirm maps fzf abort to 130"

set +e
FZF_CHOICE=No FZF_EXIT=0 run_confirm --default=false "Remove?" >/dev/null
set -e
grep -Fq -- 'start:pos(2)' "$test_tmp/args" || fail "confirm --default=false starts on No"
pass "confirm --default=false starts on No"
