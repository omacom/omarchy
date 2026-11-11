#!/bin/bash
set -euo pipefail

ROOT=$(cd "$(dirname "$0")/../.." && pwd)
fail() { printf 'not ok - %s\n' "$1" >&2; exit 1; }
pass() { printf 'ok - %s\n' "$1"; }

helper="$ROOT/bin/omarchy-plymouth-handoff"
autostart="$ROOT/default/hypr/autostart.lua"
dropin="$ROOT/default/systemd/system/plymouth-quit.service.d/10-omarchy-retain-splash.conf"

[[ -x $helper ]] || fail "boot handoff helper is installed as an executable"
[[ -f $dropin ]] || fail "Plymouth quit drop-in retains the last splash"
grep -Fx 'ExecStart=' "$dropin" >/dev/null || fail "drop-in clears the vendor quit command"
grep -Fx "ExecStart=/usr/bin/sh -c '/usr/bin/timeout -k 1s 3s /usr/bin/plymouth quit --retain-splash || /usr/bin/systemctl start omarchy-plymouth-reap.service'" "$dropin" >/dev/null ||
  fail "drop-in retains Plymouth until the compositor modeset with bounded cleanup"
grep -Fx 'ExecStartPost=/usr/bin/systemctl start omarchy-plymouth-reap.timer' "$dropin" >/dev/null ||
  fail "drop-in arms the bounded Plymouth cleanup timer"
grep -Fx "ExecStartPre=-/usr/bin/timeout -k 1s 3s /usr/bin/plymouth deactivate" "$dropin" >/dev/null ||
  fail "drop-in releases Plymouth DRM master before retaining the last splash"
pass "Plymouth deactivates before retaining its last real TTFX frame through display-manager startup"

early_line=$(grep -n 'omarchy-plymouth-handoff --launch-shell' "$autostart" | cut -d: -f1)
[[ $early_line =~ ^[0-9]+$ ]] || fail "serialized handoff launcher is missing from Hyprland startup"
grep -Fx '  hl.exec_cmd("omarchy-launch-shell")' "$autostart" >/dev/null &&
  fail "Quickshell is still launched independently and can win the controller lock"
pass "handoff claims startup before launching Quickshell"

