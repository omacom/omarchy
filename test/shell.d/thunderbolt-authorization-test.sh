#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

bash "$ROOT/test/shell.d/fixtures/thunderbolt/policy-test.sh"
bash "$ROOT/test/shell.d/fixtures/thunderbolt/startup-test.sh"

test_setup_and_removal_unit_lifecycle() {
  local fixture=$(mktemp -d)
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
exec /usr/bin/sudo "$@"
STUB
  chmod +x "$mock_bin/sudo"

  cat >"$mock_bin/systemctl" <<'STUB'
#!/bin/bash
printf 'systemctl %s\n' "$*" >> "$CALLS"
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

  CALLS="$calls" HOME="$mock_home" PATH="$mock_bin:$PATH" OMARCHY_PATH="$ROOT" \
    bash "$ROOT/bin/omarchy-remove-security-thunderbolt-authorization"

  [[ ! -f "$mock_home/.config/systemd/user/omarchy-thunderbolt-authorization.service" ]] ||
    fail "removal cleans up user systemd unit"
  grep -Fqx 'systemctl --user disable --now omarchy-thunderbolt-authorization.service' "$calls" ||
    fail "removal disables user systemd unit"

  rm -rf "$fixture"
  pass "Thunderbolt setup and removal manages user systemd unit lifecycle"
}

test_setup_and_removal_unit_lifecycle

if [[ -n ${BOLT_TEST_SOURCE:-} ]]; then
  /usr/bin/python3 "$ROOT/test/shell.d/fixtures/thunderbolt/bolt-integration.py" "$ROOT"
else
  skip "real boltd integration needs BOLT_TEST_SOURCE and an UMockdev environment"
fi

