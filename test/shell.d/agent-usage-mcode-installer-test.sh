#!/bin/bash

source "$(dirname "$0")/base-test.sh"

require_command npm

TEST_HOME=$(mktemp -d)
trap 'rm -rf "$TEST_HOME"' EXIT

# A clean home with no mcode anywhere: the installer must run npm install
# and drop a marked wrapper at ~/.local/bin/mcode, then --check answers
# non-zero only when neither path answers `mcode --version`.
HOME="$TEST_HOME" "$ROOT/bin/omarchy-install-ai-mcode" --check &>/dev/null &&
  fail "mcode installer --check fails on a fresh home" || true
pass "mcode installer --check fails on a fresh home"

[[ ! -e $TEST_HOME/.local/bin/mcode ]] ||
  fail "mcode installer does not write a wrapper before --now"
pass "mcode installer does not write a wrapper before --now"

[[ ! -e $TEST_HOME/.minimax-code/bin/mcode ]] ||
  fail "mcode installer does not write to ~/.minimax-code/ without the official install"
pass "mcode installer does not write to ~/.minimax-code/ without the official install"

# --owns answers false until --now has actually run.
HOME="$TEST_HOME" "$ROOT/bin/omarchy-install-ai-mcode" --owns &>/dev/null &&
  fail "mcode installer --owns is false before --now" || true
pass "mcode installer --owns is false before --now"

# --now installs the global npm package with the better-sqlite3-friendly
# flags, drops a marked wrapper, and exits 0.
HOME="$TEST_HOME" "$ROOT/bin/omarchy-install-ai-mcode" --now &>/dev/null ||
  fail "mcode installer --now installs the global package"
pass "mcode installer --now installs the global package"

[[ -f $TEST_HOME/.local/bin/mcode && ! -L $TEST_HOME/.local/bin/mcode ]] ||
  fail "mcode installer writes a regular wrapper, not a symlink"
pass "mcode installer writes a regular wrapper, not a symlink"

grep -qxF "# Written by omarchy-install-ai-mcode." "$TEST_HOME/.local/bin/mcode" ||
  fail "mcode wrapper carries the installer's marker"
pass "mcode wrapper carries the installer's marker"

# --owns now answers true once the wrapper is ours.
HOME="$TEST_HOME" "$ROOT/bin/omarchy-install-ai-mcode" --owns &>/dev/null ||
  fail "mcode installer --owns is true after --now"
pass "mcode installer --owns is true after --now"

# The wrapper calls npm's global prefix to find the binary, so a follow-up
# install picks up whatever npm put there.
npm_path=$(HOME="$TEST_HOME" npm prefix -g 2>/dev/null)
[[ -n $npm_path && -e "$npm_path/bin/mcode" ]] ||
  fail "npm places the mcode binary on its own prefix"
pass "npm places the mcode binary on its own prefix"

# --check answers zero when our wrapper answers `mcode --version`.
HOME="$TEST_HOME" "$ROOT/bin/omarchy-install-ai-mcode" --check &>/dev/null ||
  fail "mcode installer --check passes after --now"
pass "mcode installer --check passes after --now"

# A foreign wrapper at ~/.local/bin/mcode -- a symlink or a wrapper without
# the marker -- is never claimed as ours.
rm "$TEST_HOME/.local/bin/mcode"
ln -s /usr/bin/true "$TEST_HOME/.local/bin/mcode"
HOME="$TEST_HOME" "$ROOT/bin/omarchy-install-ai-mcode" --owns &>/dev/null &&
  fail "mcode installer --owns ignores a symlink" || true
pass "mcode installer --owns ignores a symlink"

rm -f "$TEST_HOME/.local/bin/mcode"
cat >"$TEST_HOME/.local/bin/mcode" <<'SH'
#!/bin/bash
echo "user-managed wrapper"
SH
chmod +x "$TEST_HOME/.local/bin/mcode"
HOME="$TEST_HOME" "$ROOT/bin/omarchy-install-ai-mcode" --owns &>/dev/null &&
  fail "mcode installer --owns ignores an unmarked wrapper" || true
pass "mcode installer --owns ignores an unmarked wrapper"

