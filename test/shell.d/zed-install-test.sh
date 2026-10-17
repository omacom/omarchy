#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_bin="$test_tmp/bin"
export HOME="$test_tmp/home"
mkdir -p "$mock_bin"
ln -s "$ROOT/bin/omarchy-cmd-missing" "$mock_bin/omarchy-cmd-missing"

cat >"$mock_bin/uname" <<'SH'
#!/bin/bash
echo "$OMARCHY_TEST_ARCH"
SH

cat >"$mock_bin/pacman" <<'SH'
#!/bin/bash
printf 'lookup:%s\n' "$*" >>"$OMARCHY_TEST_LOG"
[[ ${OMARCHY_TEST_ZED_AVAILABLE:-0} == "1" ]]
SH

cat >"$mock_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'pkg:%s\n' "$*" >>"$OMARCHY_TEST_LOG"
SH

cat >"$mock_bin/curl" <<'SH'
#!/bin/bash
printf 'curl:%s\n' "$*" >>"$OMARCHY_TEST_LOG"
cat <<'INSTALLER'
printf 'upstream-installer\n' >>"$OMARCHY_TEST_LOG"
mkdir -p "$HOME/.local/bin"
printf '%s\n' '#!/bin/bash' 'echo mock-zed' >"$HOME/.local/bin/zed"
chmod +x "$HOME/.local/bin/zed"
INSTALLER
SH

for command in omazed setsid; do
  cat >"$mock_bin/$command" <<'SH'
#!/bin/bash
exit 0
SH
done

chmod +x "$mock_bin"/*

# Keep fixture utilities available without inheriting host editor commands.
for command in bash sh cat chmod grep ln mkdir readlink rm; do
  ln -s "$(command -v "$command")" "$mock_bin/$command"
done

export OMARCHY_TEST_LOG="$test_tmp/install.log"
export PATH="$mock_bin:$HOME/.local/bin"

reset_fixture() {
  rm -rf "$HOME" "$mock_bin/zeditor"
  : >"$OMARCHY_TEST_LOG"
}

assert_package_path() {
  grep -Fxq 'pkg:zed omazed' "$OMARCHY_TEST_LOG" ||
    fail "Zed installs in the existing package transaction"
  if grep -Eq '^(curl:|upstream-installer$)' "$OMARCHY_TEST_LOG"; then
    fail "package installation does not run the upstream installer"
  fi
}

reset_fixture
OMARCHY_TEST_ARCH=x86_64 OMARCHY_TEST_ZED_AVAILABLE=0 bash "$ROOT/bin/omarchy-install-editor-zed"
assert_package_path
if grep -q '^lookup:' "$OMARCHY_TEST_LOG"; then
  fail "x86_64 skips the package availability lookup"
fi
pass "x86_64 uses packages even with an unavailable sync database"

reset_fixture
OMARCHY_TEST_ARCH=aarch64 OMARCHY_TEST_ZED_AVAILABLE=1 bash "$ROOT/bin/omarchy-install-editor-zed"
assert_package_path
grep -Fxq 'lookup:-Si zed' "$OMARCHY_TEST_LOG" || fail "aarch64 checks package availability"
pass "aarch64 with repo-available Zed uses packages"

export OMARCHY_TEST_ARCH=aarch64
reset_fixture
OMARCHY_TEST_ZED_AVAILABLE=0 bash "$ROOT/bin/omarchy-install-editor-zed"
grep -Fxq 'pkg:omazed' "$OMARCHY_TEST_LOG" ||
  fail "repo-unavailable Zed installs omazed separately"
grep -Fxq 'curl:-fsSL https://zed.dev/install.sh' "$OMARCHY_TEST_LOG" ||
  fail "repo-unavailable Zed downloads the official installer"
grep -Fxq 'upstream-installer' "$OMARCHY_TEST_LOG" ||
  fail "repo-unavailable Zed runs the official installer"
pass "repo-unavailable Zed installs omazed and runs the official installer"

[[ $(command -v zeditor) == "$HOME/.local/bin/zeditor" && -L $HOME/.local/bin/zeditor && $(readlink "$HOME/.local/bin/zeditor") == "zed" ]] ||
  fail "upstream Zed provides the zeditor symlink on PATH"
[[ $(zeditor) == "mock-zed" ]] || fail "zeditor executes the upstream Zed command"
pass "upstream Zed resolves and executes as zeditor"

: >"$OMARCHY_TEST_LOG"
OMARCHY_TEST_ZED_AVAILABLE=0 bash "$ROOT/bin/omarchy-install-editor-zed"
[[ $(zeditor) == "mock-zed" ]] || fail "repeated fallback installation keeps zeditor working"
pass "repeated fallback installation succeeds"

reset_fixture
mkdir -p "$HOME/.local/bin"
ln -s missing-zed "$HOME/.local/bin/zeditor"
OMARCHY_TEST_ZED_AVAILABLE=0 bash "$ROOT/bin/omarchy-install-editor-zed"
[[ -L $HOME/.local/bin/zeditor && $(readlink "$HOME/.local/bin/zeditor") == "zed" && $(zeditor) == "mock-zed" ]] ||
  fail "fallback installation replaces a dangling zeditor link with working Zed"
pass "fallback installation replaces a dangling zeditor link"

reset_fixture
cat >"$mock_bin/zeditor" <<'SH'
#!/bin/bash
echo existing-zeditor
SH
chmod +x "$mock_bin/zeditor"
OMARCHY_TEST_ZED_AVAILABLE=0 bash "$ROOT/bin/omarchy-install-editor-zed"
[[ $(command -v zeditor) == "$mock_bin/zeditor" && $(zeditor) == "existing-zeditor" ]] ||
  fail "fallback installation preserves an existing zeditor on PATH"
[[ ! -e $HOME/.local/bin/zeditor && ! -L $HOME/.local/bin/zeditor ]] ||
  fail "fallback installation does not create a symlink when zeditor exists"
pass "fallback installation leaves an existing zeditor untouched"
