#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
mkdir -p "$tmp_dir/bin"
export INSTALLED_PACKAGES="$tmp_dir/installed" CALL_LOG="$tmp_dir/calls"
export PATH="$tmp_dir/bin:$ROOT/bin:$PATH"

# Keep the real package helpers, but contain every pacman transaction here.
cat > "$tmp_dir/bin/pacman" <<'SH'
#!/bin/bash
case "$1" in
  -Q) grep -Fxq -- "$2" "$INSTALLED_PACKAGES" ;;
  -S)
    [[ ${FAIL_INSTALL:-0} == 0 ]] || exit 1
    shift 3 # -S --noconfirm --needed
    printf '%s\n' "$@" >> "$INSTALLED_PACKAGES"
    printf '%s\n' "$@" >> "$CALL_LOG"
    ;;
  *) exit 1 ;;
esac
SH
cat > "$tmp_dir/bin/sudo" <<'SH'
#!/bin/bash
[[ $1 == "pacman" ]] || exit 1
"$@"
SH
chmod +x "$tmp_dir/bin/"*

migration="$ROOT/migrations/1789546355.sh"
for kernels in linux linux-lts linux-zen linux-hardened 'linux linux-lts linux-zen linux-hardened' 'linux linux-omarchy linux-omarchy-headers' 'linux linux-t2 linux-t2-headers'; do
  read -ra installed <<< "$kernels"
  printf '%s\n' broadcom-wl-dkms dkms "${installed[@]}" > "$INSTALLED_PACKAGES"
  : > "$CALL_LOG"
  bash -euo pipefail "$migration" >/dev/null
  for kernel in "${installed[@]}"; do
    [[ $kernel == *-headers || $kernel == linux-omarchy || $kernel == linux-t2 ]] && continue
    grep -Fxq "$kernel-headers" "$INSTALLED_PACKAGES" || fail "$kernel gets its headers"
  done
  ! grep -Eq "^linux-(omarchy|t2)-headers$" "$CALL_LOG" || fail "the Omarchy and T2 kernels are left to their existing repair"
  : > "$CALL_LOG"
  bash -euo pipefail "$migration" >/dev/null
  [[ ! -s $CALL_LOG ]] || fail "header repair is idempotent"
  pass "missing headers are repaired once for $kernels"
done

printf '%s\n' linux > "$INSTALLED_PACKAGES"
: > "$CALL_LOG"
bash -euo pipefail "$migration" >/dev/null
[[ ! -s $CALL_LOG ]] || fail "machines without broadcom-wl-dkms are left alone"
pass "machines without broadcom-wl-dkms are left alone"

printf '%s\n' broadcom-wl-dkms linux > "$INSTALLED_PACKAGES"
if FAIL_INSTALL=1 bash -euo pipefail "$migration" >/dev/null; then
  fail "a failed header installation must leave the migration pending"
fi
pass "header installation failure is propagated"

for packages in 'broadcom-wl-dkms' 'broadcom-wl-dkms linux-custom' 'broadcom-wl-dkms linux-omarchy linux-t2'; do
  read -ra installed <<< "$packages"
  printf '%s\n' "${installed[@]}" > "$INSTALLED_PACKAGES"
  : > "$CALL_LOG"
  bash -euo pipefail "$migration" >/dev/null
  [[ ! -s $CALL_LOG ]] || fail "unsupported or separately managed kernels are not guessed"
  pass "no stock header repair for $packages"
done

# A failed transaction leaves the script retryable; the next successful attempt
# repairs the missing headers without repeating successful transactions.
printf '%s\n' broadcom-wl-dkms linux linux-lts > "$INSTALLED_PACKAGES"
: > "$CALL_LOG"
if FAIL_INSTALL=1 bash -euo pipefail "$migration" >/dev/null; then
  fail "a multi-kernel header transaction failure must not be hidden"
fi
[[ ! -s $CALL_LOG ]] || fail "a failed first transaction must stop later kernel repairs"
bash -euo pipefail "$migration" >/dev/null
grep -Fxq linux-headers "$INSTALLED_PACKAGES" || fail "retry repairs linux headers"
grep -Fxq linux-lts-headers "$INSTALLED_PACKAGES" || fail "retry repairs LTS headers"
pass "a failed transaction stops and can be retried"
