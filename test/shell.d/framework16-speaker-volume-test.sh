#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

scratch=$(mktemp -d)
trap 'rm -rf "$scratch"' EXIT
mkdir -p "$scratch/bin"
export OMARCHY_PATH="$ROOT"
export XDG_CONFIG_HOME="$scratch/config"
export CALL_LOG="$scratch/calls"
export AUDIO_FIXTURE="$scratch/audio.json"
export PATH="$scratch/bin:$PATH"

cat > "$scratch/bin/omarchy-hw-framework16" <<'STUB'
#!/bin/bash
[[ ${TEST_VENDOR:-} == "Framework" && ${TEST_MODEL:-} == Laptop\ 16* ]]
STUB
cat > "$scratch/bin/omarchy-hw-match" <<'STUB'
#!/bin/bash
grep -qi -- "$1" <<< "${TEST_MODEL:-}"
STUB
cat > "$scratch/bin/pw-dump" <<'STUB'
#!/bin/bash
if [[ ${DELAY_DISCOVERY:-0} == "1" && ! -e $AUDIO_FIXTURE.ready ]]; then
  touch "$AUDIO_FIXTURE.ready"
  printf '[]\n'
else
  cat "$AUDIO_FIXTURE"
fi
STUB
cat > "$scratch/bin/amixer" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >> "$CALL_LOG"
if [[ $3 == "sget" && $4 == "${MISSING_CONTROL:-}" ]]; then
  exit 1
fi
STUB
cat > "$scratch/bin/sleep" <<'STUB'
#!/bin/bash
true
STUB
cat > "$scratch/bin/cp" <<'STUB'
#!/bin/bash
if [[ ${INTERRUPT_STAGE:-} == "partial-mixer" ]]; then
  printf '# interrupted copy\n' > "${@: -1}"
  exit 99
fi
/usr/bin/cp "$@"
STUB
cat > "$scratch/bin/ln" <<'STUB'
#!/bin/bash
[[ ${INTERRUPT_STAGE:-} != "before-enable" ]] || exit 99
/usr/bin/ln "$@"
STUB
chmod +x "$scratch/bin/"*
export TEST_VENDOR=Framework
export TEST_MODEL='Laptop 16 (AMD Ryzen AI 300 Series)'

setup_fix() {
  bash -euo pipefail "$ROOT/install/user/hardware/framework/fix-f16-ai300-speaker-volume.sh" >/dev/null
}
initialize_levels() {
  : > "$CALL_LOG"
  bash "$ROOT/bin/omarchy-hw-framework16-speaker-levels"
}
fixture() {
  cat > "$AUDIO_FIXTURE" <<JSON
[
  {"type":"PipeWire:Interface:Device","info":{"props":{
    "alsa.components":"HDA:1002aa01,00aa0100,00100900",
    "api.alsa.card":2,"api.alsa.soft-mixer":true}}},
  {"type":"PipeWire:Interface:Device","info":{"props":{
    "alsa.components":"$1","api.alsa.card":9,"api.alsa.soft-mixer":$2}}}
]
JSON
}

TEST_VENDOR=Other setup_fix
TEST_MODEL='Laptop 16 (AMD Ryzen 7040 Series)' setup_fix
[[ ! -e $XDG_CONFIG_HOME ]] || fail "setup leaves unsupported hardware alone"
pass "setup leaves unsupported hardware alone"

unit_name="omarchy-framework16-speaker-levels.service"
vendor_unit="/usr/lib/systemd/user/$unit_name"
mixer_source="$ROOT/default/wireplumber/wireplumber.conf.d/framework16-ai300-soft-mixer.conf"

for stage in partial-mixer before-enable; do
  interrupted_config="$scratch/interrupted-$stage"
  if XDG_CONFIG_HOME="$interrupted_config" INTERRUPT_STAGE="$stage" setup_fix; then
    fail "interruption at $stage must fail setup"
  fi
  XDG_CONFIG_HOME="$interrupted_config" setup_fix
  cmp -s "$interrupted_config/wireplumber/wireplumber.conf.d/framework16-ai300-soft-mixer.conf" \
    "$mixer_source" || fail "retry at $stage installs the complete mixer rule"
  [[ $(readlink "$interrupted_config/systemd/user/wireplumber.service.wants/$unit_name") == "$vendor_unit" ]] || fail "retry at $stage enables the packaged service"
  [[ ! -e $interrupted_config/systemd/user/$unit_name && ! -L $interrupted_config/systemd/user/$unit_name ]] || fail "retry at $stage does not create a local service copy"
  pass "setup recovers from interruption at $stage"
done

setup_fix
config="$XDG_CONFIG_HOME/wireplumber/wireplumber.conf.d/framework16-ai300-soft-mixer.conf"
unit="$XDG_CONFIG_HOME/systemd/user/$unit_name"
enablement="$XDG_CONFIG_HOME/systemd/user/wireplumber.service.wants/$unit_name"
cmp -s "$config" "$mixer_source" || fail "mixer config is installed"
[[ ! -e $unit && ! -L $unit ]] || fail "the service definition stays package-owned"
[[ $(readlink "$enablement") == "$vendor_unit" ]] || fail "startup initializer is enabled from the packaged path"
pass "setup enables the packaged service without a local copy or live user bus"

