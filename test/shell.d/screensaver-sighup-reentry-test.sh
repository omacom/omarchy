#!/bin/bash

# A signal arriving while exit_screensaver runs must not re-enter it: bash 5.3
# runs pending traps between commands inside a trap handler, so an unguarded
# handler recurses once per pending signal until the stack overflows (#16807).

source "$(dirname -- "${BASH_SOURCE[0]}")/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"

hyprctl_log="$scratch/hyprctl.log"
ttfx_pids="$scratch/ttfx.pids"
: >"$hyprctl_log"
: >"$ttfx_pids"

# The handler's hyprctl call sends the screensaver a SIGHUP from inside the
# running handler, the way a signal burst mid-dismiss does. Without the guard
# every nested level spawns another one, and the script dies of stack
# exhaustion instead of exiting.
cat >"$scratch/bin/hyprctl" <<STUB
#!/bin/bash
printf '%s\n' "\$*" >>"$hyprctl_log"
case "\$*" in
  *activewindow*)
    printf '%s\n' '{"class":"not-the-screensaver"}'
    exit 0
    ;;
esac
case "\$*" in
  *"invisible = false"*) kill -HUP "\$PPID" 2>/dev/null ;;
esac
exit 0
STUB

cat >"$scratch/bin/ttfx" <<STUB
#!/bin/bash
echo \$\$ >>"$ttfx_pids"
exec sleep 30
STUB

printf '#!/bin/bash\nexit 0\n' >"$scratch/bin/pgrep"  # a ttfx is always "running"
printf '#!/bin/bash\nexit 0\n' >"$scratch/bin/pkill"  # the test cleans ttfx up itself
printf '#!/bin/bash\ncase ${1:-} in size) echo "50 200";; esac\nexit 0\n' >"$scratch/bin/stty"
printf '#!/bin/bash\necho /dev/stubtt\n' >"$scratch/bin/tty"
chmod +x "$scratch/bin/"*

require_command jq

# activewindow reports another class, so the run reaches exit_screensaver
# through the focus check on its first loop iteration.
timeout 60 env PATH="$scratch/bin:$PATH" HYPRCTL_LOG="$hyprctl_log" \
  bash "$ROOT/bin/omarchy-screensaver" </dev/null >"$scratch/out.log" 2>&1
status=$?

while read -r pid; do
  kill "$pid" 2>/dev/null || true
done <"$ttfx_pids"

if (( status == 124 )); then
  fail "screensaver exits cleanly through a SIGHUP arriving mid-handler" \
    "timed out; the exit handler recursed on every SIGHUP it sent itself"
fi
if (( status != 0 )); then
  fail "screensaver exits cleanly through a SIGHUP arriving mid-handler" \
    "exit status $status; the exit handler re-entered itself until the stack gave out"
fi

handler_calls=$(grep -cF 'invisible = false' "$hyprctl_log" || true)
if (( handler_calls == 1 )); then
  pass "screensaver exits cleanly through a SIGHUP arriving mid-handler"
else
  fail "the exit handler runs once, not once per re-entry" \
    "hyprctl ran the handler's restore $handler_calls times (log: $hyprctl_log)"
fi
