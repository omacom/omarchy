#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mock_bin="$test_tmp/bin"
export HOME="$test_tmp/home with spaces"
export PATH="$mock_bin:$HOME/.local/bin:$ROOT/bin:/usr/local/bin:/usr/bin"
export OMARCHY_TEST_MISE_LOG="$test_tmp/mise-log"
mkdir -p "$mock_bin" "$HOME/.local/bin"
cat >"$mock_bin/mise" <<'SH'
#!/bin/bash
printf '%s\0' "$@" >>"$OMARCHY_TEST_MISE_LOG"
SH
chmod +x "$mock_bin/mise"

source "$ROOT/install/user/mise.sh"
for agent in kimi cursor-agent muse; do
  [[ -x $HOME/.local/bin/$agent && ! -L $HOME/.local/bin/$agent ]] ||
    fail "provisioning creates the missing $agent wrapper"
  cp "$HOME/.local/bin/$agent" "$test_tmp/$agent-wrapper"
done
mapfile -d '' -t args <"$OMARCHY_TEST_MISE_LOG"
[[ ${args[*]} == "settings set upgrade.auto_prune false reshim" ]] ||
  fail "provisioning creates lazy wrappers without installing packages"
pass "provisioning creates lazy Kimi, Cursor, and Muse wrappers"

for agent in kimi cursor-agent muse; do
  launcher="$HOME/.local/bin/$agent"
  for kind in script binary symlink; do
    rm -f "$launcher"
    case $kind in
      script) printf '#!/bin/bash\necho user-managed command\n' >"$launcher" ;;
      binary) cp /usr/bin/true "$launcher" ;;
      symlink) ln -s /usr/bin/true "$launcher" ;;
    esac
    [[ $kind == "symlink" ]] || chmod +x "$launcher"
    for attempt in 1 2; do
      source "$ROOT/install/user/mise.sh"
      [[ -x $launcher && ! -L $launcher ]] || fail "provisioning replaces the $agent $kind with a wrapper"
      cmp -s "$launcher" "$test_tmp/$agent-wrapper" || fail "provisioning restores the $agent wrapper"
    done
    pass "provisioning restores the $agent wrapper over a $kind on repeated runs"
  done
done