tmp=$(mktemp -d "${TMPDIR:-/var/tmp}/ttfx-test.XXXXXXXX")
printf 'Test fixtures: %s\n' "$tmp"
mkdir -p "$tmp/runtime"
cat >"$tmp/descriptor" <<'EOF'
[Plymouth Theme]
ModuleName=ttfx-plymouth
[ttfx]
Mode=fixed
Enabled=true
Effect=decrypt
Seed=18446744073709551615
EOF
printf '%s\n' decrypt dissolve >"$tmp/catalog"
chmod 0644 "$tmp/descriptor" "$tmp/catalog"
cat >"$tmp/hyprctl" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$HANDOFF_TEST_LOG"
EOF
cat >"$tmp/launcher" <<'EOF'
#!/bin/bash
line=launcher
for arg in "$@"; do line+=" <$arg>"; done
printf '%s\n' "$line" >>"$HANDOFF_TEST_LOG"
if (( $# == 0 )); then
  [[ ! -e $XDG_RUNTIME_DIR/omarchy-plymouth-handoff.active ]] || exit 21
  printf 'fallback active=no\n' >>"$HANDOFF_TEST_LOG"
  [[ ${HANDOFF_TEST_FALLBACK_FAIL:-false} == false ]] || exit 22
  sleep 0.15
  kill -0 "$PPID" || exit 23
  printf 'fallback parent=alive\n' >>"$HANDOFF_TEST_LOG"
elif [[ ${HANDOFF_TEST_READY:-false} == true ]]; then
  touch "$XDG_RUNTIME_DIR/omarchy-plymouth-handoff.ready"
  sleep 0.15
else
  exit 17
fi
EOF
cat >"$tmp/omarchy-launch-shell" <<'EOF'
#!/bin/bash
if [[ -e $XDG_RUNTIME_DIR/omarchy-plymouth-handoff.active ]]; then
  printf 'shell active=yes\n' >>"$HANDOFF_TEST_LOG"
else
  printf 'shell active=no\n' >>"$HANDOFF_TEST_LOG"
fi
EOF
chmod +x "$tmp/hyprctl" "$tmp/launcher" "$tmp/omarchy-launch-shell"
printf 'stale\n' >"$tmp/runtime/omarchy-plymouth-handoff.ready"

HANDOFF_TEST_LOG="$tmp/log" \
PATH="$tmp:/usr/bin:/bin" \
XDG_RUNTIME_DIR="$tmp/runtime" \
OMARCHY_PLYMOUTH_DESCRIPTOR="$tmp/descriptor" \
OMARCHY_PLYMOUTH_EFFECT_CATALOG="$tmp/catalog" \
OMARCHY_TTFX_BG_LAUNCHER="$tmp/launcher" \
"$helper"

first=$(sed -n '1p' "$tmp/log")
second=$(sed -n '2p' "$tmp/log")
[[ $first == 'keyword cursor:invisible true' ]] || fail "cursor is not hidden before the desktop renderer starts"
[[ $second == "launcher <--boot-effect> <decrypt> <--boot-seed> <18446744073709551615> <--ready-file> <$tmp/runtime/omarchy-plymouth-handoff.ready> <--unhide-cursor-on-ready>" ]] ||
  fail "helper did not preserve exact boot effect/seed/readiness contract"
[[ ! -e $tmp/runtime/omarchy-plymouth-handoff.ready ]] || fail "stale readiness marker survived a new login"
third=$(sed -n '3p' "$tmp/log")
[[ $third == 'keyword cursor:invisible false' ]] ||
  fail "cursor remained hidden when renderer exited before its first frame"
pass "valid native state is handed to one early renderer without resolving random twice"
[[ $(grep -Fxc launcher "$tmp/log") == 1 ]] || fail "early exit did not launch exactly one ordinary fallback"
[[ $(sed -n '4p' "$tmp/log") == launcher ]] || fail "fallback started before cursor restoration"
grep -Fx 'fallback active=no' "$tmp/log" >/dev/null || fail "fallback inherited the handoff claim"
grep -Fx 'fallback parent=alive' "$tmp/log" >/dev/null || fail "helper did not wait for the ordinary controller"
pass "renderer startup failure restores cursor and parents one ordinary fallback"

: >"$tmp/log"
HANDOFF_TEST_LOG="$tmp/log" \
PATH="$tmp:/usr/bin:/bin" \
XDG_RUNTIME_DIR="$tmp/runtime" \
OMARCHY_PLYMOUTH_DESCRIPTOR="$tmp/descriptor" \
OMARCHY_PLYMOUTH_EFFECT_CATALOG="$tmp/catalog" \
OMARCHY_TTFX_BG_LAUNCHER="$tmp/launcher" \
"$helper" --launch-shell
grep -Fx 'shell active=yes' "$tmp/log" >/dev/null ||
  fail "Quickshell started before the handoff active claim"
[[ ! -e $tmp/runtime/omarchy-plymouth-handoff.active ]] ||
  fail "handoff active claim leaked after renderer exit"
[[ $(grep -Fxc 'shell active=yes' "$tmp/log") == 1 ]] || fail "shell was relaunched during recovery"
[[ $(grep -Fxc launcher "$tmp/log") == 1 ]] || fail "shell recovery did not start exactly one fallback"
pass "Quickshell starts only after the seeded controller is claimed"

for scenario in fallback-failure ready; do
  : >"$tmp/log"
  HANDOFF_TEST_LOG="$tmp/log" \
  HANDOFF_TEST_FALLBACK_FAIL=true \
  HANDOFF_TEST_READY="$([[ $scenario == ready ]] && printf true || printf false)" \
  PATH="$tmp:/usr/bin:/bin" \
  XDG_RUNTIME_DIR="$tmp/runtime" \
  OMARCHY_PLYMOUTH_DESCRIPTOR="$tmp/descriptor" \
  OMARCHY_PLYMOUTH_EFFECT_CATALOG="$tmp/catalog" \
  OMARCHY_TTFX_BG_LAUNCHER="$tmp/launcher" \
  timeout 5 "$helper" --launch-shell || fail "$scenario did not terminate cleanly"
  [[ $(grep -c '^launcher <--boot-effect>' "$tmp/log") == 1 ]] || fail "$scenario duplicated the seeded controller"
  [[ $(grep -Fxc 'shell active=yes' "$tmp/log") == 1 ]] || fail "$scenario changed normal shell launch"
  [[ $(grep -Fxc 'keyword cursor:invisible false' "$tmp/log") == 1 ]] || fail "$scenario did not restore cursor exactly once"
  [[ ! -e $tmp/runtime/omarchy-plymouth-handoff.active ]] || fail "$scenario leaked the active claim"
  if [[ $scenario == fallback-failure ]]; then
    [[ $(grep -Fxc launcher "$tmp/log") == 1 ]] || fail "failed fallback was retried or missing"
    grep -Fx 'fallback active=no' "$tmp/log" >/dev/null || fail "failed fallback inherited active claim"
    pass "ordinary fallback failure exits without recursion or shell relaunch"
  else
    [[ $(grep -Fxc launcher "$tmp/log" || true) == 0 ]] || fail "successful readiness launched an ordinary fallback"
    pass "successful handoff does not launch a fallback"
  fi
done

# The desktop renderer is optional; stock login must start without one.
: >"$tmp/log"
HANDOFF_TEST_LOG="$tmp/log" \
PATH="$tmp:/usr/bin:/bin" \
XDG_RUNTIME_DIR="$tmp/runtime" \
OMARCHY_PLYMOUTH_DESCRIPTOR="$tmp/descriptor" \
OMARCHY_PLYMOUTH_EFFECT_CATALOG="$tmp/catalog" \
env -u OMARCHY_TTFX_BG_LAUNCHER "$helper" --launch-shell
grep -Fx 'shell active=no' "$tmp/log" >/dev/null ||
  fail "normal shell login must start without an optional desktop renderer"
[[ $(wc -l <"$tmp/log") == 1 ]] || fail "stock login must not start a handoff renderer or hide the cursor"
pass "stock login starts normally without a desktop handoff renderer"

: >"$tmp/log"
sed 's/Effect=decrypt/Effect=not-in-catalog/' "$tmp/descriptor" >"$tmp/bad-descriptor"
HANDOFF_TEST_LOG="$tmp/log" \
PATH="$tmp:/usr/bin:/bin" \
XDG_RUNTIME_DIR="$tmp/runtime" \
OMARCHY_PLYMOUTH_DESCRIPTOR="$tmp/bad-descriptor" \
OMARCHY_PLYMOUTH_EFFECT_CATALOG="$tmp/catalog" \
OMARCHY_TTFX_BG_LAUNCHER="$tmp/launcher" \
"$helper"
[[ ! -s $tmp/log ]] || fail "invalid effect launched a renderer or hid the cursor"
pass "invalid or unavailable boot state never delays graphical login"

: >"$tmp/log"
printf '%s\n' decrypt '../injected' >"$tmp/bad-catalog"
chmod 0644 "$tmp/bad-catalog"
HANDOFF_TEST_LOG="$tmp/log" \
PATH="$tmp:/usr/bin:/bin" \
XDG_RUNTIME_DIR="$tmp/runtime" \
OMARCHY_PLYMOUTH_DESCRIPTOR="$tmp/descriptor" \
OMARCHY_PLYMOUTH_EFFECT_CATALOG="$tmp/bad-catalog" \
OMARCHY_TTFX_BG_LAUNCHER="$tmp/launcher" \
"$helper"
[[ ! -s $tmp/log ]] || fail "malformed catalog launched a renderer"

ln -s "$tmp/descriptor" "$tmp/descriptor-link"
HANDOFF_TEST_LOG="$tmp/log" \
PATH="$tmp:/usr/bin:/bin" \
XDG_RUNTIME_DIR="$tmp/runtime" \
OMARCHY_PLYMOUTH_DESCRIPTOR="$tmp/descriptor-link" \
OMARCHY_PLYMOUTH_EFFECT_CATALOG="$tmp/catalog" \
OMARCHY_TTFX_BG_LAUNCHER="$tmp/launcher" \
"$helper"
[[ ! -s $tmp/log ]] || fail "symlinked descriptor launched a renderer"
pass "handoff rejects malformed catalogs and symlinked state"

: >"$tmp/log"
cat >"$tmp/duplicate-descriptor" <<'EOF'
[Plymouth Theme]
ModuleName=
ModuleName=ttfx-plymouth
[ttfx]
Mode=
Mode=fixed
Enabled=
Enabled=true
Effect=
Effect=decrypt
Seed=
Seed=18446744073709551615
EOF
chmod 0644 "$tmp/duplicate-descriptor"
HANDOFF_TEST_LOG="$tmp/log" \
PATH="$tmp:/usr/bin:/bin" \
XDG_RUNTIME_DIR="$tmp/runtime" \
OMARCHY_PLYMOUTH_DESCRIPTOR="$tmp/duplicate-descriptor" \
OMARCHY_PLYMOUTH_EFFECT_CATALOG="$tmp/catalog" \
OMARCHY_TTFX_BG_LAUNCHER="$tmp/launcher" \
"$helper"
[[ ! -s $tmp/log ]] || fail "empty-first duplicate descriptor keys were accepted"
pass "descriptor key occurrence validation rejects empty-first duplicates"
