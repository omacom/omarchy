#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# omarchy-user-apps-apply against fake desktop entries and a setfacl that
# records ACLs: a blocked app's program is denied to that person, an app that
# runs through a shared launcher is left to the shell to hide, unblocking gives
# access back, and a rerun restores what an upgrade replaced.

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
export TEST_TMP=$tmp
mkdir -p "$tmp/bin" "$tmp/apps" "$tmp/usr/bin" "$tmp/blocked"

cat >"$tmp/bin/setfacl" <<'SH'
#!/bin/bash
acls=$TEST_TMP/acls
case $1 in
  -m) entry=${2#u:}; user=${entry%%:*}; path=$4
      grep -vxF "$user $path" "$acls" >"$acls.new" 2>/dev/null || true; mv "$acls.new" "$acls"
      echo "$user $path" >>"$acls" ;;
  -x) user=${2#u:}; path=$4
      grep -vxF "$user $path" "$acls" >"$acls.new" || true; mv "$acls.new" "$acls" ;;
esac
SH
cat >"$tmp/bin/getent" <<'SH'
#!/bin/bash
[[ $1 == passwd && ( $2 == emma || $2 == bob ) ]]
SH
chmod +x "$tmp/bin/"*
touch "$tmp/acls"

program() { printf '#!/bin/sh\n' >"$tmp/usr/bin/$1"; chmod +x "$tmp/usr/bin/$1"; }
entry() { printf '[Desktop Entry]\nName=%s\nExec=%s\n' "$1" "$2" >"$tmp/apps/$1.desktop"; }
program steam
program chromium
mkdir -p "$tmp/usr/lib/chromium" && printf '#!/bin/sh\n' >"$tmp/usr/lib/chromium/chromium"
program omarchy-launch-webapp
program bash
ln -s steam "$tmp/usr/bin/steam-runtime"
entry Steam "env GDK_SCALE=2 steam-runtime %U"
entry Discord "omarchy-launch-webapp https://discord.com/app"
entry Shell "bash -c thing"
entry Chromium "chromium %U"

apply() {
  APPS_TESTING=1 APPS_BLOCKED_DIR=$tmp/blocked APPS_STATE=$tmp/state/applied APPS_DESKTOP_DIRS=$tmp/apps APPS_PROGRAM_DIRS=$tmp/usr/bin APPS_SYSTEM_ROOTS=$tmp/usr \
    PATH="$tmp/bin:$PATH" "$ROOT/bin/omarchy-user-apps-apply"
}

printf 'Steam\nDiscord\nShell\nNotInstalled\n' >"$tmp/blocked/emma"
apply
[[ $(cat "$tmp/acls") == "emma $tmp/usr/bin/steam" ]] || fail "only the blocked app's own program is denied, through env and a symlink" "$(cat "$tmp/acls")"
pass "a blocked app's program is denied to that person, following env and symlinks; web apps and shells are left to hiding"

printf 'Steam\n' >"$tmp/blocked/bob"
apply
[[ $(sort "$tmp/acls" | paste -sd' ' -) == "bob $tmp/usr/bin/steam emma $tmp/usr/bin/steam" ]] || fail "each person's list is their own" "$(cat "$tmp/acls")"
printf 'Discord\n' >"$tmp/blocked/emma"
apply
[[ $(cat "$tmp/acls") == "bob $tmp/usr/bin/steam" ]] || fail "an app taken off a list is theirs again" "$(cat "$tmp/acls")"
pass "an app taken off someone's list is theirs to run again, and nobody else's access changes"

# An upgrade replaces the program and its ACL with it.
: >"$tmp/acls"
apply
[[ $(cat "$tmp/acls") == "bob $tmp/usr/bin/steam" ]] || fail "a rerun after an upgrade denies the program again"
pass "the pacman hook's rerun denies a program an upgrade replaced"

printf 'Chromium\n' >"$tmp/blocked/bob"
apply
grep -qx "bob $tmp/usr/bin/chromium" "$tmp/acls" && grep -qx "bob $tmp/usr/lib/chromium" "$tmp/acls" || fail "a launcher's own directory, where the real binary is, is denied with it" "$(cat "$tmp/acls")"
printf 'Steam\n' >"$tmp/blocked/bob"
apply
! grep -q chromium "$tmp/acls" || fail "unblocked, the program's directory is theirs again"
pass "a program's own directory, where a launcher hands off to the real binary, is denied with it"

rm -f "$tmp/blocked/bob"
apply
[[ ! -s $tmp/acls ]] || fail "a removed list gives access back" "$(cat "$tmp/acls")"
pass "a person's list removed, as when they are deleted, takes their ACLs with it"
