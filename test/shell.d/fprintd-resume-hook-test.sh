#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

hook="$ROOT/default/systemd/system-sleep/fprintd-resume"

# systemd execs the files in system-sleep/ directly, so a hook without the
# executable bit silently never runs. The installers set the mode explicitly,
# but the checkout should not ship a hook that cannot run as-is either.
[[ -x $hook ]] ||
  fail "the resume hook is executable" "mode: $(stat -c '%A' "$hook")"
pass "the resume hook is executable"

tmpdir=$(mktemp -d)
trap 'rm -rf "$tmpdir"' EXIT

mock_bin="$tmpdir/bin"
call_log="$tmpdir/systemctl-calls"
mkdir -p "$mock_bin"

cat >"$mock_bin/systemctl" <<SH
#!/bin/bash
printf '%s\n' "\$*" >>"$call_log"
SH
chmod +x "$mock_bin/systemctl"

run_hook() {
  : >"$call_log"
  PATH="$mock_bin:$PATH" "$hook" "$@"
}

# Resume ("post") is the only edge that clears a claim wedged across suspend.
# The restart is enqueued, not awaited: user sessions stay frozen until the
# hook returns, and a wedged fprintd can ride out its whole stop timeout.
run_hook post suspend
[[ $(<"$call_log") == "--no-block try-restart fprintd.service" ]] ||
  fail "resume enqueues an fprintd restart to clear a wedged claim" "calls: $(<"$call_log")"
pass "resume enqueues an fprintd restart to clear a wedged claim"

# The claim only wedges once the verify dies under suspend, so there is
# nothing to clear before sleep; a restart there would just take the reader
# away from the verify the lock screen still has open. "pre" must do nothing.
run_hook pre suspend
[[ -z $(<"$call_log") ]] ||
  fail "pre-suspend leaves fprintd alone" "calls: $(<"$call_log")"
pass "pre-suspend leaves fprintd alone"