# A foreign wrapper stops --now from overwriting it: --now only writes when
# the slot is empty or ours.
HOME="$TEST_HOME" "$ROOT/bin/omarchy-install-ai-mcode" --now 2>&1 && [[ -f $TEST_HOME/.local/bin/mcode ]] &&
  grep -q "user-managed wrapper" "$TEST_HOME/.local/bin/mcode" ||
  fail "mcode installer --now leaves a foreign wrapper alone"
pass "mcode installer --now leaves a foreign wrapper alone"

# --remove only tears down what this installer put there: the foreign
# wrapper survives, the npm package is left alone (it is the user's, not
# ours, since we never claimed the wrapper).
HOME="$TEST_HOME" "$ROOT/bin/omarchy-install-ai-mcode" --remove &>/dev/null ||
  fail "mcode installer --remove is idempotent on a foreign wrapper"
pass "mcode installer --remove is idempotent on a foreign wrapper"

[[ -f $TEST_HOME/.local/bin/mcode ]] ||
  fail "mcode installer --remove keeps a foreign wrapper"
pass "mcode installer --remove keeps a foreign wrapper"
grep -q "user-managed wrapper" "$TEST_HOME/.local/bin/mcode" ||
  fail "mcode installer --remove does not edit a foreign wrapper"
pass "mcode installer --remove does not edit a foreign wrapper"

# A second --now now succeeds because the slot is empty, and the wrapper
# it writes is ours again.
rm -f "$TEST_HOME/.local/bin/mcode"
HOME="$TEST_HOME" "$ROOT/bin/omarchy-install-ai-mcode" --now &>/dev/null ||
  fail "mcode installer --now succeeds after a foreign wrapper is removed"
pass "mcode installer --now succeeds after a foreign wrapper is removed"

HOME="$TEST_HOME" "$ROOT/bin/omarchy-install-ai-mcode" --owns &>/dev/null ||
  fail "mcode installer --owns is true again after a fresh --now"
pass "mcode installer --owns is true again after a fresh --now"

# --remove this time owns the wrapper and tears it down. The npm package
# is uninstalled; a follow-up --check answers non-zero.
HOME="$TEST_HOME" "$ROOT/bin/omarchy-install-ai-mcode" --remove &>/dev/null ||
  fail "mcode installer --remove tears down its own wrapper"
pass "mcode installer --remove tears down its own wrapper"

[[ ! -e $TEST_HOME/.local/bin/mcode ]] ||
  fail "mcode installer --remove deletes its own wrapper"
pass "mcode installer --remove deletes its own wrapper"

HOME="$TEST_HOME" "$ROOT/bin/omarchy-install-ai-mcode" --check &>/dev/null &&
  fail "mcode installer --check fails after --remove" || true
pass "mcode installer --check fails after --remove"

# When the official mcode install is already on PATH, --now sees it and
# stops without rewriting npm or the wrapper. The wrapper this installer
# had previously written -- the one --remove just took down -- stays
# down; --now also drops any of our wrappers that would shadow the
# official install.
mkdir -p "$TEST_HOME/.minimax-code/bin"
cat >"$TEST_HOME/.minimax-code/bin/mcode" <<'SH'
#!/bin/bash
if [[ ${1:-} == --version ]]; then
  echo "official 0.4.2"
  exit 0
fi
echo "official mcode $*"
SH
chmod +x "$TEST_HOME/.minimax-code/bin/mcode"

# Drop a stale wrapper to confirm --now cleans it up.
cat >"$TEST_HOME/.local/bin/mcode" <<'SH'
# Written by omarchy-install-ai-mcode.
exec /bin/false "$@"
SH
chmod +x "$TEST_HOME/.local/bin/mcode"

HOME="$TEST_HOME" "$ROOT/bin/omarchy-install-ai-mcode" --now &>/dev/null ||
  fail "mcode installer --now exits zero when the official install is present"
pass "mcode installer --now exits zero when the official install is present"

[[ ! -e $TEST_HOME/.local/bin/mcode ]] ||
  fail "mcode installer --now drops a stale wrapper when the official install is present"
pass "mcode installer --now drops a stale wrapper when the official install is present"

HOME="$TEST_HOME" "$ROOT/bin/omarchy-install-ai-mcode" --check &>/dev/null ||
  fail "mcode installer --check answers zero when the official install is present"
pass "mcode installer --check answers zero when the official install is present"
