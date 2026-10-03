#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
test_home="$test_tmp/home"
mkdir -p "$stub_bin" "$test_home"

write_stub() {
  local name="$1"
  local body="$2"

  cat >"$stub_bin/$name" <<SH
#!/bin/bash
$body
SH
  chmod +x "$stub_bin/$name"
}

run_orphan_checker() {
  HOME="$test_home" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-update-orphan-pkgs"
}

write_stub pacman 'if [[ $1 == "-Qtdq" ]]; then printf "old-lib\nunused-tool\n"; exit 0; fi; exit 1'
write_stub sudo 'echo "sudo should not be called" >&2; exit 99'
write_stub gum 'echo "gum should not be called" >&2; exit 99'

run_orphan_checker >"$test_tmp/noninteractive.out" 2>"$test_tmp/noninteractive.err"
grep -q '^  old-lib$' "$test_tmp/noninteractive.out" || fail "orphan checker lists orphan packages"
grep -q 'Re-run omarchy-update-orphan-pkgs in a terminal' "$test_tmp/noninteractive.out" || fail "orphan checker does not remove packages non-interactively"
pass "orphan checker only reports orphans non-interactively"

write_stub pacman 'if [[ $1 == "-Qtdq" ]]; then exit 0; fi; exit 1'
run_orphan_checker >"$test_tmp/none.out" 2>"$test_tmp/none.err"
[[ ! -s $test_tmp/none.out ]] || fail "orphan checker stays quiet when no orphans exist"
pass "orphan checker stays quiet without orphans"

# -y reaches the prompt in a terminal, so report-and-skip cannot be left to the
# non-interactive guard above: it has to be its own check. Run these on a pty
# via util-linux `script -qec` (the suite's existing pty idiom), because without
# one the guard above would answer for the unattended case and a mutant that
# dropped the check would still pass. gum itself is stubbed.
if script -qec true /dev/null >/dev/null 2>&1; then
  gum_marker="$test_tmp/gum-reached"
  write_stub pacman 'if [[ $1 == "-Qtdq" ]]; then printf "old-lib\nunused-tool\n"; exit 0; fi; exit 1'

  rm -f "$gum_marker"
  write_stub gum "touch '$gum_marker'; exit 99"
  unattended_status=0
  unattended_raw=$(OMARCHY_UPDATE_UNATTENDED=1 HOME="$test_home" PATH="$stub_bin:$ROOT/bin:$PATH" \
    script -qec "omarchy-update-orphan-pkgs" /dev/null) || unattended_status=$?
  unattended_output=$(tr -d '\r' <<<"$unattended_raw")

  (( unattended_status == 0 )) ||
    fail "unattended orphan review exits cleanly" "$unattended_output"
  grep -qF 'Run omarchy-update-orphan-pkgs when ready' <<<"$unattended_output" ||
    fail "unattended orphan review reports and skips" "$unattended_output"
  [[ ! -e $gum_marker ]] ||
    fail "unattended orphan review asked a question -y promised not to ask"
  pass "unattended orphan review reports and skips instead of prompting"

  # -y is the only thing suppressed: an interactive update still asks. gum
  # answering with a failure stands in for the user declining.
  rm -f "$gum_marker"
  write_stub gum "touch '$gum_marker'; exit 99"
  interactive_status=0
  interactive_raw=$(HOME="$test_home" PATH="$stub_bin:$ROOT/bin:$PATH" \
    script -qec "omarchy-update-orphan-pkgs" /dev/null) || interactive_status=$?
  interactive_output=$(tr -d '\r' <<<"$interactive_raw")

  (( interactive_status == 0 )) ||
    fail "interactive orphan review exits cleanly" "$interactive_output"
  [[ -e $gum_marker ]] ||
    fail "interactive orphan review stopped asking about orphans" "$interactive_output"
  grep -qF 'Keeping orphaned packages.' <<<"$interactive_output" ||
    fail "a declined orphan prompt keeps the packages" "$interactive_output"
  pass "interactive orphan review still prompts"
else
  skip "script -qec unavailable; skipping the unattended orphan prompt cases"
fi
