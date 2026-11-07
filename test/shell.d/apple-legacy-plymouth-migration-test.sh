#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_platform_fixtures "the legacy Apple Silicon Plymouth rebuild"

# The migration reads a mocked mkinitcpio.conf and its drop-ins, and the
# baseline reads a mocked plymouth install hook. Nothing here builds an
# initramfs or talks to hardware.
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

migration="$ROOT/migrations/1794058000.sh"
stub_bin="$test_tmp/bin"
conf="$test_tmp/etc/mkinitcpio.conf"
conf_dir="$test_tmp/etc/mkinitcpio.conf.d"
install_dir="$test_tmp/initcpio-install"
marker="$test_tmp/rebuilt"
log="$test_tmp/rebuild-log"
mkdir -p "$stub_bin" "$conf_dir" "$install_dir"
printf '#!/bin/bash\n' >"$install_dir/plymouth"

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
exec "$@"
SH
cat >"$stub_bin/mkinitcpio" <<'SH'
#!/bin/bash
printf 'mkinitcpio %s\n' "$*" >>"$TEST_REBUILD_LOG"
exit "${MKINITCPIO_STATUS:-0}"
SH
cat >"$stub_bin/limine-mkinitcpio" <<'SH'
#!/bin/bash
printf 'limine-mkinitcpio %s\n' "$*" >>"$TEST_REBUILD_LOG"
exit "${LIMINE_MKINITCPIO_STATUS:-0}"
SH
cat >"$stub_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
for cmd in "$@"; do
  command -v -- "$cmd" >/dev/null || exit 1
