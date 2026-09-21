#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# The real package helpers run over a stubbed pacman inside the sudo boundary
# fixture, so no transaction reaches the host.
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"
for command in omarchy-pkg-add omarchy-pkg-missing omarchy-pkg-present; do
  copy_boundary_file "bin/$command"
done
ln -s ../bin/omarchy-pkg-missing "$SUDO_TEST_ROOT/mock/omarchy-pkg-missing"

tmp_dir="$boundary_tmp"
mkdir -p "$tmp_dir/bin"
export INSTALLED_PACKAGES="$tmp_dir/installed" CALL_LOG="$tmp_dir/calls"
# Only the helpers come from the fixture; its other stand-ins stay off PATH.
for command in omarchy-pkg-add omarchy-pkg-missing omarchy-pkg-present; do
  ln -s "$SUDO_TEST_ROOT/bin/$command" "$tmp_dir/bin/$command"
done
export PATH="$tmp_dir/bin:$PATH"
export OMARCHY_SUDO_NO_UPDATE=1

cat > "$tmp_dir/bin/pacman" <<'SH'
#!/bin/bash
case "$1" in
  -Q)
    shift
    [[ ${1:-} != "--" ]] || shift
    grep -Fxq -- "$1" "$INSTALLED_PACKAGES"
    ;;
  -S)
    [[ ${FAIL_INSTALL:-0} == 0 ]] || exit 1
    for arg in "${@:2}"; do
      [[ $arg == -* ]] && continue
      printf '%s\n' "$arg" >> "$INSTALLED_PACKAGES"
      printf '%s\n' "$arg" >> "$CALL_LOG"
    done
    ;;
  *) exit 1 ;;
esac
SH
chmod +x "$tmp_dir/bin/"*
rm "$SUDO_TEST_ROOT/mock/pacman" "$SUDO_TEST_ROOT/bin/pacman"
ln -s "$tmp_dir/bin/pacman" "$SUDO_TEST_ROOT/mock/pacman"
ln -s "$tmp_dir/bin/pacman" "$SUDO_TEST_ROOT/bin/pacman"

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
