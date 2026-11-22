#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# A window opened by an agent's command doesn't inherit the agent's colorless,
# pagerless environment, and one opened by the user keeps what they set.

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

# The terminal stands in for the whole launch chain and records what the
# command in the window would see.
mkdir -p "$test_tmp/bin"
for command in setsid uwsm-app; do
  printf '#!/bin/bash\n[[ $1 == "--" ]] && shift\nexec "$@"\n' >"$test_tmp/bin/$command"
done
cat >"$test_tmp/bin/xdg-terminal-exec" <<STUB
#!/bin/bash
printf 'NO_COLOR=%s PAGER=%s GIT_PAGER=%s args=%s\\n' "\${NO_COLOR-unset}" "\${PAGER-unset}" "\${GIT_PAGER-unset}" "\$*" >"$test_tmp/window"
STUB
chmod +x "$test_tmp/bin"/*

launch() {
  rm -f "$test_tmp/window"
  env -u NO_COLOR -u PAGER -u GIT_PAGER "$@" PATH="$test_tmp/bin:$PATH" bash "$ROOT/bin/omarchy-launch-tui" --app-id=org.omarchy.test btop --utf-force
  cat "$test_tmp/window"
}

[[ $(launch NO_COLOR=1 PAGER=cat GIT_PAGER=cat) == "NO_COLOR=unset PAGER=unset GIT_PAGER=unset args=--app-id=org.omarchy.test -e btop --utf-force" ]] ||
  fail "a window opened from an agent's command gets its colors and pager back" "$(cat "$test_tmp/window")"
pass "a window opened from an agent's command gets its colors and pager back"

[[ $(launch NO_COLOR=1 PAGER=less) == "NO_COLOR=1 PAGER=less GIT_PAGER=unset args="* ]] ||
  fail "NO_COLOR the user set for themselves stays" "$(cat "$test_tmp/window")"
[[ $(launch PAGER=cat GIT_PAGER=delta) == "NO_COLOR=unset PAGER=cat GIT_PAGER=delta args="* ]] ||
  fail "a pager the user chose stays" "$(cat "$test_tmp/window")"
[[ $(launch) == "NO_COLOR=unset PAGER=unset GIT_PAGER=unset args="* ]] ||
  fail "a plain launch is unchanged" "$(cat "$test_tmp/window")"
pass "what the user set for themselves stays as it is"
