#!/bin/bash
set -euo pipefail

root=$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)
engine_root="$root/../plymouth-ttfx-engine"
engine_header="$engine_root/include/ttfx_plymouth.h"
# Build both languages on the target so cross-architecture lab runs cannot
# accidentally link a host static library into the target Plymouth module.
remote=${PLYMOUTH_BUILD_HOST:?Set PLYMOUTH_BUILD_HOST to the SSH target to validate}
port=${PLYMOUTH_BUILD_PORT:-22}
ssh_opts=(-p "$port" -o BatchMode=yes)
scp_opts=(-P "$port" -o BatchMode=yes)

"$root/generate-embedded-logo.py" --check
grep -q 'TTFX_GLYPH_COUNT 523U' "$root/glyph-atlas.generated.h"
grep -q '0x' "$root/glyph-atlas.generated.h"

remote_dir=$(ssh "${ssh_opts[@]}" "$remote" 'mktemp -d /var/tmp/plymouth-ttfx-plugin.XXXXXX')
mkdir -p "$root/build"
local_output=$(mktemp "$root/build/.plymouth-ttfx.so.XXXXXX")
cleanup() {
  rm -f -- "$local_output"
  printf 'Retained target artifacts: %s:%s\n' "$remote" "$remote_dir"
}
trap cleanup EXIT
trap 'exit 130' INT
trap 'exit 143' TERM

scp "${scp_opts[@]}" \
  "$root/plugin.c" \
  "$root/state.c" \
  "$root/state.h" \
  "$root/embedded-logo.h" \
  "$root/glyph-atlas.generated.h" \
  "$root/exports.map" \
  "$root/tests/state-test.c" \
  "$root/tests/real-pixelbuffer-test.c" \
  "$engine_header" \
  "$remote:$remote_dir/"

tar --exclude='./target' --exclude='./vendor/ttfx/target' -C "$engine_root" -cf - . |
  ssh "${ssh_opts[@]}" "$remote" "mkdir -p '$remote_dir/engine' && tar -xf - -C '$remote_dir/engine'"

ssh "${ssh_opts[@]}" "$remote" bash -s -- "$remote_dir" <<'REMOTE_BUILD'
set -euo pipefail
cd "$1"
(cd engine && cargo build --locked --offline --profile plymouth)
cp engine/target/plymouth/libttfx_plymouth.a .
printf '%s\n' '== target =='
package=$(pacman -Q plymouth)
printf '%s\n' "$package"
[[ $package == 'plymouth 26.134.222' || $package == 'plymouth 26.134.222-'* ]] || { printf 'unexpected Plymouth package: %s\n' "$package" >&2; exit 1; }
printf '%s\n' '== pkg-config cflags =='
pkgconf --cflags ply-splash-core ply-splash-graphics
printf '%s\n' '== pkg-config libs =='
pkgconf --libs ply-splash-core ply-splash-graphics
cflags=()
for flag in $(pkgconf --cflags ply-splash-core ply-splash-graphics); do
  if [[ $flag == -I* ]]; then
    cflags+=("-isystem" "${flag#-I}")
  else
    cflags+=("$flag")
  fi
done
read -r -a libs <<<"$(pkgconf --libs ply-splash-core ply-splash-graphics)"
printf '%s\n' '== state unit tests =='
gcc -std=c11 -Wall -Wextra -Wpedantic -Werror state-test.c state.c -o state-test
./state-test
printf '%s\n' '== real Plymouth pixelbuffer readback =='
gcc -std=c11 -Wall -Wextra -Wpedantic -Werror "${cflags[@]}" -I. \
  real-pixelbuffer-test.c state.c "${libs[@]}" -o real-pixelbuffer-test
./real-pixelbuffer-test
printf '%s\n' '== shared module compile =='
printf '%s\n' 'gcc -std=c11 -fPIC -shared -fvisibility=hidden -Wall -Wextra -Wpedantic -Werror -Wl,-z,defs -Wl,-z,relro,-z,now -Wl,--exclude-libs,ALL -Wl,--version-script=exports.map [pkg-config cflags] -I. plugin.c state.c libttfx_plymouth.a [pkg-config libs] -ldl -lpthread -lm -o plymouth-ttfx.so.unstripped.tmp'
gcc -std=c11 -fPIC -shared -fvisibility=hidden -Wall -Wextra -Wpedantic -Werror \
  -Wl,-z,defs -Wl,-z,relro,-z,now -Wl,--exclude-libs,ALL -Wl,--version-script=exports.map \
  "${cflags[@]}" -I. plugin.c state.c libttfx_plymouth.a "${libs[@]}" \
  -ldl -lpthread -lm -o plymouth-ttfx.so.unstripped.tmp
before=$(stat -c %s plymouth-ttfx.so.unstripped.tmp)
cp -- plymouth-ttfx.so.unstripped.tmp plymouth-ttfx.so.stripped.tmp
strip --strip-unneeded plymouth-ttfx.so.stripped.tmp
after=$(stat -c %s plymouth-ttfx.so.stripped.tmp)
printf 'module bytes: unstripped=%s stripped=%s\n' "$before" "$after"
(( after < before * 9 / 10 )) || { printf 'stripped module is not materially smaller\n' >&2; exit 1; }
if readelf -SW plymouth-ttfx.so.stripped.tmp | grep -q '\.debug'; then
  printf 'stripped module still contains debug sections\n' >&2
  exit 1
fi
mv -f -- plymouth-ttfx.so.stripped.tmp plymouth-ttfx.so
printf '%s\n' '== file =='
file plymouth-ttfx.so
printf '%s\n' '== ELF header and RELRO =='
readelf -h plymouth-ttfx.so
readelf -lW plymouth-ttfx.so | grep GNU_RELRO
readelf -dW plymouth-ttfx.so | grep -E 'BIND_NOW|FLAGS.*NOW'
printf '%s\n' '== exported defined dynamic symbols =='
exports=$(nm -D --defined-only --format=posix plymouth-ttfx.so | awk '{print $1}')
printf '%s\n' "$exports"
[[ $exports == 'ply_boot_splash_plugin_get_interface' ]] || { printf 'unexpected dynamic exports\n' >&2; exit 1; }
if nm -D plymouth-ttfx.so | grep -q 'ttfx_engine_'; then
  printf 'Rust engine symbol leaked into dynamic symbol table\n' >&2
  exit 1
fi
printf '%s\n' '== dependencies =='
ldd_output=$(ldd plymouth-ttfx.so)
printf '%s\n' "$ldd_output"
if grep -q 'not found' <<<"$ldd_output"; then
  printf 'unresolved runtime dependency\n' >&2
  exit 1
fi
REMOTE_BUILD

scp "${scp_opts[@]}" "$remote:$remote_dir/plymouth-ttfx.so" "$local_output"
mv -f -- "$local_output" "$root/build/plymouth-ttfx.so"
printf 'module: %s\n' "$root/build/plymouth-ttfx.so"
