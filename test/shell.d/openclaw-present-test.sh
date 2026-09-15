#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/home/.config/systemd/user"
export HOME="$tmp/home"
export XDG_CONFIG_HOME="$tmp/home/.config"
export PATH="$tmp/bin:$ROOT/bin:/usr/bin:/bin"
export TEST_LOG="$tmp/log"
: >"$TEST_LOG"

cat >"$tmp/bin/omarchy-pkg-present" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$tmp/bin/omarchy-pkg-present"

cat >"$tmp/bin/systemctl" <<'SH'
#!/bin/bash
exit 1
SH
chmod +x "$tmp/bin/systemctl"

if omarchy-openclaw-present; then
  fail "absent OpenClaw should not count as present"
fi
pass "absent OpenClaw is not present"

cat >"$tmp/bin/openclaw" <<'SH'
#!/bin/bash
exit 0
SH
chmod +x "$tmp/bin/openclaw"

omarchy-openclaw-present || fail "PATH openclaw should count as present"
pass "PATH openclaw counts as present"

cat >"$tmp/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf 'pkg-add:%s\n' "$*" >>"$TEST_LOG"
exit 0
SH
chmod +x "$tmp/bin/omarchy-pkg-add"

omarchy-install-openclaw-cli --check || fail "--check should succeed for PATH openclaw"
omarchy-install-openclaw-cli --now || fail "--now should succeed without installing"
if [[ -s $TEST_LOG ]]; then
  fail "--now must not reinstall over a PATH openclaw" "$(cat "$TEST_LOG")"
fi
pass "install-openclaw-cli leaves a PATH openclaw alone"

rm -f "$tmp/bin/openclaw"
touch "$XDG_CONFIG_HOME/systemd/user/openclaw-gateway.service"
omarchy-openclaw-present || fail "gateway unit should count as present"
pass "gateway unit counts as present"

# Shadowed PATH warning (exercise the detection the launcher uses).
rm -f "$XDG_CONFIG_HOME/systemd/user/openclaw-gateway.service"
mkdir -p "$tmp/a" "$tmp/b"
printf '#!/bin/bash\n' >"$tmp/a/openclaw"
printf '#!/bin/bash\n' >"$tmp/b/openclaw"
chmod +x "$tmp/a/openclaw" "$tmp/b/openclaw"
export PATH="$tmp/a:$tmp/b:$tmp/bin:$ROOT/bin:/usr/bin:/bin"
mapfile -t bins < <(type -aP openclaw)
(( ${#bins[@]} > 1 )) || fail "fixture should expose two openclaw binaries"
pass "multiple openclaw binaries are detectable on PATH"
