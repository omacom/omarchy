#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

installer="$ROOT/bin/omarchy-install-service-sunshine"
remover="$ROOT/bin/omarchy-remove-service-sunshine"

! grep -Fq 'enable --now sunshine' "$installer" ||
  fail "the installer no longer enables the bare alias name"
grep -Fq 'app-dev.lizardbyte.app.Sunshine.service' "$installer" ||
  fail "the installer knows the shipped unit name"
pass "the installer enables the shipped unit name"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
test_home="$test_tmp/home"
calls="$test_tmp/calls.log"
mkdir -p "$stub_bin" "$test_home/.config"

cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash

printf 'systemctl' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"

if [[ $1 == "--user" && $2 == "list-unit-files" ]]; then
  if (( ${SUNSHINE_ALIAS_PRESENT:-0} == 1 )); then
    printf '%s\n' "app-dev.lizardbyte.app.Sunshine.service enabled" "sunshine.service enabled"
  else
    printf '%s\n' "app-dev.lizardbyte.app.Sunshine.service disabled"
  fi
  exit 0
fi

# A fresh install cannot resolve the alias: this is the reported failure.
if [[ $* == *"enable --now sunshine.service"* && ${SUNSHINE_ALIAS_PRESENT:-0} != "1" ]]; then
  echo "Failed to enable unit: Unit sunshine.service does not exist" >&2
  exit 1
fi
SH

cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash

printf 'sudo' >>"$TEST_LOG"
printf '\t%s' "$@" >>"$TEST_LOG"
printf '\n' >>"$TEST_LOG"
SH

cat >"$stub_bin/omarchy-pkg-add" <<'SH'
#!/bin/bash

printf 'pkg-add\t%s\n' "$*" >>"$TEST_LOG"
SH

cat >"$stub_bin/omarchy-cmd-missing" <<'SH'
#!/bin/bash

# ufw is present so the firewall steps run.
exit 1
SH

cat >"$stub_bin/omarchy-webapp-install" <<'SH'
#!/bin/bash

printf 'webapp-install\t%s\n' "$*" >>"$TEST_LOG"
SH

cat >"$stub_bin/omarchy-launch-webapp" <<'SH'
#!/bin/bash

printf 'launch-webapp\t%s\n' "$*" >>"$TEST_LOG"
SH

chmod +x "$stub_bin"/*

run_installer() {
  local alias_present="$1"
  : >"$calls"

  HOME="$test_home" \
    PATH="$stub_bin:$ROOT/bin:$PATH" TEST_LOG="$calls" \
    SUNSHINE_ALIAS_PRESENT="$alias_present" \
    bash -eE -o pipefail "$installer" >/dev/null
}

# The mock reproduces the reported failure for the old command.
if PATH="$stub_bin:$PATH" TEST_LOG="$calls" SUNSHINE_ALIAS_PRESENT=0 \
  systemctl --user enable --now sunshine.service 2>/dev/null; then
  fail "the mock reproduces the alias failure on a fresh install"
fi
pass "the mock reproduces the alias failure on a fresh install"

# Fresh install: the shipped name is enabled and every later step still runs.
run_installer 0
grep -Fq $'systemctl\t--user\tenable\t--now\tapp-dev.lizardbyte.app.Sunshine.service' "$calls" ||
  fail "a fresh install enables the shipped unit name" "$(cat "$calls")"
grep -Fq $'sudo\tufw\tallow' "$calls" ||
  fail "a fresh install still opens the firewall ports" "$(cat "$calls")"
grep -Fq $'webapp-install\tSunshine Admin' "$calls" ||
  fail "a fresh install still installs the admin webapp" "$(cat "$calls")"
grep -Fxq 'o.launch_on_start("sunshine")' "$test_home/.config/hypr/autostart.lua" ||
  fail "a fresh install still adds the autostart entry"
pass "a fresh install completes every setup step"

# Re-run with the alias present: still the shipped name, still everything.
rm -f "$test_home/.config/hypr/autostart.lua"
run_installer 1
grep -Fq $'systemctl\t--user\tenable\t--now\tapp-dev.lizardbyte.app.Sunshine.service' "$calls" ||
  fail "a re-run enables the shipped unit name" "$(cat "$calls")"
grep -Fxq 'o.launch_on_start("sunshine")' "$test_home/.config/hypr/autostart.lua" ||
  fail "a re-run keeps the autostart entry"
pass "a re-run enables the shipped unit name"

# Removal disables both names so no enabled unit is left behind.
: >"$calls"
HOME="$test_home" \
  PATH="$stub_bin:$ROOT/bin:$PATH" TEST_LOG="$calls" \
  bash -eE -o pipefail "$remover" >/dev/null
grep -Fq $'systemctl\t--user\tdisable\t--now\tapp-dev.lizardbyte.app.Sunshine.service\tsunshine.service' "$calls" ||
  fail "removal disables both unit names" "$(cat "$calls")"
pass "removal disables both unit names"
