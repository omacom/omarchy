#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

migration="$ROOT/migrations/1788380505.sh"
[[ -f $migration ]] || fail "SDDM Qt6 guard migration exists"
bash -n "$migration"

test_dir=$(mktemp -d)
trap 'rm -rf "$test_dir"' EXIT

mkdir -p "$test_dir/bin" "$test_dir/etc/sddm.conf.d" "$test_dir/usr/bin"
touch "$test_dir/usr/bin/sddm-greeter"
chmod +x "$test_dir/usr/bin/sddm-greeter"
sudo_log="$test_dir/sudo.log"
ldd_log="$test_dir/ldd.log"

cat >"$test_dir/bin/ldd" <<'STUB'
#!/bin/bash
printf '%s\n' "$1" >>"$SDDM_TEST_LDD_LOG"
case ${SDDM_TEST_LDD:-missing} in
  missing) printf 'libQt5Core.so.5 => not found\n' ;;
  present) printf 'libQt5Core.so.5 => /usr/lib/libQt5Core.so.5\n' ;;
esac
STUB
chmod +x "$test_dir/bin/ldd"

cat >"$test_dir/bin/sudo" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$SDDM_TEST_SUDO_LOG"
if [[ ${SDDM_TEST_SUDO:-allow} == "refuse" ]]; then
  echo "sudo refused" >&2
  exit 1
fi
exec "$@"
STUB
chmod +x "$test_dir/bin/sudo"

reset_state() {
  rm -f "$test_dir/etc/sddm.conf" "$test_dir/etc/sddm.conf.d/"*
  : >"$sudo_log"
  : >"$ldd_log"
}

run_migration() {
  local ldd_state=${1:-missing}
  local sudo_state=${2:-allow}
  OMARCHY_SDDM_CONF="$test_dir/etc/sddm.conf" \
    OMARCHY_SDDM_CONF_DIR="$test_dir/etc/sddm.conf.d" \
    OMARCHY_SDDM_GREETER="$test_dir/usr/bin/sddm-greeter" \
    SDDM_TEST_LDD="$ldd_state" \
    SDDM_TEST_SUDO="$sudo_state" \
    SDDM_TEST_LDD_LOG="$ldd_log" \
    SDDM_TEST_SUDO_LOG="$sudo_log" \
    PATH="$test_dir/bin:$PATH" \
    bash -euo pipefail "$migration"
}

for theme in elarun maldives maya; do
  reset_state
  printf '[Theme]\nCurrent=%s\n[Users]\nHideUsers=true\n' "$theme" >"$test_dir/etc/sddm.conf.d/10-theme.conf"
  printf '[Theme]\nCurrent=omarchy\n[Users]\nHideUsers=true\n' >"$test_dir/expected"
  run_migration missing >/dev/null
  cmp -s "$test_dir/expected" "$test_dir/etc/sddm.conf.d/10-theme.conf" ||
    fail "missing Qt5 greeter libraries reset only Current from $theme"
done
grep -F 'sed -i ' "$sudo_log" >/dev/null ||
  fail "the repair uses sudo sed -i"
pass "missing Qt5 greeter libraries reset stock themes to omarchy"

reset_state
printf '[Theme]\nCurrent=maya\n' >"$test_dir/etc/sddm.conf.d/10-theme.conf"
printf '[Wayland]\nSession=hyprland.desktop\n' >"$test_dir/etc/sddm.conf.d/10-wayland.conf"
printf '[Users]\nHideUsers=true\n' >"$test_dir/etc/sddm.conf.d/99-omarchy-login.conf"
printf '[Autologin]\nRelogin=false\n' >"$test_dir/etc/sddm.conf.d/autologin.conf"
for file in 10-wayland.conf 99-omarchy-login.conf autologin.conf; do
  cp "$test_dir/etc/sddm.conf.d/$file" "$test_dir/expected-$file"
done
run_migration missing >/dev/null
grep -Fx 'Current=omarchy' "$test_dir/etc/sddm.conf.d/10-theme.conf" >/dev/null ||
  fail "the stock multi-file layout repairs the theme drop-in"
