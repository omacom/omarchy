#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
calls="$test_tmp/calls"
mkdir -p "$mock_bin"

cat >"$mock_bin/sudo" <<'SH'
#!/bin/bash
case $1 in
  -v) exit "$TEST_SUDO_STATUS" ;;
  -n) exit 0 ;;
  *) printf 'sudo %s\n' "$*" >>"$TEST_CALLS" ;;
esac
SH

cat >"$mock_bin/fzf" <<'SH'
#!/bin/bash
cat >/dev/null
echo test-package
SH

cat >"$mock_bin/pacman" <<'SH'
#!/bin/bash
echo test-package
SH

cat >"$mock_bin/yay" <<'SH'
#!/bin/bash
if [[ $1 == "-Slqa" ]]; then
  echo test-package
else
  printf 'yay %s\n' "$*" >>"$TEST_CALLS"
fi
SH

cat >"$mock_bin/omarchy-show-done" <<'SH'
#!/bin/bash
printf 'omarchy-show-done %s\n' "$*" >>"$TEST_CALLS"
SH

chmod +x "$mock_bin"/*

run_install() {
  local script=$1 sudo_status=$2

  : >"$calls"
  PATH="$mock_bin:$ROOT/bin:$PATH" TEST_CALLS="$calls" TEST_SUDO_STATUS="$sudo_status" \
    bash "$ROOT/bin/$script" </dev/null >/dev/null 2>&1
}

declare -A expected_calls=(
  [omarchy-pkg-install]=$'sudo pacman -S --noconfirm test-package\nomarchy-show-done 0'
  [omarchy-pkg-aur-install]=$'yay -S --noconfirm aur/test-package\nsudo updatedb --prune-bind-mounts=no --add-prunepaths=/.snapshots\nomarchy-show-done 0'
)

for script in omarchy-pkg-install omarchy-pkg-aur-install; do
  if run_install "$script" 1; then
    fail "$script exits non-zero when the sudo prompt is cancelled"
  fi
  [[ ! -s $calls ]] || fail "$script installs nothing when the sudo prompt is cancelled" "$(cat "$calls")"
  pass "$script stops when the sudo prompt is cancelled"

  run_install "$script" 0 || fail "$script succeeds once sudo is authorized" "$(cat "$calls")"
  [[ $(<"$calls") == "${expected_calls[$script]}" ]] || fail "$script installs once sudo is authorized" "$(cat "$calls")"
  pass "$script installs once sudo is authorized"
done
