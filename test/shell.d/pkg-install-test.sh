#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_path="$test_tmp/pkg-install-bin"
mkdir -p "$mock_path"

cat >"$mock_path/pacman" <<'MOCK'
#!/bin/bash
if [[ $1 == "-Sl" ]]; then
  printf '%s\n' \
    "extra ripgrep 15.0.0-1 [installed]" \
    "extra fd 10.3.0-1 [installed: 10.2.0-1]" \
    "extra bat 0.26.0-1" \
    "omarchy quickshell 0.3.2-1 [installed]" \
    "omarchy omarchy-fonts 1.0-1"
  exit 0
fi
if [[ $1 == "-Slq" ]]; then
  printf '%s\n' ripgrep fd bat quickshell omarchy-fonts
  exit 0
fi
exit 1
MOCK

cat >"$mock_path/fzf" <<'MOCK'
#!/bin/bash
cat >"$TEST_TMP/fzf-input"
printf '%s\n' bat
MOCK

cat >"$mock_path/sudo" <<'MOCK'
#!/bin/bash
printf '%s\n' "$*" >"$TEST_TMP/pkg-install-command"
MOCK

: >"$mock_path/omarchy-sudo-keepalive"

cat >"$mock_path/omarchy-show-done" <<'MOCK'
#!/bin/bash
exit 0
MOCK

chmod +x "$mock_path/pacman" "$mock_path/fzf" "$mock_path/sudo" "$mock_path/omarchy-show-done"

PATH="$mock_path:$PATH" TEST_TMP="$test_tmp" "$ROOT/bin/omarchy-pkg-install"

[[ $(<"$test_tmp/fzf-input") == $'bat\nomarchy-fonts' ]] ||
  fail "package picker lists installed packages: $(tr '\n' ' ' <"$test_tmp/fzf-input")"
pass "package picker lists only packages that are not installed"

[[ $(<"$test_tmp/pkg-install-command") == "pacman -S --noconfirm --needed bat" ]] ||
  fail "package install must pass --needed: $(<"$test_tmp/pkg-install-command")"
pass "package install passes --needed to skip reinstalling up-to-date packages"