for file in 10-wayland.conf 99-omarchy-login.conf autologin.conf; do
  cmp -s "$test_dir/expected-$file" "$test_dir/etc/sddm.conf.d/$file" ||
    fail "the stock multi-file layout preserves $file"
done
pass "the stock multi-file layout repairs only the theme drop-in"

reset_state
printf '[Theme]\nCurrent=maya\n' >"$test_dir/etc/sddm.conf.d/10-theme.conf"
printf '[Theme]\nCurrent=omarchy\n' >"$test_dir/etc/sddm.conf.d/99-override.conf"
cp "$test_dir/etc/sddm.conf.d/10-theme.conf" "$test_dir/expected-first"
cp "$test_dir/etc/sddm.conf.d/99-override.conf" "$test_dir/expected-second"
run_migration missing >/dev/null
cmp -s "$test_dir/expected-first" "$test_dir/etc/sddm.conf.d/10-theme.conf" &&
  cmp -s "$test_dir/expected-second" "$test_dir/etc/sddm.conf.d/99-override.conf" ||
  fail "a later omarchy drop-in overrides the Qt5 theme unchanged"
[[ ! -s $sudo_log ]] || fail "an effective omarchy drop-in does not invoke sudo"
pass "a later omarchy drop-in overrides an earlier Qt5 theme"

reset_state
printf '[Theme]\nCurrent=maya\n' >"$test_dir/etc/sddm.conf"
printf '[Theme]\nCurrent=omarchy\n' >"$test_dir/expected"
run_migration missing >/dev/null
cmp -s "$test_dir/expected" "$test_dir/etc/sddm.conf" ||
  fail "the main SDDM configuration receives the same repair"
pass "the main SDDM configuration is supported"

reset_state
printf '[Theme]\nCurrent=omarchy\n' >"$test_dir/etc/sddm.conf.d/10-theme.conf"
printf '[Theme]\nCurrent=maya\n' >"$test_dir/etc/sddm.conf"
cp "$test_dir/etc/sddm.conf.d/10-theme.conf" "$test_dir/expected-dropin"
run_migration missing >/dev/null
grep -Fx 'Current=omarchy' "$test_dir/etc/sddm.conf" >/dev/null ||
  fail "the main configuration overrides and repairs the earlier drop-in"
cmp -s "$test_dir/expected-dropin" "$test_dir/etc/sddm.conf.d/10-theme.conf" ||
  fail "the main configuration repair leaves the earlier drop-in unchanged"
pass "the main configuration takes precedence over drop-ins"

sudo_calls=$(wc -l <"$sudo_log")
run_migration missing >/dev/null
[[ $(wc -l <"$sudo_log") == "$sudo_calls" ]] ||
  fail "a second migration run does not request another repair"
pass "a second migration run is a no-op"

reset_state
printf '[Theme]\nCurrent=maya\n' >"$test_dir/etc/sddm.conf.d/10-theme.conf"
cp "$test_dir/etc/sddm.conf.d/10-theme.conf" "$test_dir/expected"
run_migration present >/dev/null
cmp -s "$test_dir/expected" "$test_dir/etc/sddm.conf.d/10-theme.conf" ||
  fail "a Qt5 theme with working libraries remains unchanged"
[[ ! -s $sudo_log ]] || fail "working Qt5 libraries do not invoke sudo"
pass "a Qt5 theme with working libraries remains unchanged"

reset_state
printf '[Theme]\nCurrent=omarchy\n' >"$test_dir/etc/sddm.conf.d/10-theme.conf"
cp "$test_dir/etc/sddm.conf.d/10-theme.conf" "$test_dir/expected"
run_migration missing >/dev/null
cmp -s "$test_dir/expected" "$test_dir/etc/sddm.conf.d/10-theme.conf" ||
  fail "the stock omarchy theme remains unchanged"
[[ ! -s $sudo_log ]] || fail "the stock omarchy theme does not invoke sudo"
pass "the stock omarchy theme remains unchanged"

reset_state
rm "$test_dir/usr/bin/sddm-greeter"
printf '[Theme]\nCurrent=maya\n' >"$test_dir/etc/sddm.conf.d/10-theme.conf"
cp "$test_dir/etc/sddm.conf.d/10-theme.conf" "$test_dir/expected"
run_migration missing >/dev/null
cmp -s "$test_dir/expected" "$test_dir/etc/sddm.conf.d/10-theme.conf" ||
  fail "an absent greeter leaves the theme unchanged"