setup_fix
cmp -s "$config" "$mixer_source" || fail "repeat setup preserves the mixer rule"
[[ ! -e $unit && ! -L $unit && $(readlink "$enablement") == "$vendor_unit" ]] || fail "repeat setup preserves package ownership"
pass "setup is repeatable"

# The normal lifecycle runs once; explicit setup reruns reapply enablement.
rm "$enablement"
setup_fix
[[ $(readlink "$enablement") == "$vendor_unit" ]] || fail "explicit setup reapplies enablement"
pass "explicit setup reapplies enablement after disabling the service"

ln -s /dev/null "$unit"
setup_fix
[[ -L $unit && $(readlink "$unit") == /dev/null ]] || fail "masked service stays masked"
pass "setup preserves an existing service mask"
rm "$unit"
printf '# custom service\n' > "$unit"
setup_fix
[[ $(<"$unit") == '# custom service' ]] || fail "custom service override is preserved"
pass "setup preserves a custom service override"
rm "$unit"

# Compatible mixer symlinks are used without taking ownership of their source.
external_mixer="$scratch/external-mixer"
cp "$mixer_source" "$external_mixer"
rm "$config"
ln -s "$external_mixer" "$config"
rm "$enablement"
setup_fix
[[ -L $config && $(readlink "$config") == "$external_mixer" ]] || fail "compatible mixer symlink is preserved"
[[ $(readlink "$enablement") == "$vendor_unit" ]] || fail "compatible mixer symlink enables the packaged service"
printf '# custom mixer rule\n' > "$external_mixer"
setup_fix
[[ -L $config && $(<"$config") == '# custom mixer rule' ]] || fail "external mixer edits remain visible"
pass "setup preserves a compatible mixer symlink and later external edits"

rm "$config" "$enablement"
printf '# custom mixer rule\n' > "$config"
setup_fix
[[ $(<"$config") == '# custom mixer rule' && ! -L $enablement ]] || fail "custom mixer rule is preserved without enabling the service"
pass "setup preserves a custom mixer rule without enabling the service"
rm "$config"
ln -s "$scratch/missing-mixer" "$config"
setup_fix
[[ -L $config && $(readlink "$config") == "$scratch/missing-mixer" && ! -L $enablement ]] || fail "dangling mixer symlink is preserved without enabling the service"
pass "setup preserves a dangling mixer symlink without enabling the service"

fixture 'HDA:10ec0285,f111000d,00100002' true
initialize_levels
expected=$'-c 9 sget Master\n-c 9 sget Speaker\n-c 9 sget Bass Speaker\n-c 9 sset Master 0dB unmute\n-c 9 sset Speaker 0dB unmute\n-c 9 sset Bass Speaker 0dB unmute'
[[ $(<"$CALL_LOG") == "$expected" ]] || fail "initializer targets the discovered Framework card only" "$(<"$CALL_LOG")"
pass "initializer sets only the discovered Framework card to 0 dB"

DELAY_DISCOVERY=1 initialize_levels
[[ $(<"$CALL_LOG") == "$expected" ]] || fail "initializer waits for delayed device discovery"
pass "initializer waits for delayed device discovery"

fixture 'HDA:10ec0285,f111000d,00100002' false
discovery_status=0
initialize_levels 2>/dev/null || discovery_status=$?
(( discovery_status == 75 )) || fail "discovery timeout requests a retry"
[[ ! -s $CALL_LOG ]] || fail "inactive software volume leaves hardware untouched"
pass "initializer refuses to raise levels without software volume"

fixture 'HDA:10ec0285,f111000d,00100002' true
initialize_levels
[[ $(<"$CALL_LOG") == "$expected" ]] || fail "initializer recovers after discovery timeout"
pass "initializer recovers after discovery timeout"

fixture 'HDA:10ec0285,12345678,00100002' true
if initialize_levels 2>/dev/null; then
  fail "initializer refuses a different codec subsystem"
fi
[[ ! -s $CALL_LOG ]] || fail "different codec subsystem leaves hardware untouched"
pass "initializer refuses a different codec subsystem"

fixture 'HDA:10ec0285,f111000d,00100002' true
control_status=0
MISSING_CONTROL='Bass Speaker' initialize_levels 2>/dev/null || control_status=$?
(( control_status != 0 && control_status != 75 )) || fail "missing controls fail without requesting discovery retry"
if rg -q ' sset ' "$CALL_LOG"; then
  fail "incomplete speaker controls must not cause a partial level change"
fi
pass "initializer checks every required control before changing levels"

TEST_VENDOR=Other initialize_levels
[[ ! -s $CALL_LOG ]] || fail "initializer leaves unsupported hardware alone"
pass "initializer leaves unsupported hardware alone"

# Existing installs use exactly the same setup path as fresh installs.
rm -f "$config"
bash -euo pipefail "$ROOT/migrations/1791044739.sh" >/dev/null
cmp -s "$config" "$ROOT/default/wireplumber/wireplumber.conf.d/framework16-ai300-soft-mixer.conf" || fail "migration installs the same fix"
[[ ! -e $unit && ! -L $unit && $(readlink "$enablement") == "$vendor_unit" ]] || fail "migration enables the packaged service without a local copy"
bash -euo pipefail "$ROOT/migrations/1791044739.sh" >/dev/null
[[ $(readlink "$enablement") == "$vendor_unit" ]] || fail "migration is repeatable"
pass "migration installs the mixer rule and enables the packaged service repeatably"
