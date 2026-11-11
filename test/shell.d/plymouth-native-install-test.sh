#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"
set -euo pipefail

installer="$ROOT/bin/omarchy-plymouth-ttfx-install"
tmp=$(mktemp -d "${TMPDIR:-/var/tmp}/ttfx-test.XXXXXXXX")
printf 'Test fixtures: %s\n' "$tmp"
root="$tmp/root"
mkdir -p "$root/usr/lib/plymouth" "$root/usr/share/plymouth/themes/omarchy/animation" \
  "$root/usr/share/omarchy/default/plymouth" "$root/boot/EFI/Linux" "$tmp/bin"
printf old-module >"$root/usr/lib/plymouth/ttfx-plymouth.so"
cp -a "$ROOT/default/plymouth/." "$root/usr/share/plymouth/themes/omarchy/"
cp -a "$ROOT/default/plymouth/." "$root/usr/share/omarchy/default/plymouth/"
chmod 0755 "$root" "$root/usr" "$root/usr/share" "$root/usr/share/omarchy" \
  "$root/usr/share/omarchy/default" "$root/usr/share/omarchy/default/plymouth"
chmod 0644 "$root/usr/share/omarchy/default/plymouth/omarchy.plymouth" \
  "$root/usr/share/plymouth/themes/omarchy/ttfx-effects.txt"
printf old-uki >"$root/boot/EFI/Linux/omarchy_linux.efi"
printf spinner >"$tmp/current-theme"
mkdir -p "$root/usr/share/plymouth/themes/omarchy-static"
printf old-recovery >"$root/usr/share/plymouth/themes/omarchy-static/marker"
ln -s marker "$root/usr/share/plymouth/themes/omarchy-static/marker-link"
cp -a "$root/usr/share/plymouth/themes/omarchy-static" "$tmp/expected-recovery"
cp -a "$root/usr/share/plymouth/themes/omarchy/omarchy.plymouth" "$tmp/expected-descriptor"
mkdir -p "$tmp/artifacts"
cat >"$tmp/module.c" <<'C'
__attribute__((visibility("default"))) void *ply_boot_splash_plugin_get_interface(void) { return 0; }
C
gcc -shared -fPIC -fvisibility=hidden -Wl,-z,relro,-z,now -s "$tmp/module.c" -o "$tmp/artifacts/module.so"
chmod 0755 "$tmp/artifacts" "$tmp/artifacts/module.so"
module_source="$tmp/artifacts/module.so"