[[ ! -s $ldd_log ]] || fail "an absent greeter does not run ldd"
touch "$test_dir/usr/bin/sddm-greeter"
chmod +x "$test_dir/usr/bin/sddm-greeter"
pass "an absent greeter is a no-op"

reset_state
mkdir -p "$test_dir/usr/share/sddm/themes/custom"
printf '[SddmGreeterTheme]\nName=Custom\\Theme\n' >"$test_dir/usr/share/sddm/themes/custom/metadata.desktop"
printf '[Theme]\nCurrent=custom\n' >"$test_dir/etc/sddm.conf.d/10-theme.conf"
cp "$test_dir/etc/sddm.conf.d/10-theme.conf" "$test_dir/expected"
run_migration missing >/dev/null
cmp -s "$test_dir/expected" "$test_dir/etc/sddm.conf.d/10-theme.conf" ||
  fail "unrecognized theme with backslash metadata remains untouched"
pass "backslash metadata is ignored safely"

reset_state
printf '[Theme]\nCurrent=custom\n# Latin-1: \351\n' >"$test_dir/etc/sddm.conf.d/10-theme.conf"
cp "$test_dir/etc/sddm.conf.d/10-theme.conf" "$test_dir/expected"
run_migration missing >/dev/null
cmp -s "$test_dir/expected" "$test_dir/etc/sddm.conf.d/10-theme.conf" ||
  fail "a Latin-1 drop-in remains untouched"
pass "Latin-1 drop-ins are ignored safely"

reset_state
printf '[Theme]\nCurrent=maya\n' >"$test_dir/etc/sddm.conf.d/10-theme.conf"
printf '[Theme]\nCurrent=omarchy\n' >"$test_dir/etc/sddm.conf.d/20-theme.conf"
cp "$test_dir/etc/sddm.conf.d/10-theme.conf" "$test_dir/expected-first"
cp "$test_dir/etc/sddm.conf.d/20-theme.conf" "$test_dir/expected-second"
run_migration missing >/dev/null
cmp -s "$test_dir/expected-first" "$test_dir/etc/sddm.conf.d/10-theme.conf" &&
  cmp -s "$test_dir/expected-second" "$test_dir/etc/sddm.conf.d/20-theme.conf" ||
  fail "multiple drop-ins remain untouched"
[[ ! -s $sudo_log ]] || fail "multiple drop-ins do not invoke sudo"
pass "multiple drop-ins are ignored safely"

reset_state
printf '[Theme]\nCurrent=omarchy\n' >"$test_dir/etc/sddm.conf.d/99-omarchy-login.conf"
printf '[Theme]\nCurrent=maya\n' >"$test_dir/etc/sddm.conf.d/99-omarchy-login.conf.orig"
cp "$test_dir/etc/sddm.conf.d/99-omarchy-login.conf" "$test_dir/expected"
run_migration missing >/dev/null
grep -Fx 'Current=omarchy' "$test_dir/etc/sddm.conf.d/99-omarchy-login.conf.orig" >/dev/null ||
  fail "a later drop-in without a .conf suffix is repaired"
cmp -s "$test_dir/expected" "$test_dir/etc/sddm.conf.d/99-omarchy-login.conf" ||
  fail "the earlier .conf drop-in is left unchanged"
pass "a later drop-in without a .conf suffix is repaired, as SDDM loads it"

reset_state
printf '[Theme]\nCurrent=elarun\n' >"$test_dir/etc/sddm.conf.d/10-theme.conf"
cp "$test_dir/etc/sddm.conf.d/10-theme.conf" "$test_dir/expected"
if run_migration missing refuse >/dev/null 2>&1; then
  fail "a refused sudo repair must keep the migration pending"
fi
cmp -s "$test_dir/expected" "$test_dir/etc/sddm.conf.d/10-theme.conf" ||
  fail "a refused sudo repair leaves the configuration unchanged"
pass "a refused sudo repair exits non-zero without changing the configuration"
