#!/bin/bash

set -euo pipefail

source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

# Remove > AI > ChatGPT must take ~/.config/Codex and ~/.cache/Codex with it
# even when the app's artifact runtime left read-only directories behind
# (#16033): rm -rf cannot delete files inside a directory the user owns but
# cannot write to, so the script has to make everything writable first.

# As root, rm -rf ignores missing write permission, so the fixture cannot
# reproduce the failure for the superuser.
if (( EUID == 0 )); then
  skip "running as root, where rm -rf ignores read-only directories; skipping read-only Codex config removal"
  exit 0
fi

work=$(mktemp -d)
trap 'chmod -R u+w "$work" 2>/dev/null; rm -rf "$work"' EXIT

# A stub omarchy-pkg-drop, so the fixture exercises the script's own removal
# work without touching this machine's packages.
stub_bin="$work/stub"
mkdir -p "$stub_bin"
printf '#!/bin/bash\nexit 0\n' >"$stub_bin/omarchy-pkg-drop"
chmod +x "$stub_bin/omarchy-pkg-drop"

# A config and cache tree shaped like the one the artifact runtime leaves
# behind: user-owned directories without write permission, all the way down.
fake_home="$work/home"
readonly_dirs=(
  "$fake_home/.config/Codex/artifact-sessions/runtime-generations/generation-1/runtime"
  "$fake_home/.config/Codex/artifact-sessions/runtime-generations/generation-1/runtime/bin"
  "$fake_home/.config/Codex/artifact-sessions/runtime-generations/generation-1/runtime/node_modules/@oai/artifact-tool"
  "$fake_home/.cache/Codex/artifact-sessions/runtime-generations/generation-2/runtime"
)
mkdir -p "${readonly_dirs[@]}"
printf 'module.exports = {}\n' >"${readonly_dirs[1]}/index.js"
printf 'cache\n' >"${readonly_dirs[3]}/cache.dat"

if ! chmod 500 "${readonly_dirs[@]}"; then
  skip "cannot create read-only directories on this filesystem; skipping read-only Codex config removal"
  exit 0
fi

run_script() {
  local out="$work/out" err="$work/err"

  if HOME="$fake_home" PATH="$stub_bin:$PATH" "$ROOT/bin/omarchy-remove-ai-chatgpt" >"$out" 2>"$err"; then
    return 0
  fi

  cat "$err" >&2
  return 1
}

if ! run_script; then
  fail "omarchy-remove-ai-chatgpt exits 0 on a read-only Codex config" "the script died instead of removing \$HOME/.config/Codex and \$HOME/.cache/Codex"
fi
pass "omarchy-remove-ai-chatgpt exits 0 on a read-only Codex config"

if [[ -e $fake_home/.config/Codex || -e $fake_home/.cache/Codex ]]; then
  fail "the read-only Codex config and cache are gone" "$(ls -la "$fake_home/.config" "$fake_home/.cache" 2>&1)"
fi
pass "the read-only Codex config and cache are gone"

if ! grep -q "ChatGPT has been removed." "$work/out"; then
  fail "the removal reports success" "$(cat "$work/out" "$work/err" 2>&1)"
fi
pass "the removal reports success"

# Without read-only directories the script must still clean up and succeed.
mkdir -p "$fake_home/.config/Codex" "$fake_home/.cache/Codex"
printf 'settings\n' >"$fake_home/.config/Codex/config.json"

if ! run_script; then
  fail "omarchy-remove-ai-chatgpt exits 0 on an ordinary Codex config"
fi
pass "omarchy-remove-ai-chatgpt exits 0 on an ordinary Codex config"

if [[ -e $fake_home/.config/Codex || -e $fake_home/.cache/Codex ]]; then
  fail "an ordinary Codex config and cache are gone"
fi
pass "an ordinary Codex config and cache are gone"

# A Codex config that is a symlink goes, and its target's permissions do not change.
linked="$work/linked"
mkdir -p "$linked/runtime"
chmod 500 "$linked/runtime"
ln -s "$linked" "$fake_home/.config/Codex"

if ! run_script; then
  fail "omarchy-remove-ai-chatgpt exits 0 on a symlinked Codex config"
fi
pass "omarchy-remove-ai-chatgpt exits 0 on a symlinked Codex config"

if [[ -L $fake_home/.config/Codex ]] || [[ $(stat -c %a "$linked/runtime") != "500" ]]; then
  fail "the symlink is removed and its target left untouched" "$(ls -la "$fake_home/.config" "$linked" 2>&1)"
fi
pass "the symlink is removed and its target left untouched"
