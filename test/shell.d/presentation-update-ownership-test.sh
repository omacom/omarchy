#!/bin/bash

set -euo pipefail

source "$(dirname "$0")/base-test.sh"
source "$SHELL_TEST_DIR/fixtures/sudo-boundary-test.sh"

runtime_dir="/run/user/$(id -u)"
stay_awake_dir_name="omarchy-presentation-test-$BASHPID-$RANDOM"
stay_awake_helper_state="$runtime_dir/$stay_awake_dir_name"
test_home="$SUDO_TEST_HOME"
stub_bin="$SUDO_TEST_ROOT/bin"
stay_awake_state="$test_home/.local/state/omarchy/indicators/stay-awake"
trap 'rm -rf -- "$stay_awake_helper_state" "$boundary_tmp"' EXIT
rm -f "$stub_bin/omarchy-update-stay-awake"
copy_boundary_file bin/omarchy-update-stay-awake
sed -i "s#state_dir=\"\$state_base/omarchy-update-stay-awake\"#state_dir=\"\$state_base/$stay_awake_dir_name\"#" "$stub_bin/omarchy-update-stay-awake"

write_stub() {
  local name="$1" body="$2"
  rm -f "$stub_bin/$name"
  printf '#!/bin/bash\n%s\n' "$body" >"$stub_bin/$name"
  chmod +x "$stub_bin/$name"
}

run_with_lock_env() {
  SUDO_TEST_HOME="$test_home" XDG_RUNTIME_DIR="$runtime_dir" \
    PATH="$stub_bin:$ROOT/bin:$PATH" "$@"
}

# Presentation must retain stay-awake when the update's owner expires, then
# restore the idle state from before that update when presentation ends.
write_stub omarchy-shell '
[[ ${1:-} != "-q" ]] || shift
if [[ ${1:-} == "notifications" && ${2:-} == "dndState" ]]; then
  printf "off\n"
elif [[ ${1:-} == "notifications" && ${2:-} == "setDnd" ]]; then
  printf "%s\n" "$3"
fi'
write_stub omarchy-notification-send 'exit 0'
rm -f "$stub_bin/omarchy-toggle-idle"
copy_boundary_file bin/omarchy-toggle-idle
mkdir -m 700 -p "$stay_awake_helper_state"
mkdir -p "$test_home/.local/state/omarchy/indicators"
printf '123:456:789\n' >"$stay_awake_helper_state/idle-owner"
chmod 600 "$stay_awake_helper_state/idle-owner"
printf '123:456:789\n' >"$stay_awake_state"
HOME="$test_home" PATH="$stub_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-toggle-presentation" on >/dev/null
run_with_lock_env "$SUDO_TEST_ROOT/bin/omarchy-update-stay-awake" stop
[[ -f $stay_awake_state ]] || fail "update cleanup keeps presentation awake"
HOME="$test_home" PATH="$stub_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-toggle-presentation" off >/dev/null
[[ ! -f $stay_awake_state ]] || fail "presentation releases expired update ownership"
pass "update cleanup keeps presentation awake and transfers idle restoration"