cat >"$tmp/bin/plymouth-set-default-theme" <<'SH'
#!/bin/bash
if (( $# )); then
  printf '%s' "$1" >"${TEST_CURRENT_THEME:?}"
  printf 'activate:%s\n' "$1" >>"${TEST_LOG:?}"
else
  [[ ${TEST_FAIL_THEME_QUERY:-0} != 1 ]] || exit 71
  cat "${TEST_CURRENT_THEME:?}"
fi
SH
cat >"$tmp/bin/rebuild" <<'SH'
#!/bin/bash
printf 'rebuild:%s:%s\n' "$(cat "${TEST_CURRENT_THEME:?}")" "$(cat "${TEST_ROOT:?}/usr/lib/plymouth/ttfx-plymouth.so")" >>"${TEST_LOG:?}"
count_file=${TEST_REBUILD_COUNT:?}
count=0
[[ ! -f $count_file ]] || count=$(<"$count_file")
printf '%s' "$((count + 1))" >"$count_file"
if [[ ${TEST_FAIL_FIRST_REBUILD:-0} == 1 && $count == 0 ]]; then exit 1; fi
if [[ ${TEST_BOOT_FORMAT:-uki} == "classic" ]]; then
  mkdir -p "${TEST_ROOT:?}/boot"
  if [[ ! -f ${TEST_ROOT:?}/etc/mkinitcpio.d/linux-asahi.preset ]]; then
    rm -f -- "${TEST_ROOT:?}"/boot/initramfs-*.img
  fi
  printf 'initramfs:%s' "$(cat "${TEST_CURRENT_THEME:?}")" >"${TEST_ROOT:?}/boot/initramfs-linux-asahi.img"
  exit 0
fi
rm -f -- "${TEST_ROOT:?}"/boot/EFI/Linux/omarchy_linux*.efi
if [[ ${TEST_UKI_MODE:-single} == "none-first" && $count == 0 ]]; then exit 0; fi
if [[ ${TEST_UKI_MODE:-single} == "rollback-partial" ]]; then
  if (( count == 0 )); then exit 0; fi
  mkdir -p "${TEST_ROOT:?}/boot/EFI/Linux"
  printf partial-corrupt >"${TEST_ROOT:?}/boot/EFI/Linux/omarchy_linux.efi"
  exit 1
fi
mkdir -p "${TEST_ROOT:?}/boot/EFI/Linux"
if [[ ${TEST_UKI_MODE:-single} == "multiple" && $count == 0 ]]; then
  printf 'uki:%s' "$(cat "${TEST_CURRENT_THEME:?}")" >"${TEST_ROOT:?}/boot/EFI/Linux/omarchy_linux-a.efi"
  printf 'uki:%s' "$(cat "${TEST_CURRENT_THEME:?}")" >"${TEST_ROOT:?}/boot/EFI/Linux/omarchy_linux-z-bad.efi"
else
  printf 'uki:%s' "$(cat "${TEST_CURRENT_THEME:?}")" >"${TEST_ROOT:?}/boot/EFI/Linux/omarchy_linux.efi"
fi
SH
chmod +x "$tmp/bin/plymouth-set-default-theme" "$tmp/bin/rebuild"
cat >"$tmp/bin/pacman" <<'SH'
#!/bin/bash
printf 'plymouth %s\n' "${TEST_PLYMOUTH_VERSION:?}"
SH
cat >"$tmp/bin/pkgconf" <<'SH'
#!/bin/bash
printf '%s\n%s\n' "${TEST_PKGCONFIG_VERSION:?}" "${TEST_PKGCONFIG_VERSION:?}"
SH
chmod +x "$tmp/bin/pacman" "$tmp/bin/pkgconf"
cat >"$tmp/bin/lsinitcpio" <<'SH'
#!/bin/bash
image=${2:-}
if [[ $image != *-bad.efi ]]; then
  printf '%s\n' usr/lib/plymouth/ttfx-plymouth.so
fi
cat <<EOF
usr/share/plymouth/themes/omarchy/omarchy.plymouth
usr/share/plymouth/themes/omarchy/omarchy.script
usr/share/plymouth/themes/omarchy/logo.png
usr/lib/libc.so.6
EOF
[[ -z ${TEST_EXTRA_INITRAMFS_PATH:-} ]] || printf '%s\n' "$TEST_EXTRA_INITRAMFS_PATH"
SH
chmod +x "$tmp/bin/lsinitcpio"
cat >"$tmp/bin/ldd" <<'SH'
#!/bin/bash
printf '%s\n' "${TEST_LDD_OUTPUT:-/usr/lib/libc.so.6}"
SH
chmod +x "$tmp/bin/ldd"
cat >"$tmp/bin/file" <<'SH'
#!/bin/bash
[[ -z ${TEST_FILE_LOG:-} ]] || printf '%s\n' "$1" >>"$TEST_FILE_LOG"
exec /usr/bin/file "$@"
SH
chmod +x "$tmp/bin/file"
cat >"$tmp/bin/cp" <<'SH'
#!/bin/bash
if [[ ${TEST_FAIL_DESCRIPTOR_BACKUP:-0} == 1 && $* == *'/omarchy.plymouth'* && $* == *'/backup/descriptor'* ]]; then
  exit 72
fi
if [[ ${TEST_FAIL_MODULE_RESTORE:-0} == 1 && $* == *'--remove-destination'* && $* == *'/backup/module'* ]]; then
  exit 73
fi
exec /usr/bin/cp "$@"
SH
chmod +x "$tmp/bin/cp"
cat >"$tmp/bin/sed" <<'SH'
#!/bin/bash
target=${!#}
if [[ $target == *'/.omarchy-static.'* ]]; then
  printf '%s\n' "$target" >>"${TEST_STAGE_LOG:?}"
  if [[ ${TEST_CANCEL_RECOVERY_STAGE:-0} == 1 ]]; then
    kill -TERM "$PPID"
    exit 143
  fi
  [[ ${TEST_FAIL_RECOVERY_STAGE:-0} != 1 ]] || exit 74
elif [[ $target == *'/.omarchy.plymouth.'* ]]; then
  printf '%s\n' "$target" >>"${TEST_STAGE_LOG:?}"
  [[ ${TEST_FAIL_DESCRIPTOR_STAGE:-0} != 1 ]] || exit 75
fi
exec /usr/bin/sed "$@"
SH
chmod +x "$tmp/bin/sed"

canonical_libc=$(realpath -e /usr/lib/libc.so.6)
env_common=(
  PATH="$tmp/bin:/usr/bin:/bin"
  TEST_LDD_OUTPUT="$canonical_libc" TEST_EXTRA_INITRAMFS_PATH="${canonical_libc#/}"
  TEST_PLYMOUTH_VERSION=26.134.222-2 TEST_PKGCONFIG_VERSION=26.134.222
  OMARCHY_PLYMOUTH_TEST_ROOT="$root"
  OMARCHY_PLYMOUTH_TEST_SOURCE_ROOT="$tmp/artifacts"
  OMARCHY_PLYMOUTH_THEME_COMMAND="$tmp/bin/plymouth-set-default-theme"
  OMARCHY_PLYMOUTH_REBUILD_COMMAND="$tmp/bin/rebuild"
  OMARCHY_LSINITCPIO="$tmp/bin/lsinitcpio"
  OMARCHY_PLYMOUTH_TEST_DEPENDENCIES=/usr/lib/libc.so.6
  TEST_ROOT="$root" TEST_CURRENT_THEME="$tmp/current-theme"
  TEST_LOG="$tmp/log" TEST_REBUILD_COUNT="$tmp/rebuild-count" TEST_FILE_LOG="$tmp/file-log"
  TEST_STAGE_LOG="$tmp/stage-log"
)

if ! env "${env_common[@]}" INSTALLER="$installer" bash -c '
  source <(/usr/bin/sed "/^case /,\$d" "$INSTALLER")
  path_is_within_anchor /trusted/module.so /
  ! path_is_within_anchor /trusted-escape/module.so /trusted
'; then
  fail "source containment accepts a canonical path below root and rejects a sibling escape"
fi
pass "source containment handles the production root anchor"

if env "${env_common[@]}" OMARCHY_PLYMOUTH_TEST_DEPENDENCIES= TEST_LDD_OUTPUT='libmissing.so => not found' \
  "$installer" --verify-initramfs "$root/boot/EFI/Linux/omarchy_linux.efi" >"$tmp/out" 2>"$tmp/err"; then
  fail "initramfs verifier rejects an unresolved module dependency"
fi
grep -F 'unresolved module dependency: libmissing.so' "$tmp/err" >/dev/null || fail "unresolved dependency refusal names the library"
pass "initramfs verifier rejects unresolved ldd dependencies"

for loader in /lib64/ld-linux-x86-64.so.2 /lib/ld-linux-aarch64.so.1; do
  [[ -e $loader ]] && break
done
canonical_loader=$(realpath -e "$loader")
if ! env "${env_common[@]}" OMARCHY_PLYMOUTH_TEST_DEPENDENCIES= \
  TEST_LDD_OUTPUT=$loader \
  TEST_EXTRA_INITRAMFS_PATH=${canonical_loader#/} \
  "$installer" --verify-initramfs "$root/boot/EFI/Linux/omarchy_linux.efi" >"$tmp/out" 2>"$tmp/err"; then
  fail "initramfs verifier resolves loader symlinks before checking the image" "$(cat "$tmp/err")"
fi
pass "initramfs verifier compares canonical dependency paths"

if env "${env_common[@]}" TEST_PLYMOUTH_VERSION=26.135.0-1 "$installer" --module "$module_source" >"$tmp/out" 2>"$tmp/err"; then
  fail "runtime installer rejects an incompatible Plymouth ABI"
fi
[[ $(<"$root/usr/lib/plymouth/ttfx-plymouth.so") == "old-module" ]] || fail "ABI refusal leaves last known-good module untouched"
pass "runtime ABI gate fails before publication"

for retired in "$root/run"/omarchy-plymouth-install.*; do
  [[ ! -e $retired ]] || mv -- "$retired" "$tmp/retired-${retired##*/}"
done
if env "${env_common[@]}" TEST_FAIL_DESCRIPTOR_BACKUP=1 "$installer" --module "$module_source" >"$tmp/out" 2>"$tmp/err"; then
  fail "descriptor backup failure reports failure"
fi
if compgen -G "$root/run/omarchy-plymouth-install.*" >/dev/null; then
  fail "descriptor backup failure cleans the root work directory" "$(cat "$tmp/err"); leaked: $(printf '%s ' "$root/run"/omarchy-plymouth-install.*)"
fi
[[ $(<"$root/usr/lib/plymouth/ttfx-plymouth.so") == "old-module" ]] || fail "backup failure does not mutate the module"
pass "backup failure cannot leak privileged transaction work"

rm -f "$tmp/rebuild-count"
if env "${env_common[@]}" TEST_FAIL_THEME_QUERY=1 "$installer" --module "$module_source" >"$tmp/out" 2>"$tmp/err"; then
  fail "active theme query failure reports failure"
fi
if compgen -G "$root/run/omarchy-plymouth-install.*" >/dev/null; then
  fail "active theme query failure cleans the root work directory"
fi
pass "theme query failure cannot leak privileged transaction work"

: >"$tmp/stage-log"
rm -f "$tmp/rebuild-count"
mkdir -p "$root/usr/share/plymouth/themes/omarchy-static.new"
printf stale >"$root/usr/share/plymouth/themes/omarchy-static.new/marker"
if env "${env_common[@]}" TEST_CANCEL_RECOVERY_STAGE=1 "$installer" --module "$module_source" >"$tmp/out" 2>"$tmp/err"; then
  fail "cancellation while staging recovery reports failure"
fi
recovery_stage_path=$(grep '/.omarchy-static.[^/]*/omarchy-static.plymouth$' "$tmp/stage-log" || true)
[[ $recovery_stage_path == "$root/usr/share/plymouth/themes/.omarchy-static."* ]] || fail "recovery is staged beside its destination" "stage log: $(cat "$tmp/stage-log"); error: $(cat "$tmp/err")"
if compgen -G "$root/usr/share/plymouth/themes/.omarchy-static.*" >/dev/null; then
  fail "recovery cancellation removes its destination-filesystem stage"
fi
[[ ! -e $root/usr/share/plymouth/themes/omarchy-static.new ]] || fail "recovery cancellation removes the legacy .new stage"
diff -r "$tmp/expected-recovery" "$root/usr/share/plymouth/themes/omarchy-static" >/dev/null || fail "recovery cancellation preserves the exact prior tree"
pass "recovery staging is same-filesystem and cancellation-clean"

: >"$tmp/stage-log"
rm -f "$tmp/rebuild-count"
if env "${env_common[@]}" TEST_FAIL_DESCRIPTOR_STAGE=1 "$installer" --module "$module_source" >"$tmp/out" 2>"$tmp/err"; then
  fail "descriptor staging failure reports failure"
fi
descriptor_stage_path=$(grep '/.omarchy.plymouth.' "$tmp/stage-log")
[[ $descriptor_stage_path == "$root/usr/share/plymouth/themes/omarchy/.omarchy.plymouth."* ]] || fail "descriptor is staged beside its destination" "$descriptor_stage_path"
if compgen -G "$root/usr/share/plymouth/themes/omarchy/.omarchy.plymouth.*" >/dev/null; then
  fail "descriptor failure removes its destination-filesystem stage"
fi
cmp -s "$tmp/expected-descriptor" "$root/usr/share/plymouth/themes/omarchy/omarchy.plymouth" || fail "descriptor failure restores the exact prior descriptor"
diff -r "$tmp/expected-recovery" "$root/usr/share/plymouth/themes/omarchy-static" >/dev/null || fail "descriptor failure restores the exact prior recovery tree"
pass "descriptor staging is same-filesystem and failure-clean"

: >"$tmp/log"
rm -f "$tmp/rebuild-count"
if env "${env_common[@]}" TEST_FAIL_FIRST_REBUILD=1 TEST_FAIL_MODULE_RESTORE=1 "$installer" --module "$module_source" >"$tmp/out" 2>"$tmp/err"; then
  fail "failed restore still reports the original install failure"
fi
cmp -s "$tmp/expected-descriptor" "$root/usr/share/plymouth/themes/omarchy/omarchy.plymouth" || fail "a failed module restore does not prevent descriptor restoration"
diff -r "$tmp/expected-recovery" "$root/usr/share/plymouth/themes/omarchy-static" >/dev/null || fail "a failed module restore does not prevent recovery restoration"
[[ $(<"$tmp/current-theme") == "spinner" ]] || fail "a failed module restore does not prevent theme restoration"
[[ $(<"$tmp/rebuild-count") == 2 ]] || fail "a failed module restore does not prevent restored-state rebuild"
printf old-module >"$root/usr/lib/plymouth/ttfx-plymouth.so"
pass "rollback attempts every restoration after an earlier restore fails"

: >"$tmp/log"
rm -f "$tmp/rebuild-count"
if env "${env_common[@]}" TEST_FAIL_FIRST_REBUILD=1 "$installer" --module "$module_source" >"$tmp/out" 2>"$tmp/err"; then
  fail "failed native rebuild reports failure"
fi
[[ $(<"$root/usr/lib/plymouth/ttfx-plymouth.so") == "old-module" ]] || fail "failed rebuild restores last known-good module"
[[ $(<"$root/boot/EFI/Linux/omarchy_linux.efi") == "uki:spinner" ]] || fail "failed rebuild restores and rebuilds last known-good UKI" "$(cat "$tmp/err")"
[[ $(<"$tmp/current-theme") == "spinner" ]] || fail "failed rebuild restores the previous active descriptor"
grep -Fx 'activate:omarchy-static' "$tmp/log" >/dev/null || fail "installer activates static recovery before replacing native state"
grep -Fx 'activate:omarchy' "$tmp/log" >/dev/null || fail "installer activates native theme only after publication"
pass "failed native activation rolls module, descriptor, theme, and UKI back through static recovery"

: >"$tmp/log"
rm -f "$tmp/rebuild-count"
if env "${env_common[@]}" TEST_UKI_MODE=none-first "$installer" --module "$module_source" >"$tmp/out" 2>"$tmp/err"; then
  fail "native install rejects a rebuild that produces no boot image"
fi
grep -F 'rebuild produced no boot image' "$tmp/err" >/dev/null || fail "missing boot image refusal explains the failure"
[[ $(<"$root/usr/lib/plymouth/ttfx-plymouth.so") == "old-module" ]] || fail "missing boot image rolls the module back"
pass "native install requires at least one rebuilt boot image"

: >"$tmp/log"
rm -f "$tmp/rebuild-count"
if env "${env_common[@]}" TEST_UKI_MODE=multiple "$installer" --module "$module_source" >"$tmp/out" 2>"$tmp/err"; then
  fail "native install verifies every rebuilt UKI"
fi
grep -F 'omarchy_linux-z-bad.efi' "$tmp/err" >/dev/null || fail "multi-UKI verification identifies the broken image"
[[ $(<"$root/usr/lib/plymouth/ttfx-plymouth.so") == "old-module" ]] || fail "broken secondary UKI rolls the module back"
pass "native install verifies every rebuilt UKI"

printf old-uki >"$root/boot/EFI/Linux/omarchy_linux.efi"
: >"$tmp/log"
rm -f "$tmp/rebuild-count"
if env "${env_common[@]}" TEST_UKI_MODE=rollback-partial "$installer" --module "$module_source" >"$tmp/out" 2>"$tmp/err"; then
  fail "missing UKI with failed rollback rebuild reports failure"
fi
[[ $(<"$root/boot/EFI/Linux/omarchy_linux.efi") == "old-uki" ]] || fail "failed rollback rebuild cannot replace the preserved known-good UKI"
pass "failed rollback rebuild recopies the preserved UKI"

mv -- "$root/boot/EFI/Linux" "$tmp/retired-uki"
: >"$tmp/log"
rm -f "$tmp/rebuild-count"
if env "${env_common[@]}" TEST_UKI_MODE=multiple "$installer" --module "$module_source" >"$tmp/out" 2>"$tmp/err"; then
  fail "broken secondary UKI fails when no UKI directory existed before installation"
fi
[[ ! -e $root/boot/EFI/Linux ]] || fail "rollback removes a UKI directory created by the failed transaction"
pass "rollback restores an absent UKI directory"
mkdir -p "$root/boot/EFI/Linux"
printf old-uki >"$root/boot/EFI/Linux/omarchy_linux.efi"

: >"$tmp/log"
: >"$tmp/file-log"
rm -f "$tmp/rebuild-count"
# Simulate the first package transition: pacman preserved the old descriptor
# and wrote the new package copy elsewhere, so the live file has no [ttfx].
cat >"$root/usr/share/plymouth/themes/omarchy/omarchy.plymouth" <<'EOF'
[Plymouth Theme]
Name=Omarchy
ModuleName=script
[script]
ImageDir=/usr/share/plymouth/themes/omarchy
ScriptFile=/usr/share/plymouth/themes/omarchy/omarchy.script
EOF
env "${env_common[@]}" "$installer" --module "$module_source" >"$tmp/out" 2>"$tmp/err" || fail "native install succeeds" "$(cat "$tmp/err")"
grep -Fx '[Daemon]' "$root/etc/plymouth/plymouthd.conf" >/dev/null || fail "installer repairs an empty Plymouth configuration before theme activation"
grep -E "^$root/usr/lib/plymouth/[.]ttfx-plymouth[.]so[.]" "$tmp/file-log" >/dev/null || fail "module is validated on destination filesystem before atomic publication"
cmp -s "$module_source" "$root/usr/lib/plymouth/ttfx-plymouth.so" || fail "successful install publishes new module"
[[ $(stat -c %a "$root/usr/lib/plymouth/ttfx-plymouth.so") == "755" ]] || fail "installed module is executable for mkinitcpio add_binary"
[[ $(<"$tmp/current-theme") == "omarchy" ]] || fail "successful install activates native descriptor"
[[ $(<"$root/boot/EFI/Linux/omarchy_linux.efi") == "uki:omarchy" ]] || fail "successful install commits rebuilt UKI"
for entry in '[ttfx]' 'Enabled=true' 'Mode=fixed' 'Effect=decrypt' 'Seed=22321466108495961' 'PlaybackMode=submit-to-finish' 'BackgroundColor=1a1b26'; do
  grep -Fx "$entry" "$root/usr/share/plymouth/themes/omarchy/omarchy.plymouth" >/dev/null ||
    fail "upgrade normalization materializes complete native descriptor entry: $entry"
done
pass "successful install atomically publishes native state before rebuilding"
pass "legacy package descriptor is normalized from immutable native template"

sed -i 's/^Mode=.*/Mode=invalid/' "$root/usr/share/plymouth/themes/omarchy/omarchy.plymouth"
: >"$tmp/log"
rm -f "$tmp/rebuild-count"
env "${env_common[@]}" "$installer" --module "$module_source" >"$tmp/out" 2>"$tmp/err" ||
  fail "native reinstall safely normalizes malformed selector" "$(cat "$tmp/err")"
for entry in 'Enabled=false' 'Mode=off' 'Effect=off' 'Seed=0'; do
  grep -Fx "$entry" "$root/usr/share/plymouth/themes/omarchy/omarchy.plymouth" >/dev/null ||
    fail "malformed native selector degrades to off: $entry"
done
pass "malformed existing native selector degrades to off"

sed -i \
  -e 's/^Enabled=.*/Enabled=true/' \
  -e 's/^Mode=.*/Mode=fixed/' \
  -e 's/^Effect=.*/Effect=decrypt/' \
  -e 's/^Seed=.*/Seed=18446744073709551615/' \
  -e 's/^PlaybackMode=.*/PlaybackMode=continuous/' \
  -e 's/^BackgroundColor=.*/BackgroundColor=112233/' \
  -e 's/^TextColor=.*/TextColor=aabbcc/' \
  -e 's/^MessageColor=.*/MessageColor=445566/' \
  "$root/usr/share/plymouth/themes/omarchy/omarchy.plymouth"
: >"$tmp/log"
rm -f "$tmp/rebuild-count"
env "${env_common[@]}" "$installer" --module "$module_source" >"$tmp/out" 2>"$tmp/err" ||
  fail "native reinstall preserves valid selector and branding" "$(cat "$tmp/err")"
for entry in 'Enabled=true' 'Mode=fixed' 'Effect=decrypt' 'Seed=18446744073709551615' 'PlaybackMode=continuous' \
  'BackgroundColor=112233' 'TextColor=aabbcc' 'MessageColor=445566'; do
  grep -Fx "$entry" "$root/usr/share/plymouth/themes/omarchy/omarchy.plymouth" >/dev/null ||
    fail "native descriptor normalization preserves valid state: $entry"
done
pass "native descriptor normalization preserves valid selector and branding"

sed -i \
  -e 's/^Enabled=.*/Enabled=false/' \
  -e 's/^Mode=.*/Mode=off/' \
  -e 's/^Effect=.*/Effect=off/' \
  -e 's/^Seed=.*/Seed=0/' \
  "$root/usr/share/plymouth/themes/omarchy/omarchy.plymouth"
: >"$tmp/log"
rm -f "$tmp/rebuild-count"
env "${env_common[@]}" "$installer" --module "$module_source" >"$tmp/out" 2>"$tmp/err" ||
  fail "native reinstall preserves explicit off selection" "$(cat "$tmp/err")"
for entry in 'Enabled=false' 'Mode=off' 'Effect=off' 'Seed=0'; do
  grep -Fx "$entry" "$root/usr/share/plymouth/themes/omarchy/omarchy.plymouth" >/dev/null ||
    fail "native descriptor normalization preserves explicit off: $entry"
done
pass "native descriptor normalization preserves explicit off selection"

cp "$module_source" "$tmp/original-module.so"
cat >"$tmp/replacement.c" <<'C'
static const char replacement_marker[] = "replacement-module";
__attribute__((visibility("default"))) void *ply_boot_splash_plugin_get_interface(void) { return (void *) replacement_marker; }
C
gcc -shared -fPIC -fvisibility=hidden -Wl,-z,relro,-z,now -s "$tmp/replacement.c" -o "$tmp/replacement.so"
chmod 0755 "$tmp/replacement.so"
cat >"$tmp/bin/replace-source" <<'SH'
#!/bin/bash
cp -- "${TEST_REPLACEMENT:?}" "${TEST_SOURCE:?}.new"
mv -fT "${TEST_SOURCE:?}.new" "${TEST_SOURCE:?}"
printf opened >"${TEST_OPEN_HOOK_RAN:?}"
SH
chmod +x "$tmp/bin/replace-source"
: >"$tmp/log"
rm -f "$tmp/rebuild-count" "$tmp/open-hook-ran"
env "${env_common[@]}" OMARCHY_PLYMOUTH_TEST_AFTER_OPEN_COMMAND="$tmp/bin/replace-source" \
  TEST_SOURCE="$module_source" TEST_REPLACEMENT="$tmp/replacement.so" TEST_OPEN_HOOK_RAN="$tmp/open-hook-ran" \
  "$installer" --module "$module_source" >"$tmp/out" 2>"$tmp/err" || fail "stable-fd install succeeds" "$(cat "$tmp/err")"
[[ -f $tmp/open-hook-ran ]] || fail "source replacement hook ran after the installer opened the artifact"
cmp -s "$tmp/original-module.so" "$root/usr/lib/plymouth/ttfx-plymouth.so" || fail "installer publishes bytes from the stable source fd"
cmp -s "$tmp/replacement.so" "$module_source" || fail "TOCTOU fixture replaced the source pathname"
pass "installer never reopens the source pathname after locking"

cat >"$tmp/bin/lsinitcpio" <<'SH'
#!/bin/bash
cat <<EOF
usr/lib/plymouth/ttfx-plymouth.so
usr/share/plymouth/themes/omarchy/omarchy.plymouth
usr/share/plymouth/themes/omarchy/omarchy.script
usr/share/plymouth/themes/omarchy/logo.png
usr/lib/libc.so.6
EOF
SH
chmod +x "$tmp/bin/lsinitcpio"
env OMARCHY_PLYMOUTH_TEST_ROOT="$root" OMARCHY_LSINITCPIO="$tmp/bin/lsinitcpio" OMARCHY_PLYMOUTH_TEST_DEPENDENCIES=/usr/lib/libc.so.6 \
  "$installer" --verify-initramfs "$root/boot/EFI/Linux/omarchy_linux.efi" >/dev/null || fail "initramfs verifier accepts stock-hook module/theme/dependency closure"
pass "lsinitcpio contract proves stock hook inclusion without a custom hook"

classic_root="$tmp/classic-root"
cp -a "$root" "$classic_root"
mv -- "$classic_root/boot/EFI/Linux" "$tmp/retired-classic-uki"
printf old-classic >"$classic_root/boot/initramfs-linux-asahi.img"
printf spinner >"$tmp/classic-current-theme"
: >"$tmp/classic-log"
rm -f "$tmp/classic-rebuild-count"
classic_env=(
  "${env_common[@]}"
  OMARCHY_PLYMOUTH_TEST_ROOT="$classic_root"
  TEST_ROOT="$classic_root"
  TEST_CURRENT_THEME="$tmp/classic-current-theme"
  TEST_LOG="$tmp/classic-log"
  TEST_REBUILD_COUNT="$tmp/classic-rebuild-count"
  TEST_BOOT_FORMAT=classic
)
env "${classic_env[@]}" "$installer" --module "$module_source" >"$tmp/out" 2>"$tmp/err" ||
  fail "native install succeeds with classic initramfs" "$(cat "$tmp/err")"
[[ $(<"$classic_root/boot/initramfs-linux-asahi.img") == "initramfs:omarchy" ]] ||
  fail "classic initramfs is rebuilt and verified"
[[ ! -e $classic_root/boot/EFI/Linux ]] || fail "classic install does not fabricate a Limine UKI directory"
pass "native install supports GRUB classic initramfs images"

printf old-classic >"$classic_root/boot/initramfs-linux-asahi.img"
printf spinner >"$tmp/classic-current-theme"
: >"$tmp/classic-log"
rm -f "$tmp/classic-rebuild-count"
if env "${classic_env[@]}" TEST_FAIL_FIRST_REBUILD=1 "$installer" --module "$module_source" >"$tmp/out" 2>"$tmp/err"; then
  fail "classic initramfs rebuild failure reports failure"
fi
[[ $(<"$classic_root/boot/initramfs-linux-asahi.img") == "initramfs:spinner" ]] ||
  fail "classic rollback rebuilds the restored theme"
[[ $(<"$tmp/classic-current-theme") == "spinner" ]] || fail "classic rollback restores previous theme"
pass "classic initramfs rollback rebuilds the restored state"

# A Mac keeps hand-saved images of earlier kernels beside the preset's image.
# mkinitcpio -P never rebuilds them, so the install must neither verify nor
# roll them back.
mkdir -p "$classic_root/etc/mkinitcpio.d"
cat >"$classic_root/etc/mkinitcpio.d/linux-asahi.preset" <<'PRESET'
ALL_kver="/boot/vmlinuz-linux-asahi"
PRESETS=('default')
default_image="/boot/initramfs-linux-asahi.img"
#fallback_image="/boot/initramfs-linux-asahi-fallback.img"
PRESET
# Like the real tool, the listing of an image built before the native module
# lacks it.
cat >"$tmp/bin/lsinitcpio-classic" <<'SH'
#!/bin/bash
[[ $(<"${!#}") != "kept-by-hand" ]] || exit 0
exec "${TEST_LSINITCPIO:?}" "$@"
SH
chmod +x "$tmp/bin/lsinitcpio-classic"
classic_env+=(OMARCHY_LSINITCPIO="$tmp/bin/lsinitcpio-classic" TEST_LSINITCPIO="$tmp/bin/lsinitcpio")
printf old-classic >"$classic_root/boot/initramfs-linux-asahi.img"
printf kept-by-hand >"$classic_root/boot/initramfs-asahi-previous.img"
printf spinner >"$tmp/classic-current-theme"
: >"$tmp/classic-log"
rm -f "$tmp/classic-rebuild-count"
env "${classic_env[@]}" "$installer" --module "$module_source" >"$tmp/out" 2>"$tmp/err" ||
  fail "native install ignores a classic image no preset names" "$(cat "$tmp/err")"
[[ $(<"$classic_root/boot/initramfs-linux-asahi.img") == "initramfs:omarchy" ]] ||
  fail "the preset's classic image is rebuilt and verified"
[[ $(<"$classic_root/boot/initramfs-asahi-previous.img") == "kept-by-hand" ]] ||
  fail "a hand-saved classic image is left as it was"
printf old-classic >"$classic_root/boot/initramfs-linux-asahi.img"
printf spinner >"$tmp/classic-current-theme"
rm -f "$tmp/classic-rebuild-count"
if env "${classic_env[@]}" TEST_FAIL_FIRST_REBUILD=1 "$installer" --module "$module_source" >"$tmp/out" 2>"$tmp/err"; then
  fail "a failed preset rebuild reports failure"
fi
[[ $(<"$classic_root/boot/initramfs-asahi-previous.img") == "kept-by-hand" ]] ||
  fail "rollback leaves a hand-saved classic image as it was"
pass "classic install verifies and rolls back only the images the presets name"

# The outer installer owns the same shared lock across snapshot and commit.
# A child must inherit the exact open file description, not just any descriptor
# or an independent open of that same inode.
mkdir -p "$root/run/lock"
shared_lock="$root/run/lock/omarchy-plymouth.lock"
cat >"$tmp/lock-probe" <<'SH'
#!/bin/bash
set -euo pipefail
source <(/usr/bin/sed "/^case /,\$d" "$INSTALLER")
acquire_plymouth_lock
printf 'shared lock acquired\n'
SH
chmod +x "$tmp/lock-probe"
exec {held_lock}>"$shared_lock"
flock -x "$held_lock"

status=0
timeout 1 env "${env_common[@]}" INSTALLER="$installer" "$tmp/lock-probe" >"$tmp/lock.out" 2>"$tmp/lock.err" || status=$?
[[ $status == 124 && ! -s $tmp/lock.out ]] || fail "ordinary child waits for the shared Plymouth lock" "$(cat "$tmp/lock.err")"

if ! timeout 5 env "${env_common[@]}" INSTALLER="$installer" OMARCHY_PLYMOUTH_LOCK_FD="$held_lock" "$tmp/lock-probe" >"$tmp/lock.out" 2>"$tmp/lock.err"; then
  fail "a valid inherited shared lock completes without deadlock" "$(cat "$tmp/lock.err")"
fi
grep -Fxq 'shared lock acquired' "$tmp/lock.out" || fail "inherited descriptor did not acquire the real lock"

exec {unrelated_lock}>"$tmp/unrelated.lock"
status=0
timeout 1 env "${env_common[@]}" INSTALLER="$installer" OMARCHY_PLYMOUTH_LOCK_FD="$unrelated_lock" "$tmp/lock-probe" >"$tmp/lock.out" 2>"$tmp/lock.err" || status=$?
[[ $status == 124 && ! -s $tmp/lock.out ]] || fail "an unrelated descriptor cannot bypass the shared lock" "$(cat "$tmp/lock.err")"
exec {unrelated_lock}>&-

exec {independent_lock}>"$shared_lock"
status=0
timeout 1 env "${env_common[@]}" INSTALLER="$installer" OMARCHY_PLYMOUTH_LOCK_FD="$independent_lock" "$tmp/lock-probe" >"$tmp/lock.out" 2>"$tmp/lock.err" || status=$?
[[ $status == 124 && ! -s $tmp/lock.out ]] || fail "an independent open of the same inode cannot bypass its owner" "$(cat "$tmp/lock.err")"
exec {independent_lock}>&-
exec {held_lock}>&-
pass "shared Plymouth lock permits only a validated inherited open file description"
