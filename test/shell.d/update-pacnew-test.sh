#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

write_stub() {
  local name="$1"
  local body="$2"

  cat >"$stub_bin/$name" <<SH
#!/bin/bash
$body
SH
  chmod +x "$stub_bin/$name"
}

# pacdiff -o prints every pending file it finds beside a packaged config file,
# whichever package owns it. PENDING holds what this machine has waiting.
export PENDING="$test_tmp/pending"
write_pacdiff() {
  write_stub pacdiff '[[ $* == "-o" ]] || exit 1
cat "$PENDING"'
}

# The omarchy repository carries packages that are not named after it, one of
# them named after an Arch package whose own config file is waiting too, and the
# files Omarchy installs over pacman's own belong to Arch packages.
write_pacman() {
  local repo_listing="$1"

  write_stub pacman 'case $1 in
  -Slq)
    [[ $2 == "omarchy" ]] || exit 1
    '"$repo_listing"'
    ;;
  -Qoq)
    case $2 in
      /etc/sddm.conf.d/10-theme.conf|/etc/sddm.conf.d/10-wayland.conf|"/etc/omarchy test/a b.conf") echo omarchy-settings ;;
      /etc/limine-snapper-sync.conf) echo limine-snapper-sync ;;
      /etc/pacman.d/mirrorlist) echo pacman-mirrorlist ;;
      /etc/pacman.conf) echo pacman ;;
      /etc/mkinitcpio.conf) echo mkinitcpio ;;
      *) echo "error: No package owns $2" >&2; exit 1 ;;
    esac
    ;;
  *) exit 1 ;;
esac'
}

omarchy_repo='printf "%s\n" omarchy-settings limine-snapper-sync limine-mkinitcpio-hook'

run_report() {
  PATH="$stub_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-update-pacnew" >"$test_tmp/out" 2>"$test_tmp/err"
}

listed() {
  grep '^  /' "$test_tmp/out" || true
}

write_pacdiff
write_pacman "$omarchy_repo"

cat >"$PENDING" <<'PENDING'
/etc/pacman.conf.pacnew
/etc/pacman.d/mirrorlist.pacnew
/etc/mkinitcpio.conf.pacnew
/etc/sddm.conf.d/10-theme.conf.pacnew
/etc/sddm.conf.d/10-wayland.conf.pacsave
/etc/limine-snapper-sync.conf.pacnew
/etc/unowned.conf.pacnew
/etc/omarchy test/a b.conf.pacnew
PENDING

run_report || fail "the report fails when Omarchy config updates are waiting"
diff <(printf '  %s\n' \
  /etc/sddm.conf.d/10-theme.conf.pacnew \
  /etc/limine-snapper-sync.conf.pacnew \
  "/etc/omarchy test/a b.conf.pacnew") <(listed) >"$test_tmp/diff" ||
  fail "the report does not list exactly the .pacnew files of Omarchy's packages" "$(cat "$test_tmp/diff")"
[[ ! -s $test_tmp/err ]] || fail "the report passes on pacman's error for a file no package owns" "$(cat "$test_tmp/err")"
pass "the report lists the .pacnew files of every package in the omarchy repository, and only those"

grep -q 'Omarchy config updates not applied' "$test_tmp/out" || fail "the report does not say what the list is"
grep -q 'DIFFPROG="nvim -d" pacdiff -s' "$test_tmp/out" || fail "the report does not say how to merge the files"
pass "the report says what the files are and how to merge them"

cat >"$PENDING" <<'PENDING'
/etc/pacman.conf.pacnew
/etc/pacman.d/mirrorlist.pacnew
/etc/mkinitcpio.conf.pacnew
/etc/sddm.conf.d/10-wayland.conf.pacsave
PENDING
run_report || fail "the report fails when only other packages have config updates waiting"
[[ ! -s $test_tmp/out ]] || fail "the report speaks up for config updates that are not Omarchy's" "$(cat "$test_tmp/out")"
pass "the report stays quiet about other packages' .pacnew files and about .pacsave files"

: >"$PENDING"
run_report || fail "the report fails when nothing is waiting"
[[ ! -s $test_tmp/out && ! -s $test_tmp/err ]] ||
  fail "the report speaks up when nothing is waiting" "$(cat "$test_tmp/out" "$test_tmp/err")"
pass "the report stays quiet when nothing is waiting"

# A machine without the omarchy repository has no Omarchy package to speak for.
echo /etc/sddm.conf.d/10-theme.conf.pacnew >"$PENDING"
write_pacman 'echo "error: repository \"omarchy\" was not found." >&2; exit 1'
run_report || fail "the report fails on a machine without the omarchy repository"
[[ ! -s $test_tmp/out && ! -s $test_tmp/err ]] ||
  fail "the report claims a file for a repository this machine does not have" "$(cat "$test_tmp/out" "$test_tmp/err")"
pass "the report stays quiet without the omarchy repository"

# A report is not worth an update: when the look itself fails, the update it
# runs inside carries on, but an empty list must not pass for a clean machine.
write_pacman "$omarchy_repo"
write_stub pacdiff 'echo "==> ERROR: unable to read pacman database" >&2; exit 1'
run_report || fail "the report stops the update when pacdiff cannot read the package database"
[[ ! -s $test_tmp/out ]] || fail "the report prints a list it could not build" "$(cat "$test_tmp/out")"
grep -q 'unable to read pacman database' "$test_tmp/err" || fail "the report hides why pacdiff failed"
grep -q 'Could not look for unmerged Omarchy config updates' "$test_tmp/err" ||
  fail "the report lets a failed look pass for a clean machine"
pass "the report says so when it could not look, without stopping the update"
