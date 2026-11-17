#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
require_command pacman-conf

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
migration="$ROOT/migrations/1794890158.sh"
key=12CE6799A94A3F1B5DDFFE88F576553597FB8FEB

# pacman, pacman-key and the Omarchy helpers act on files in the case's
# directory: installed holds the local packages, synced the [omarchy] ones,
# old-repo the [asahi-alarm] ones, required-by the keyring's dependents, keys
# the pacman keyring. An installed package [omarchy] lacks counts as foreign.
stubs="$test_tmp/bin"
mkdir -p "$stubs"
cat >"$stubs/sudo" <<'EOF'
#!/bin/bash
exec "$@"
EOF
cat >"$stubs/omarchy-hw-aarch64-apple" <<'EOF'
#!/bin/bash
[[ $TEST_PLATFORM == "aarch64-apple" ]]
EOF
cat >"$stubs/pacman" <<'EOF'
#!/bin/bash
echo "pacman $*" >>"$TEST_CASE/log"
case $1 in
  -Q) grep -qx "$3" "$TEST_CASE/installed" ;;
  -Si) grep -qx "${2#omarchy/}" "$TEST_CASE/synced" ;;
  -Slq) cat "$TEST_CASE/old-repo" ;;
  -Qq) cat "$TEST_CASE/installed" ;;
  -Qqm) grep -vxFf "$TEST_CASE/synced" "$TEST_CASE/installed" ;;
  -Qi)
    grep -qx "$3" "$TEST_CASE/installed" || exit 1
    echo "Name            : $3"
    echo "Required By     : $(cat "$TEST_CASE/required-by")"
    ;;
  *) exit 1 ;;
esac
EOF
cat >"$stubs/pacman-key" <<'EOF'
#!/bin/bash
echo "pacman-key $*" >>"$TEST_CASE/log"
case $1 in
  --list-keys) grep -qx "$2" "$TEST_CASE/keys" ;;
  --delete) grep -vx "$2" "$TEST_CASE/keys" >"$TEST_CASE/keys.new" || true; mv "$TEST_CASE/keys.new" "$TEST_CASE/keys" ;;
  *) exit 1 ;;
esac
EOF
# The upgrade replaces each asahi-* package with its aurora-* build and leaves
# the keyring required by whatever the case says remains.
cat >"$stubs/omarchy-update-system-pkgs" <<'EOF'
#!/bin/bash
echo "omarchy-update-system-pkgs" >>"$TEST_CASE/log"
[[ ${TEST_UPGRADE_FAILS:-0} == 0 ]] || exit 1
sed -i 's/^asahi-scripts$/aurora-scripts/; s/^asahi-fwextract$/aurora-fwextract/; s/^FEX-Emu$/fex-emu/' "$TEST_CASE/installed"
cat "$TEST_CASE/required-by-after" >"$TEST_CASE/required-by"
EOF
cat >"$stubs/omarchy-pkg-drop" <<'EOF'
#!/bin/bash
echo "omarchy-pkg-drop $*" >>"$TEST_CASE/log"
for pkg in "$@"; do
  grep -vx "$pkg" "$TEST_CASE/installed" >"$TEST_CASE/installed.new" || true
  mv "$TEST_CASE/installed.new" "$TEST_CASE/installed"
