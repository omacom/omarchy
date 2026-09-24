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

migration="$ROOT/migrations/1789444024.sh"
for kernels in linux-omarchy linux-t2 'linux-omarchy linux-t2'; do
  read -ra installed <<< "$kernels"
  printf '%s\n' linux linux-headers "${installed[@]}" > "$INSTALLED_PACKAGES"
  : > "$CALL_LOG"
  bash -euo pipefail "$migration" >/dev/null
  for kernel in "${installed[@]}"; do
    grep -Fxq "$kernel-headers" "$INSTALLED_PACKAGES" || fail "$kernel gets its headers"
  done
  : > "$CALL_LOG"
  bash -euo pipefail "$migration" >/dev/null
  [[ ! -s $CALL_LOG ]] || fail "header repair is idempotent"
  pass "missing headers are repaired once for $kernels"
done

printf '%s\n' linux linux-aarch64 > "$INSTALLED_PACKAGES"
: > "$CALL_LOG"
bash -euo pipefail "$migration" >/dev/null
[[ ! -s $CALL_LOG ]] || fail "header repair skips unrelated kernels"
pass "header repair skips unrelated kernels"

echo linux-omarchy > "$INSTALLED_PACKAGES"
if FAIL_INSTALL=1 bash -euo pipefail "$migration" >/dev/null; then
  fail "a failed header installation must leave the migration pending"
fi
pass "header installation failure is propagated"