done
exit 0
SH
chmod +x "$stub_bin"/*

for platform in aarch64-apple aarch64 x86; do
  fake_platform "$test_tmp/platforms/$platform" "$platform"
done
mkdir -p "$test_tmp/platforms/no-detector/bin"

write_conf() {
  cat >"$conf" <<CONF
MODULES=()
BINARIES=()
FILES=()
HOOKS=($1)
CONF
  rm -rf "$conf_dir"
  mkdir -p "$conf_dir"
  cp "$ROOT"/etc/mkinitcpio.conf.d/*.conf "$conf_dir/"
}

run_migration() {
  local platform="$1"
  local path="$stub_bin:$test_tmp/platforms/$platform/bin:$ROOT/bin:/usr/bin"
  [[ $platform != "no-detector" ]] || path="$stub_bin:$test_tmp/platforms/no-detector/bin:/usr/bin"
  env -i \
    HOME="$test_tmp/home" \
    PATH="$path" \
    OMARCHY_PROC_ROOT="$test_tmp/platforms/$platform/proc" \
    OMARCHY_MKINITCPIO_CONF="$conf" \
    OMARCHY_MKINITCPIO_CONF_DIR="$conf_dir" \
    OMARCHY_INITCPIO_INSTALL="$install_dir" \
    OMARCHY_PLYMOUTH_REBUILD_MARKER="$marker" \
    TEST_REBUILD_LOG="$log" \
    MKINITCPIO_STATUS="${MKINITCPIO_STATUS:-0}" \
    LIMINE_MKINITCPIO_STATUS="${LIMINE_MKINITCPIO_STATUS:-0}" \
    bash -euo pipefail "$migration"
}

assert_skipped() {
  local description="$1" platform="$2"
  rm -f "$log" "$marker"
  run_migration "$platform" >/dev/null
  [[ ! -e $log && ! -e $marker ]] || fail "$description" "log=$(cat "$log" 2>/dev/null)"
  pass "$description"
}

legacy_luks="base asahi udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck"

write_conf "$legacy_luks"
rm -f "$log" "$marker"
run_migration aarch64-apple >/dev/null
[[ $(cat "$log") == "mkinitcpio -P" && -e $marker ]] || fail "a legacy Apple Silicon LUKS line rebuilds with mkinitcpio" "log=$(cat "$log" 2>/dev/null)"
run_migration aarch64-apple >/dev/null
[[ $(cat "$log") == "mkinitcpio -P" ]] || fail "a completed rebuild is not repeated" "log=$(cat "$log")"
pass "a legacy Apple Silicon LUKS line rebuilds with mkinitcpio once"

write_conf "$legacy_luks"
rm -f "$log" "$marker"
run_migration no-detector >/dev/null
[[ $(cat "$log") == "mkinitcpio -P" && -e $marker ]] || fail "a legacy asahi LUKS line rebuilds without the detector" "log=$(cat "$log" 2>/dev/null)"
pass "a legacy asahi LUKS line rebuilds without the detector"

write_conf "$legacy_luks"
rm -f "$log" "$marker"
run_migration aarch64 >/dev/null
[[ $(cat "$log") == "mkinitcpio -P" && -e $marker ]] || fail "an asahi LUKS root off a Mac rebuilds" "log=$(cat "$log" 2>/dev/null)"
pass "an asahi LUKS root off a Mac rebuilds"

write_conf "base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck"
rm -f "$log" "$marker"
run_migration aarch64-apple >/dev/null
[[ $(cat "$log") == "mkinitcpio -P" && -e $marker ]] || fail "a Mac busybox encrypt line without asahi rebuilds" "log=$(cat "$log" 2>/dev/null)"
pass "a Mac busybox encrypt line without asahi rebuilds"

# A settings package can update before the runtime whose detector still prints
# the old platform name. The baseline treats that as aarch64-apple.
cat >"$stub_bin/omarchy-hw-platform" <<'SH'
#!/bin/bash
printf 'apple-silicon\n'
SH
chmod +x "$stub_bin/omarchy-hw-platform"
write_conf "base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck"
rm -f "$log" "$marker"
run_migration x86 >/dev/null
[[ $(cat "$log") == "mkinitcpio -P" && -e $marker ]] || fail "an apple-silicon detector name still rebuilds the LUKS line" "log=$(cat "$log" 2>/dev/null)"
pass "an apple-silicon detector name still rebuilds the LUKS line"
rm -f "$stub_bin/omarchy-hw-platform"

write_conf "$legacy_luks"
rm -f "$stub_bin/mkinitcpio" "$log" "$marker"
run_migration aarch64-apple >/dev/null
[[ $(cat "$log") == "limine-mkinitcpio " && -e $marker ]] || fail "limine-mkinitcpio rebuilds when mkinitcpio is absent" "log=$(cat "$log" 2>/dev/null)"
pass "limine-mkinitcpio rebuilds when mkinitcpio is absent"
cat >"$stub_bin/mkinitcpio" <<'SH'
#!/bin/bash
printf 'mkinitcpio %s\n' "$*" >>"$TEST_REBUILD_LOG"
exit "${MKINITCPIO_STATUS:-0}"
SH
chmod +x "$stub_bin/mkinitcpio"

write_conf "base asahi udev plymouth autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck"
assert_skipped "a line that already lists plymouth is not rebuilt" aarch64-apple

write_conf "base udev autodetect microcode modconf kms keyboard keymap consolefont block asahi filesystems fsck"
assert_skipped "an unencrypted asahi line is not rebuilt" aarch64-apple

write_conf "base udev autodetect microcode modconf kms keyboard keymap consolefont block encrypt filesystems fsck"
assert_skipped "busybox encrypt off Apple Silicon is not rebuilt" x86
assert_skipped "busybox encrypt on plain aarch64 without asahi is not rebuilt" aarch64

write_conf "base systemd autodetect microcode modconf kms keyboard sd-vconsole block filesystems fsck"
assert_skipped "a new Apple Silicon systemd line is not rebuilt" aarch64-apple

write_conf "$legacy_luks"
printf ':\n' >"$conf_dir/00-omarchy-hooks.conf"
assert_skipped "a held-back drop-in that does not add plymouth is not rebuilt" aarch64-apple

write_conf "$legacy_luks"
rm -f "$install_dir/plymouth" "$log" "$marker"
run_migration aarch64-apple >/dev/null
[[ ! -e $log && ! -e $marker ]] || fail "a machine without the plymouth hook is not rebuilt" "log=$(cat "$log" 2>/dev/null)"
pass "a machine without the plymouth hook is not rebuilt"
printf '#!/bin/bash\n' >"$install_dir/plymouth"

write_conf "$legacy_luks"
rm -f "$log" "$marker"
if MKINITCPIO_STATUS=1 run_migration aarch64-apple >/dev/null; then
  fail "a failed initramfs rebuild stays pending"
fi
[[ ! -e $marker ]] || fail "a failed initramfs rebuild leaves no completion marker"
MKINITCPIO_STATUS=0 run_migration aarch64-apple >/dev/null
[[ $(cat "$log") == $'mkinitcpio -P\nmkinitcpio -P' && -e $marker ]] ||
  fail "a failed initramfs rebuild is retried" "log=$(cat "$log" 2>/dev/null)"
pass "a failed initramfs rebuild stays pending and is retried"
