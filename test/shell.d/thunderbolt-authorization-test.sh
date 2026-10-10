#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

bash "$ROOT/test/shell.d/fixtures/thunderbolt/policy-test.sh"
bash "$ROOT/test/shell.d/fixtures/thunderbolt/startup-test.sh"

test_setup_and_removal_unit_lifecycle() {
  fixture=$(mktemp -d)
  trap 'rm -rf "${fixture:-}"' EXIT
  local mock_bin="$fixture/bin"
  local mock_home="$fixture/home"
  local calls="$fixture/calls"
  mkdir -p "$mock_bin" "$mock_home"
  touch "$calls"

  cat >"$mock_bin/sudo" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >> "$CALLS"
if [[ $1 == install && ${!#} == /usr/share/polkit-1/actions/org.omarchy.thunderbolt.policy ]]; then
  exit 0
elif [[ $1 == systemctl && $2 == daemon-reload ]]; then
  exit 0
elif [[ $1 == /usr/bin/omarchy-thunderbolt-authorization-admin ]]; then
  exit 0
fi
echo "unexpected sudo call: $*" >&2
exit 1
STUB
  chmod +x "$mock_bin/sudo"

  cat >"$mock_bin/systemctl" <<'STUB'
#!/bin/bash
printf 'systemctl %s\n' "$*" >> "$CALLS"
unit_file="$HOME/.config/systemd/user/omarchy-thunderbolt-authorization.service"
if [[ $1 == --user ]]; then
  case $2 in
    cat|enable) [[ -f $unit_file ]] || { echo "Unit does not exist" >&2; exit 1; } ;;
    disable) [[ -z ${DISABLE_FAIL:-} ]] || { echo "Failed to disable unit" >&2; exit 1; } ;;
  esac
fi
exit 0
STUB
  chmod +x "$mock_bin/systemctl"

  cat >"$mock_bin/gum" <<'STUB'
#!/bin/bash
exit 0
STUB
  chmod +x "$mock_bin/gum"

  CALLS="$calls" HOME="$mock_home" PATH="$mock_bin:$PATH" OMARCHY_PATH="$ROOT" \
    bash "$ROOT/bin/omarchy-setup-security-thunderbolt-authorization" --quiet

  [[ -f "$mock_home/.config/systemd/user/omarchy-thunderbolt-authorization.service" ]] ||
    fail "setup installs user systemd unit"
  cmp -s "$ROOT/default/systemd/user/omarchy-thunderbolt-authorization.service" \
    "$mock_home/.config/systemd/user/omarchy-thunderbolt-authorization.service" ||
    fail "installed user unit matches repository source"
  grep -Fqx 'systemctl --user enable --now omarchy-thunderbolt-authorization.service' "$calls" ||
    fail "setup enables user systemd unit"

  # Re-running setup must be idempotent and leave no temporary files behind
  CALLS="$calls" HOME="$mock_home" PATH="$mock_bin:$PATH" OMARCHY_PATH="$ROOT" \
    bash "$ROOT/bin/omarchy-setup-security-thunderbolt-authorization" --quiet
  cmp -s "$ROOT/default/systemd/user/omarchy-thunderbolt-authorization.service" \
    "$mock_home/.config/systemd/user/omarchy-thunderbolt-authorization.service" ||
    fail "second setup keeps installed unit identical to source"
  [[ $(ls -A "$mock_home/.config/systemd/user" | wc -l) == 1 ]] ||
    fail "setup leaves no temporary files in the user unit directory"

  CALLS="$calls" HOME="$mock_home" PATH="$mock_bin:$PATH" OMARCHY_PATH="$ROOT" \
    bash "$ROOT/bin/omarchy-remove-security-thunderbolt-authorization"

  [[ ! -f "$mock_home/.config/systemd/user/omarchy-thunderbolt-authorization.service" ]] ||
    fail "removal cleans up user systemd unit"
  grep -Fqx 'systemctl --user disable --now omarchy-thunderbolt-authorization.service' "$calls" ||
    fail "removal disables user systemd unit"

  # A failing disable must abort removal and keep the unit for a retry
  CALLS="$calls" HOME="$mock_home" PATH="$mock_bin:$PATH" OMARCHY_PATH="$ROOT" \
    bash "$ROOT/bin/omarchy-setup-security-thunderbolt-authorization" --quiet
  if DISABLE_FAIL=1 CALLS="$calls" HOME="$mock_home" PATH="$mock_bin:$PATH" OMARCHY_PATH="$ROOT" \
    bash "$ROOT/bin/omarchy-remove-security-thunderbolt-authorization" 2>/dev/null; then
    fail "removal fails when disabling the unit fails"
  fi
  [[ -f "$mock_home/.config/systemd/user/omarchy-thunderbolt-authorization.service" ]] ||
    fail "removal keeps the unit when disabling fails"

  # A missing unit is tolerated
  rm -f "$mock_home/.config/systemd/user/omarchy-thunderbolt-authorization.service"
  CALLS="$calls" HOME="$mock_home" PATH="$mock_bin:$PATH" OMARCHY_PATH="$ROOT" \
    bash "$ROOT/bin/omarchy-remove-security-thunderbolt-authorization" >/dev/null ||
    fail "removal tolerates a missing unit"

  pass "Thunderbolt setup and removal manages user systemd unit lifecycle"
}

test_setup_and_removal_unit_lifecycle

if [[ -n ${BOLT_TEST_SOURCE:-} ]]; then
  /usr/bin/python3 "$ROOT/test/shell.d/fixtures/thunderbolt/bolt-integration.py" "$ROOT"
else
  skip "real boltd integration needs BOLT_TEST_SOURCE and an UMockdev environment"
fi