done
EOF
chmod +x "$stubs"/*

# A live pacman.conf with [asahi-alarm] between Omarchy's repository and Arch
# Linux ARM's, a header with trailing whitespace, and an administrator's own
# options and repository around it.
write_conf() {
  cat >"$1" <<'EOF'
[options]
HoldPkg = pacman glibc
Architecture = auto
SigLevel = Required DatabaseOptional
IgnorePkg = example

[omarchy]
Server = https://pkgs.omarchy.org/edge/$arch

[asahi-alarm]
Server = https://github.com/asahi-alarm/asahi-alarm/releases/download/aarch64

[core]
Include = /etc/pacman.d/mirrorlist

[extra]
Include = /etc/pacman.d/mirrorlist

[alarm]
Include = /etc/pacman.d/mirrorlist

[custom]
Server = https://example.com/$arch
EOF
}

new_case() {
  local case_dir="$test_tmp/$1"
  mkdir -p "$case_dir/home"
  write_conf "$case_dir/pacman.conf"
  sed -i "s|/etc/pacman.d/mirrorlist|$case_dir/mirrorlist|" "$case_dir/pacman.conf"
  echo 'Server = https://arm-mirror.omarchy.org/$arch/$repo' >"$case_dir/mirrorlist"
  printf '%s\n' asahi-scripts asahi-fwextract lzfse speakersafetyd bankstown triforce-lv2 widevine FEX-Emu asahi-alarm-keyring omarchy-mac steam >"$case_dir/installed"
  printf '%s\n' asahi-scripts asahi-fwextract lzfse speakersafetyd bankstown triforce-lv2 widevine muvm FEX-Emu asahi-alarm-keyring steam fex-emu-rootfs-arch >"$case_dir/old-repo"
  printf '%s\n' aurora-scripts aurora-fwextract lzfse speakersafetyd bankstown triforce-lv2 widevine muvm fex-emu >"$case_dir/synced"
  echo "omarchy-mac" >"$case_dir/required-by"
  echo "None" >"$case_dir/required-by-after"
  printf '%s\n' "$key" 68B3537F39A313B3E574D06777193F152BDBE6A6 >"$case_dir/keys"
  : >"$case_dir/log"
  echo "$case_dir"
}

run_migration() {
  local case_dir=$1
  env -i \
    HOME="$case_dir/home" \
    PATH="$stubs:/usr/bin:/bin" \
    TEST_CASE="$case_dir" \
    TEST_PLATFORM="${TEST_PLATFORM:-aarch64-apple}" \
    OMARCHY_ASAHI_ALARM_PACMAN_CONF="$case_dir/pacman.conf" \
    OMARCHY_ASAHI_ALARM_MARKER="$case_dir/marker" \
    TEST_UPGRADE_FAILS="${TEST_UPGRADE_FAILS:-0}" \
    bash -euo pipefail "$migration"
}

repos() {
  pacman-conf --config "$1" --repo-list | tr '\n' ' '
}

# ── the move ─────────────────────────────────────────────────────────────────

case_dir=$(new_case move)
original=$(cat "$case_dir/pacman.conf")
run_migration "$case_dir" >"$case_dir/out" 2>&1 || fail "the migration moves a Mac off [asahi-alarm]" "$(cat "$case_dir/out")"
[[ $(repos "$case_dir/pacman.conf") == "omarchy core extra alarm custom " ]] ||
  fail "only [asahi-alarm] leaves pacman.conf" "$(repos "$case_dir/pacman.conf")"
grep -qx 'IgnorePkg = example' "$case_dir/pacman.conf" || fail "the administrator's options stay"
! grep -q 'asahi-alarm' "$case_dir/pacman.conf" || fail "nothing of the section stays" "$(cat "$case_dir/pacman.conf")"
[[ $(cat "$case_dir/pacman.conf.bak-asahi-alarm") == "$original" ]] || fail "the old pacman.conf is kept as a backup"
[[ $(stat -c %a "$case_dir/pacman.conf") == 644 ]] || fail "pacman.conf stays world-readable"
grep -qx 'omarchy-update-system-pkgs' "$case_dir/log" || fail "the migration upgrades against the remaining repositories"
grep -qx 'aurora-scripts' "$case_dir/installed" && ! grep -qx 'asahi-scripts' "$case_dir/installed" ||
  fail "aurora-scripts replaces asahi-scripts in the upgrade"
grep -qx "pacman-key --delete $key" "$case_dir/log" || fail "the Asahi ALARM key is deleted" "$(cat "$case_dir/log")"
! grep -qx "$key" "$case_dir/keys" || fail "the Asahi ALARM key is gone from the keyring"
grep -qx 68B3537F39A313B3E574D06777193F152BDBE6A6 "$case_dir/keys" || fail "Arch Linux ARM's key stays"
grep -qx 'omarchy-pkg-drop asahi-alarm-keyring' "$case_dir/log" || fail "the orphaned keyring is removed"
[[ -e $case_dir/marker ]] || fail "the machine is marked done"
grep -qx 'No longer updated, since only \[asahi-alarm\] carried them: steam' "$case_dir/out" ||
  fail "it names the installed packages only [asahi-alarm] carried" "$(cat "$case_dir/out")"
pass "the migration drops [asahi-alarm] and keeps everything else, upgrades, then deletes the orphaned keyring and its key"

# ── idempotency ──────────────────────────────────────────────────────────────

moved=$(cat "$case_dir/pacman.conf")
: >"$case_dir/log"
run_migration "$case_dir" >/dev/null 2>&1 || fail "the migration runs again"
[[ ! -s $case_dir/log && $(cat "$case_dir/pacman.conf") == "$moved" ]] || fail "a second run on a marked machine does nothing" "$(cat "$case_dir/log")"
rm "$case_dir/marker"
run_migration "$case_dir" >/dev/null 2>&1 || fail "the migration runs for another user"
grep -qv '^pacman -Q -- ' "$case_dir/log" && fail "a moved machine without the marker only looks" "$(cat "$case_dir/log")"
[[ $(cat "$case_dir/pacman.conf") == "$moved" ]] || fail "a moved machine's pacman.conf is left alone"
pass "the migration is idempotent, with or without the machine's marker"

# ── no-ops ───────────────────────────────────────────────────────────────────

for platform in x86 aarch64 aarch64-qualcomm; do
  case_dir=$(new_case "other-$platform")
  TEST_PLATFORM=$platform run_migration "$case_dir" >/dev/null 2>&1 || fail "the migration completes on $platform"
  [[ ! -s $case_dir/log && ! -e $case_dir/marker ]] || fail "the migration does nothing on $platform" "$(cat "$case_dir/log")"
  [[ ! -e $case_dir/pacman.conf.bak-asahi-alarm ]] || fail "the migration leaves pacman.conf alone on $platform"
done
pass "the migration does nothing on anything but an Apple Silicon Mac"

case_dir=$(new_case fresh)
sed -i '/^\[asahi-alarm\]/,/^$/d' "$case_dir/pacman.conf"
sed -i '/^asahi-alarm-keyring$/d' "$case_dir/installed"
fresh=$(cat "$case_dir/pacman.conf")
run_migration "$case_dir" >/dev/null 2>&1 || fail "the migration completes on a Mac without [asahi-alarm]"
grep -qv '^pacman -Q -- ' "$case_dir/log" && fail "a Mac without [asahi-alarm] or its keyring is only looked at" "$(cat "$case_dir/log")"
[[ $(cat "$case_dir/pacman.conf") == "$fresh" && ! -e $case_dir/pacman.conf.bak-asahi-alarm ]] || fail "its pacman.conf is left alone"
pass "the migration does nothing on a Mac without [asahi-alarm] or its keyring"

# ── staying pending ──────────────────────────────────────────────────────────

case_dir=$(new_case unpublished)
sed -i '/^aurora-scripts$/d' "$case_dir/synced"
original=$(cat "$case_dir/pacman.conf")
if run_migration "$case_dir" >"$case_dir/out" 2>&1; then
  fail "the migration waits for [omarchy] to carry aurora-scripts"
fi
grep -q 'omarchy/aurora-scripts is not available' "$case_dir/out" || fail "it says which package is missing" "$(cat "$case_dir/out")"
[[ $(cat "$case_dir/pacman.conf") == "$original" ]] || fail "pacman.conf is untouched while it waits"
! grep -q 'omarchy-update-system-pkgs\|pacman-key\|omarchy-pkg-drop' "$case_dir/log" || fail "nothing else changes while it waits"
[[ ! -e $case_dir/marker ]] || fail "the machine is not marked while it waits"
pass "the migration stays pending, changing nothing, while the channel lacks an Omarchy build"

# An import that isn't installed doesn't need its build on the channel.
case_dir=$(new_case not-installed)
sed -i '/^FEX-Emu$/d' "$case_dir/installed"
sed -i '/^fex-emu$/d' "$case_dir/synced"
run_migration "$case_dir" >/dev/null 2>&1 || fail "the migration needs only the installed imports' builds"
[[ -e $case_dir/marker ]] || fail "the machine without FEX-Emu is moved"
pass "the migration checks only the imports that are installed"

case_dir=$(new_case upgrade-fails)
if TEST_UPGRADE_FAILS=1 run_migration "$case_dir" >/dev/null 2>&1; then
  fail "a failed upgrade leaves the migration pending"
fi
[[ $(repos "$case_dir/pacman.conf") == "omarchy core extra alarm custom " ]] || fail "the repository is gone before the upgrade"
grep -qx "$key" "$case_dir/keys" && grep -qx asahi-alarm-keyring "$case_dir/installed" || fail "the keyring and its key stay until the upgrade succeeds"
: >"$case_dir/log"
run_migration "$case_dir" >/dev/null 2>&1 || fail "the rerun finishes after a failed upgrade"
grep -qx 'omarchy-update-system-pkgs' "$case_dir/log" || fail "the rerun retries the upgrade though the repository is gone"
grep -qx 'omarchy-pkg-drop asahi-alarm-keyring' "$case_dir/log" && [[ -e $case_dir/marker ]] || fail "the rerun finishes the move"
pass "a failed upgrade stays pending, and the rerun retries it and finishes"

# ── a keyring still required ─────────────────────────────────────────────────

case_dir=$(new_case still-required)
echo "omarchy-mac  omarchy-mac-boot" >"$case_dir/required-by-after"
run_migration "$case_dir" >"$case_dir/out" 2>&1 || fail "the migration completes with the keyring still required"
grep -q 'Keeping asahi-alarm-keyring and its key: omarchy-mac  omarchy-mac-boot still requires it' "$case_dir/out" ||
  fail "it says what still requires the keyring" "$(cat "$case_dir/out")"
grep -qx asahi-alarm-keyring "$case_dir/installed" && grep -qx "$key" "$case_dir/keys" || fail "the required keyring and its key stay"
! grep -q 'pacman-key --delete\|omarchy-pkg-drop' "$case_dir/log" || fail "nothing is deleted" "$(cat "$case_dir/log")"
[[ $(repos "$case_dir/pacman.conf") == "omarchy core extra alarm custom " ]] || fail "the repository still goes"
pass "a keyring something still requires stays, with its key"
