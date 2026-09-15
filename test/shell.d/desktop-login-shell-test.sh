#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"
export LAUNCH_LOG="$scratch/launch.log"
export PASSWD_SHELL="/bin/sh"
export LOOKUP_UID="$EUID"

cat > "$scratch/bin/getent" <<'STUB'
#!/bin/bash
[[ $1 == "passwd" && $2 == "$LOOKUP_UID" ]] || exit 1
[[ -n $PASSWD_SHELL ]] || exit 2
printf 'account:x:1000:1000::/home/account:%s\n' "$PASSWD_SHELL"
STUB
cat > "$scratch/bin/uwsm-app" <<'STUB'
#!/bin/bash
[[ $1 == "--" && $2 == "gtk-launch" ]] || exit 1
shift
exec "$@"
STUB
cat > "$scratch/bin/gtk-launch" <<'STUB'
#!/bin/bash
printf '%s\n' "$SHELL" "$@" > "$LAUNCH_LOG"
exit "${LAUNCH_STATUS:-0}"
STUB
chmod +x "$scratch/bin/"*
export PATH="$scratch/bin:$PATH"

# USER can be stale too. The lookup must use the actual process UID.
entry='An app; $(touch unwanted).desktop'
USER=another-account SHELL=/bin/bash "$ROOT/bin/omarchy-launch-desktop" "$entry" 'file:///path with spaces'
expected=$(printf '%s\n' /bin/sh "$entry" 'file:///path with spaces')
[[ $(cat "$LAUNCH_LOG") == "$expected" ]] || fail "launch uses the login shell and preserves literal arguments"
pass "a stale desktop SHELL is replaced with the current account's shell"

# Query for each launch, including switching back, without restarting a caller.
PASSWD_SHELL=/bin/bash SHELL=/bin/sh "$ROOT/bin/omarchy-launch-desktop" example.desktop
[[ $(head -n 1 "$LAUNCH_LOG") == "/bin/bash" ]] || fail "launch re-reads the login shell"
pass "later launches pick up another login-shell change"

for unavailable in '' /nonexistent/login-shell; do
  PASSWD_SHELL="$unavailable" SHELL=/bin/sh "$ROOT/bin/omarchy-launch-desktop" example.desktop
  [[ $(head -n 1 "$LAUNCH_LOG") == "/bin/sh" ]] || fail "unavailable login shell preserves inherited SHELL"
done
pass "failed lookup and missing shell retain the inherited environment"

status=0
LAUNCH_STATUS=17 "$ROOT/bin/omarchy-launch-desktop" example.desktop || status=$?
[[ $status == 17 ]] || fail "launcher failure reaches the caller"
pass "desktop launch failure is reported"
