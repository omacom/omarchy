#!/bin/bash

source "$(dirname "${BASH_SOURCE[0]}")/base-test.sh"

set -euo pipefail

command_under_test="$ROOT/bin/omarchy-plymouth-ttfx-build"
tmp=$(mktemp -d "${TMPDIR:-/var/tmp}/ttfx-test.XXXXXXXX")
printf 'Test fixtures: %s\n' "$tmp"

mkdir -p "$tmp/bin" "$tmp/pkg"
cat >"$tmp/module.c" <<'C'
__attribute__((visibility("default"))) void *ply_boot_splash_plugin_get_interface(void) { return 0; }
C
gcc -shared -fPIC -fvisibility=hidden -Wl,-z,relro,-z,now -s "$tmp/module.c" -o "$tmp/ttfx-plymouth.so"

cat >"$tmp/bin/pacman" <<'SH'
#!/bin/bash
printf 'plymouth %s\n' "${TEST_PLYMOUTH_VERSION:?}"
SH
cat >"$tmp/bin/pkgconf" <<'SH'
#!/bin/bash
case "$1" in
--modversion) printf '%s\n%s\n' "${TEST_PKGCONFIG_VERSION:?}" "${TEST_PKGCONFIG_VERSION:?}" ;;
--cflags|--libs) printf '\n' ;;
*) exit 2 ;;
esac
SH
chmod +x "$tmp/bin/pacman" "$tmp/bin/pkgconf"

run_stage() {
  env PATH="$tmp/bin:/usr/bin:/bin" \
    TEST_PLYMOUTH_VERSION="$1" TEST_PKGCONFIG_VERSION="$2" \
    "$command_under_test" stage --module "$tmp/ttfx-plymouth.so" --destdir "$tmp/pkg"
}

if run_stage 26.134.223-1 26.134.222 >"$tmp/out" 2>"$tmp/err"; then
  fail "native package rejects a different Plymouth ABI"
fi
grep -F 'unsupported Plymouth ABI' "$tmp/err" >/dev/null || fail "ABI refusal explains the supported ABI"
pass "native package rejects a different Plymouth ABI"

mv -- "$tmp/pkg" "$tmp/pkg-retired"
run_stage 26.134.222-2 26.134.222 >"$tmp/out" 2>"$tmp/err" || fail "native package accepts an ABI-matched package release" "$(cat "$tmp/err")"
module="$tmp/pkg/usr/lib/plymouth/ttfx-plymouth.so"
descriptor="$tmp/pkg/usr/share/plymouth/themes/omarchy/omarchy.plymouth"
recovery="$tmp/pkg/usr/share/plymouth/themes/omarchy-static/omarchy-static.plymouth"
[[ -f $module ]] || fail "stage writes the current ModuleName path"
[[ $(stat -c %a "$module") == "755" ]] || fail "staged module is executable for mkinitcpio add_binary"
grep -Fx 'ModuleName=ttfx-plymouth' "$descriptor" >/dev/null || fail "native descriptor selects the staged module"
for entry in 'Enabled=true' 'Mode=fixed' 'Effect=decrypt' 'Seed=22321466108495961' 'PlaybackMode=submit-to-finish'; do
  grep -Fx "$entry" "$descriptor" >/dev/null || fail "native package default is exact decrypt tuple: $entry"
done
grep -Fx 'ModuleName=script' "$recovery" >/dev/null || fail "stage includes a static recovery descriptor"
recovery_script="$tmp/pkg/usr/share/plymouth/themes/omarchy-static/omarchy.script"
[[ -f $recovery_script ]] || fail "static recovery includes its script"
grep -Fq 'logo.image = Image("logo.png")' "$recovery_script" || fail "static recovery renders its logo"
if grep -Eq 'logo[.]frames|animation/frame-[^[:space:]]*[.]png' "$recovery_script"; then
  fail "static recovery cannot load animation frames"
fi
pass "ABI-matched release stages module and native/static themes"

exports=$(nm -D --defined-only --format=posix "$module" | awk '{print $1}')
[[ $exports == "ply_boot_splash_plugin_get_interface" ]] || fail "stage rejects unexpected module exports"
readelf -lW "$module" | grep -F GNU_RELRO >/dev/null || fail "staged module retains RELRO"
readelf -dW "$module" | grep -Eq 'BIND_NOW|FLAGS.*NOW' || fail "staged module retains immediate binding"
if readelf -SW "$module" | grep -q '\.debug'; then
  fail "staged module is stripped of debug sections"
fi
pass "staged module passes symbol and hardening inspection"

cat >"$tmp/bin/cargo" <<'SH'
#!/bin/bash
printf '%s\n' "$*" >"${TEST_CARGO_LOG:?}"
[[ ${CARGO_TARGET_DIR:-} == /* ]] || exit 75
mkdir -p "$CARGO_TARGET_DIR/plymouth"
: >"$CARGO_TARGET_DIR/plymouth/libttfx_plymouth.a"
SH
cat >"$tmp/bin/gcc" <<'SH'
#!/bin/bash
output=
while (( $# )); do
  if [[ $1 == "-o" ]]; then output=$2; shift 2; else shift; fi
done
cp -- "${TEST_BUILT_MODULE:?}" "$output"
SH
chmod +x "$tmp/bin/cargo" "$tmp/bin/gcc"
output="$tmp/built/ttfx-plymouth.so"
sentinel="$ROOT/native/plymouth-ttfx-engine/target/plymouth/.package-test-sentinel"
mkdir -p -- "${sentinel%/*}"
printf 'untouched\n' >"$sentinel"
env PATH="$tmp/bin:/usr/bin:/bin" \
  TEST_PLYMOUTH_VERSION=26.134.222-9 TEST_PKGCONFIG_VERSION=26.134.222 \
  TEST_CARGO_LOG="$tmp/cargo.log" TEST_BUILT_MODULE="$tmp/ttfx-plymouth.so" \
  "$command_under_test" build --output "$output" >"$tmp/out" 2>"$tmp/err" ||
  fail "package build creates a validated module" "$(cat "$tmp/err")"
[[ -f $output ]] || fail "package build publishes its requested output"
grep -Fx 'build --locked --offline --profile plymouth' "$tmp/cargo.log" >/dev/null || fail "package build uses the locked vendored Rust source offline"
[[ $(<"$sentinel") == untouched ]] || fail "package build touched the source-tree Cargo target"
rm -f -- "$sentinel"
pass "package build produces a validated artifact without runtime Rust"

cat >"$tmp/bin/cargo" <<'SH'
#!/bin/bash
mkdir -p "${CARGO_TARGET_DIR:?}/plymouth"
printf stale >"$CARGO_TARGET_DIR/plymouth/partial"
exit 77
SH
chmod +x "$tmp/bin/cargo"
failed_output="$tmp/failed/ttfx-plymouth.so"
if env PATH="$tmp/bin:/usr/bin:/bin" \
  TEST_PLYMOUTH_VERSION=26.134.222-9 TEST_PKGCONFIG_VERSION=26.134.222 \
  "$command_under_test" build --output "$failed_output" >"$tmp/out" 2>"$tmp/err"; then
  fail "failed package build reports failure"
fi
if compgen -G "$tmp/failed/.ttfx-plymouth-target.*" >/dev/null ||
  compgen -G "$tmp/failed/.ttfx-plymouth.so.*" >/dev/null; then
  fail "failed package build removes all temporary artifacts"
fi
pass "failed package build cleans its isolated Cargo target"
