#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# --- omarchy-setup-essentials sets the choices up in order ---

work=$(mktemp -d)
trap 'rm -rf "$work"' EXIT
stubs="$work/bin"
calls="$work/calls"
mkdir -p "$stubs" "$work/home" "$work/run"

stub() {
  printf '#!/bin/bash\necho "%s $*" >>"$OMARCHY_TEST_CALLS"\nexit ${%s:-0}\n' "$1" "${2:-OMARCHY_TEST_NO_FAILURE}" >"$stubs/$1"
  chmod +x "$stubs/$1"
}

for name in omarchy-done omarchy-notification-dismiss nm-online omarchy-install-dictation-voxtype omarchy-agent-local; do
  stub "$name"
done
stub omarchy-hyprland-workspace-layout-default OMARCHY_TEST_LAYOUT_STATUS
stub omarchy-install-service-tailscale OMARCHY_TEST_TAILSCALE_STATUS
printf '#!/bin/bash\necho "$1"\n' >"$stubs/omarchy-i18n"
printf '#!/bin/bash\necho "${OMARCHY_TEST_DICTATION:-voxtype}"\n' >"$stubs/omarchy-default-dictation"

# The terminal runs what it is handed, as the real one does.
cat >"$stubs/omarchy-launch-floating-terminal-with-presentation" <<'SH'
#!/bin/bash
echo "terminal: $*" >>"$OMARCHY_TEST_CALLS"
bash -c "$*"
SH

# Installing an agent ends however the agent's own session did.
cat >"$stubs/omarchy-default-agent" <<'SH'
#!/bin/bash
echo "omarchy-default-agent $*" >>"$OMARCHY_TEST_CALLS"
case "$1" in
  --install) exit "${OMARCHY_TEST_AGENT_SESSION:-0}" ;;
  --installed) exit "${OMARCHY_TEST_AGENT_MISSING:-0}" ;;
esac
SH
chmod +x "$stubs"/*

# In a session of its own: essentials waits for a key on the terminal before
# an agent takes it over, and must find none here rather than the one the suite
# was started from.
essentials() {
  : >"$calls"
  HOME="$work/home" PATH="$stubs:$ROOT/bin:$PATH" OMARCHY_TEST_CALLS="$calls" setsid -w "$@" >"$work/output" 2>&1
}

installs() {
  grep -E '^(omarchy-install-dictation-voxtype|omarchy-install-service-tailscale|omarchy-agent-local|omarchy-default-agent --install)( |$)' "$calls" | tr '\n' '|'
}

essentials omarchy-setup-essentials --layout scrolling --dictation voxtype --tailscale --local-ai big-27b --agent claude ||
  fail "what the tour picked is set up" "$(<"$work/output")"
[[ $(grep -c '^omarchy-hyprland-workspace-layout-default scrolling$' "$calls") == "1" ]] || fail "the layout is set once" "$(<"$calls")"
[[ $(sed -n '1p' "$calls") == "omarchy-hyprland-workspace-layout-default scrolling" ]] || fail "the layout is set before any terminal opens" "$(<"$calls")"
[[ $(grep -c '^terminal: ' "$calls") == "1" ]] || fail "the installs share one terminal" "$(<"$calls")"
[[ $(installs) == "omarchy-install-dictation-voxtype |omarchy-install-service-tailscale |omarchy-agent-local use --detach big-27b|omarchy-default-agent --install claude|" ]] ||
  fail "the installs run one after another, the agent last, and the model by its recipe" "$(installs)"
grep -Fxq 'omarchy-done mark agent-setup-invitation' "$calls" || fail "a tour that picked an agent answers first run's invitation to" "$(<"$calls")"
pass "the layout is set at once, and the installs run in one terminal with the agent last"

essentials omarchy-setup-essentials --layout floating || fail "a layout alone is set" "$(<"$work/output")"
if grep -q '^terminal: ' "$calls"; then
  fail "a layout alone opens no terminal" "$(<"$calls")"
fi
pass "a layout alone opens no terminal"

if OMARCHY_TEST_TAILSCALE_STATUS=1 essentials omarchy-setup-essentials --tailscale --agent claude; then
  fail "a failed install fails the run" "$(<"$work/output")"
fi
grep -Fxq 'omarchy-default-agent --install claude' "$calls" || fail "one failed install does not stop the ones after it" "$(<"$calls")"
[[ $(grep -c 'Could not set up: Tailscale$' "$work/output") == "2" ]] ||
  fail "a failed install is named before the agent takes the terminal, and again at the end" "$(<"$work/output")"
pass "one failed install is named and does not stop the others"

OMARCHY_TEST_DICTATION=superwhisper essentials omarchy-setup-essentials --dictation voxtype ||
  fail "an install that was turned down is not a failure" "$(<"$work/output")"
grep -Fq 'Left as it was: dictation' "$work/output" || fail "but it is not passed off as set up" "$(<"$work/output")"
pass "a dictation install that was turned down is reported as left alone"

OMARCHY_TEST_AGENT_SESSION=130 essentials omarchy-setup-essentials --agent claude ||
  fail "an agent left with Ctrl+C was still set up" "$(<"$work/output")"
if OMARCHY_TEST_AGENT_MISSING=1 essentials omarchy-setup-essentials --agent claude; then
  fail "an agent that is not there afterwards was not set up" "$(<"$work/output")"
fi
grep -Fq 'Could not set up: claude' "$work/output" || fail "an agent that did not install is named" "$(<"$work/output")"
pass "an agent's install is judged by the agent being there, not by how its session ended"

if OMARCHY_TEST_LAYOUT_STATUS=1 essentials omarchy-setup-essentials --layout scrolling --tailscale; then
  fail "a layout that could not be set fails the run" "$(<"$work/output")"
fi
[[ $(grep -c '^omarchy-hyprland-workspace-layout-default scrolling$' "$calls") == "2" ]] ||
  fail "a layout that could not be set is tried again in the terminal" "$(<"$calls")"
grep -Fq 'Could not set up: the workspace layout' "$work/output" || fail "and is named there" "$(<"$work/output")"
pass "a layout that could not be set is carried into the terminal, where it shows"

refused() {
  if essentials omarchy-setup-essentials "$@"; then
    fail "a value that is not one is refused: $*"
  fi
  [[ ! -s $calls ]] || fail "a refused value runs nothing: $*" "$(<"$calls")"
}

refused --agent 'claude; touch owned'
refused --local-ai 'big; touch owned'
refused --layout sideways
pass "a name, a recipe or a layout that is not one is refused before anything runs"
