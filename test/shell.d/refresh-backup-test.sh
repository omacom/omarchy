#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# refresh-pacman rebuilds PATH around its own sudo wrapper, so a stub earlier on
# PATH never answers it. The boundary fixture redirects those fixed paths to
# stand-ins instead, so no host sudo, pacman or hook is ever in reach.
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
copy_boundary_file bin/omarchy-refresh-pacman

root_fs="$boundary_tmp/fs"
mkdir -p "$root_fs/etc/pacman.d" "$root_fs/boot" "$SUDO_TEST_ROOT/default/pacman"
printf 'stable pacman conf\n' >"$SUDO_TEST_ROOT/default/pacman/pacman-stable.conf"
printf 'stable mirrorlist\n' >"$SUDO_TEST_ROOT/default/pacman/mirrorlist-stable"

# The mock sudo runs cp from the fixture's bin, so reroot /etc into a tree the
# test owns, and leave the package transaction a logged no-op.
rm "$SUDO_TEST_ROOT/bin/cp" "$SUDO_TEST_ROOT/bin/omarchy-update-pacman"
cat >"$SUDO_TEST_ROOT/bin/cp" <<SH
#!/bin/bash
args=()
for arg in "\$@"; do
  case "\$arg" in
    /etc/*) args+=("$root_fs\$arg") ;;
    *) args+=("\$arg") ;;
  esac
done
exec /usr/bin/cp "\${args[@]}"
SH
chmod +x "$SUDO_TEST_ROOT/bin/cp"
ln -s test-step "$SUDO_TEST_ROOT/bin/omarchy-update-pacman"

refresh_pacman() {
  "$SUDO_TEST_ROOT/bin/omarchy-refresh-pacman" "$@" >"$boundary_tmp/output" 2>&1
}

backups_in() {
  find "$1" -maxdepth 1 -name "$2" | wc -l
}

# refresh-pacman: two runs have to leave two backups, not one overwritten twice.
printf 'first pacman conf\n' >"$root_fs/etc/pacman.conf"
printf 'first mirrorlist\n' >"$root_fs/etc/pacman.d/mirrorlist"

refresh_pacman stable || fail "first pacman refresh" "$(<"$boundary_tmp/output")"
printf 'second pacman conf\n' >"$root_fs/etc/pacman.conf"
sleep 1
refresh_pacman stable || fail "second pacman refresh" "$(<"$boundary_tmp/output")"

count=$(backups_in "$root_fs/etc" 'pacman.conf.bak.*')
(( count == 2 )) ||
  fail "two pacman refreshes keep both backups" "got: $count"

grep -rqx 'first pacman conf' "$root_fs/etc"/pacman.conf.bak.* ||
  fail "the first pacman refresh's backup survives the second"

count=$(backups_in "$root_fs/etc/pacman.d" 'mirrorlist.bak.*')
(( count == 2 )) ||
  fail "two pacman refreshes keep both mirrorlist backups" "got: $count"

grep -rqx 'first mirrorlist' "$root_fs/etc/pacman.d"/mirrorlist.bak.* ||
  fail "the first pacman refresh's mirrorlist backup survives the second"

# Both files share one timestamp per run, so a pair stays recognisable as a pair.
for backup in "$root_fs/etc"/pacman.conf.bak.*; do
  stamp=${backup##*/pacman.conf.bak.}
  [[ -f $root_fs/etc/pacman.d/mirrorlist.bak.$stamp ]] ||
    fail "each pacman.conf backup has a mirrorlist backup from the same run" \
      "no mirrorlist for stamp $stamp, have: $(find "$root_fs/etc/pacman.d" -name 'mirrorlist.bak.*' -printf '%f ')"
done

grep -q '^step:omarchy-hook pre-refresh-pacman' "$SUDO_TEST_LOG" ||
  fail "the pre-refresh hook is answered by the stand-in" "$(<"$SUDO_TEST_LOG")"

pass "two pacman refreshes keep both backups, paired by run"

# A rejected channel must not spend the backups on its way out.
before=$(backups_in "$root_fs/etc" 'pacman.conf.bak.*')
if refresh_pacman nonsense; then
  fail "an unknown channel is refused"
fi
after=$(backups_in "$root_fs/etc" 'pacman.conf.bak.*')
(( before == after )) ||
  fail "an unknown channel writes no backup" "before: $before, after: $after"

pass "an unknown channel is refused before any backup is written"

# refresh-limine: same rule, and the config it replaces is moved rather than
# copied, so an overwritten backup loses the original outright. It runs on the
# caller's PATH, so a sudo stub there reroots /boot.
limine_bin="$boundary_tmp/limine-bin"
mkdir -p "$limine_bin"
cat >"$limine_bin/sudo" <<SH
#!/bin/bash
action=\$1
shift
args=()
for arg in "\$@"; do
  case "\$arg" in
    /etc/* | /boot/*) args+=("$root_fs\$arg") ;;
    *) args+=("\$arg") ;;
  esac
done
case "\$action" in
  cp | mv) command "\$action" "\${args[@]}" ;;
  test) command test "\${args[@]}" ;;
  *) exit 0 ;;
esac
SH
chmod +x "$limine_bin/sudo"

refresh_limine() {
  HOME="$SUDO_TEST_HOME" OMARCHY_PATH="$ROOT" PATH="$limine_bin:$PATH" "$ROOT/bin/omarchy-refresh-limine" >/dev/null 2>&1
}

printf 'first limine conf\n' >"$root_fs/boot/limine.conf"
refresh_limine
printf 'second limine conf\n' >"$root_fs/boot/limine.conf"
sleep 1
refresh_limine

count=$(backups_in "$root_fs/boot" 'limine.conf.bak.*')
(( count == 2 )) ||
  fail "two limine refreshes keep both backups" "got: $count"

grep -rqx 'first limine conf' "$root_fs/boot"/limine.conf.bak.* ||
  fail "the first limine refresh's backup survives the second"

pass "two limine refreshes keep both backups"
