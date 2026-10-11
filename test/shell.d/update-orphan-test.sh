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
  HOME="$test_home" PATH="$stub_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-update-orphan-pkgs" "$@"
}

write_stub pacman 'if [[ $1 == "-Qtdq" ]]; then printf "old-lib\nunused-tool\n"; exit 0; fi; exit 1'
write_stub sudo 'echo "sudo should not be called" >&2; exit 99'
write_stub gum 'echo "gum should not be called" >&2; exit 99'

run_orphan_checker >"$test_tmp/noninteractive.out" 2>"$test_tmp/noninteractive.err"
grep -q '^  old-lib$' "$test_tmp/noninteractive.out" || fail "orphan checker lists orphan packages"
grep -q 'Re-run omarchy-update-orphan-pkgs in a terminal' "$test_tmp/noninteractive.out" || fail "orphan checker does not remove packages non-interactively"
pass "orphan checker only reports orphans non-interactively"

export REMOVAL_LOG="$test_tmp/removal.log"
write_stub pacman 'case $1 in
  -Qtdq|-Qq) printf "old-lib\nunused-tool\n" ;;
  -Rns) printf "%s\n" "$@" >"$REMOVAL_LOG" ;;
  *) exit 1 ;;
esac'
write_stub sudo '"$@"'
run_orphan_checker -y >"$test_tmp/approved.out" 2>"$test_tmp/approved.err"
diff <(printf '%s\n' -Rns --noconfirm old-lib unused-tool) "$REMOVAL_LOG" ||
  fail "approved cleanup removes the orphan packages without pacman confirmation"
pass "approved cleanup removes orphans without Omarchy or pacman confirmation"

write_stub sudo 'exit 42'
if run_orphan_checker -y >"$test_tmp/failure.out" 2>"$test_tmp/failure.err"; then
  fail "approved cleanup reports removal failures"
fi
pass "approved cleanup reports removal failures"

rm -f "$REMOVAL_LOG"
write_stub pacman 'if [[ $1 == "-Qtdq" ]]; then exit 0; fi; exit 1'
for mode in "" -y; do
  run_orphan_checker $mode >"$test_tmp/none.out" 2>"$test_tmp/none.err"
  [[ ! -s $test_tmp/none.out ]] || fail "orphan checker stays quiet when no orphans exist"
done
[[ ! -e $REMOVAL_LOG ]] || fail "orphan checker does not remove packages when no orphans exist"
pass "orphan checker stays quiet without orphans"
