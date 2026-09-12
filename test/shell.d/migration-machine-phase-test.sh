#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
tmp=$(mktemp -d)
trap 'chmod -R u+rwx "$tmp" 2>/dev/null || true; rm -rf "$tmp"' EXIT
if ! unshare --user --map-root-user --mount /usr/bin/bash -p -c : 2>/dev/null; then
  pass "user namespaces unavailable; skipping privileged migration machine-body execution"
  exit 0
fi
root_run() { unshare --user --map-root-user --mount /usr/bin/bash -p "$@"; }
script_copy() { cp "$ROOT/migrations/$1.sh" "$2"; }

fido_dir="$tmp/fido2"; fido_file="$fido_dir/fido2"; fido_marker="$tmp/fido.marker"
mkdir "$fido_dir"; printf 'credential\n' >"$fido_file"; chmod 700 "$fido_dir"
fido_body="$tmp/fido-body.sh"; script_copy 1787494718 "$fido_body"
sed -i -e "s|/etc/fido2/fido2|$fido_file|g" -e "s|/var/lib/omarchy/migrations/1787494718|$fido_marker|g" -e 's/-o root -g root //' "$fido_body"
root_run "$fido_body" --machine
[[ $(stat -c %a "$fido_dir") == 755 ]] || fail "FIDO2 repair leaves a hidden credential directory"
[[ $(stat -c %a "$fido_file") == 644 ]] || fail "FIDO2 repair does not restore the credential mode"
pass "FIDO2 machine body repairs a hidden directory and credential mode"

bt_bin="$tmp/bt-bin"; mkdir "$bt_bin"
cat >"$bt_bin/timeout" <<'SH'
#!/bin/bash
shift
exec "$@"
SH
cat >"$bt_bin/bluetoothctl" <<'SH'
#!/bin/bash
[[ ${BT_QUERY_FAIL:-0} == 0 ]] || exit 124
if [[ $1 == list ]]; then echo 'Controller AA:BB test'; else echo "Powered: ${BT_POWER:-no}"; fi
SH
cat >"$bt_bin/power" <<'SH'
#!/bin/bash
[[ ${BT_POWER_FAIL:-0} == 0 ]] || exit 19
echo "$1" >>"$BT_LOG"
SH
chmod +x "$bt_bin"/*
bt_body="$tmp/bt-body.sh"; bt_marker="$tmp/bt.marker"; bt_conf="$tmp/main.conf"; printf 'AutoEnable=false\n' >"$bt_conf"
script_copy 1786380259 "$bt_body"
sed -i -e "s|/usr/bin/timeout|$bt_bin/timeout|g" -e "s|/usr/bin/bluetoothctl|$bt_bin/bluetoothctl|g" -e "s|/usr/bin/omarchy-bluetooth-power|$bt_bin/power|g" -e "s|/var/lib/omarchy/migrations/1786380259|$bt_marker|g" -e "s|/etc/bluetooth/main.conf|$bt_conf|g" "$bt_body"
BT_LOG="$tmp/bt.log" BT_POWER=yes root_run "$bt_body" --machine
[[ $(cat "$tmp/bt.log") == on && -e $bt_marker ]] || fail "Bluetooth machine body loses powered-on state"
BT_LOG="$tmp/bt.log" BT_QUERY_FAIL=1 root_run "$bt_body" --machine
[[ $(wc -l <"$tmp/bt.log") == 1 ]] || fail "Bluetooth replay queried or changed completed state"
rm -f "$bt_marker"; : >"$tmp/bt.log"
BT_LOG="$tmp/bt.log" BT_POWER=no root_run "$bt_body" --machine
[[ $(cat "$tmp/bt.log") == off && -e $bt_marker ]] || fail "Bluetooth machine body loses powered-off state"
rm -f "$bt_marker"; : >"$tmp/bt.log"
if BT_LOG="$tmp/bt.log" BT_QUERY_FAIL=1 root_run "$bt_body" --machine; then fail "Bluetooth discovery failure is treated as powered off"; fi
[[ ! -e $bt_marker && ! -s $tmp/bt.log ]] || fail "Bluetooth query error publishes or changes policy"
BT_LOG="$tmp/bt.log" BT_POWER=yes root_run "$bt_body" --machine
[[ -e $bt_marker && $(cat "$tmp/bt.log") == on ]] || fail "Bluetooth query failure is not retryable"
rm -f "$bt_marker"; : >"$tmp/bt.log"
if BT_LOG="$tmp/bt.log" BT_POWER_FAIL=1 root_run "$bt_body" --machine; then fail "Bluetooth power failure publishes completion"; fi
[[ ! -e $bt_marker && ! -s $tmp/bt.log ]] || fail "Bluetooth power failure is not retryable"
BT_LOG="$tmp/bt.log" BT_POWER=yes root_run "$bt_body" --machine
[[ -e $bt_marker && $(cat "$tmp/bt.log") == on ]] || fail "Bluetooth power failure retry did not complete"
[[ $(cat "$bt_conf") == '#AutoEnable=true' ]] || fail "Bluetooth repair did not update the fixed configuration"
pass "Bluetooth machine body preserves on/off state, replays safely, and retries discovery and mutation failures"

bt_dispatch="$tmp/bt-dispatch.sh"; script_copy 1786380259 "$bt_dispatch"
bt_dispatch_marker="$tmp/bt-dispatch.marker"; bt_dispatch_lock="$tmp/bt-dispatch.lock"; bt_dispatch_log="$tmp/bt-dispatch.log"
bt_dispatch_power="$tmp/bt-dispatch-power"; bt_dispatch_ctl="$tmp/bt-dispatch-ctl"; bt_dispatch_timeout="$tmp/bt-dispatch-timeout"; bt_dispatch_sudo="$tmp/bt-dispatch-sudo"
cat >"$bt_dispatch_power" <<SH
#!/bin/bash
printf 'start\n' >>'$bt_dispatch_log'
/usr/bin/sleep 0.2
printf '%s\n' "\$1" >>'$bt_dispatch_log'
SH
cat >"$bt_dispatch_ctl" <<'SH'
#!/bin/bash
if [[ $1 == list ]]; then echo 'Controller AA:BB test'; else echo 'Powered: yes'; fi
SH
cat >"$bt_dispatch_timeout" <<'SH'
#!/bin/bash
shift
exec "$@"
SH
cat >"$bt_dispatch_sudo" <<'SH'
#!/bin/bash
[[ $1 == -N && $2 == -- ]] || exit 90
shift 2
exec "$@"
SH
chmod +x "$bt_dispatch_power" "$bt_dispatch_ctl" "$bt_dispatch_timeout" "$bt_dispatch_sudo"
sed -i -e "s|/usr/bin/timeout|$bt_dispatch_timeout|g" -e "s|/usr/bin/bluetoothctl|$bt_dispatch_ctl|g" -e "s|/usr/bin/omarchy-bluetooth-power|$bt_dispatch_power|g" -e "s|/usr/bin/sudo|$bt_dispatch_sudo|g" -e "s|/run/omarchy-bluetooth-state-migration.lock|$bt_dispatch_lock|g" -e "s|/usr/share/omarchy/migrations/1786380259.sh|$bt_dispatch|g" -e "s|/var/lib/omarchy/migrations/1786380259|$bt_dispatch_marker|g" -e "s|/etc/bluetooth/main.conf|$tmp/no-bt-conf|g" "$bt_dispatch"
root_run "$bt_dispatch" & bt_pid_one=$!
root_run "$bt_dispatch" & bt_pid_two=$!
wait "$bt_pid_one"; wait "$bt_pid_two"
[[ -e $bt_dispatch_marker && $(grep -c '^start$' "$bt_dispatch_log") == 1 && $(grep -c '^on$' "$bt_dispatch_log") == 1 ]] || fail "Bluetooth full dispatch is not serialized and replay safe"
pass "Bluetooth full no-argument dispatch preserves sudo arguments, clean environment, flock serialization, recheck, and marker replay"

t2_bin="$tmp/t2-bin"; mkdir "$t2_bin"
cat >"$t2_bin/lspci" <<'SH'
#!/bin/bash
(( ${T2_QUERY_STATUS:-0} == 0 )) || exit "$T2_QUERY_STATUS"
[[ ${T2_PRESENT:-0} == 1 ]] && echo '00:00.0 ISA bridge [0601]: Apple Inc. T2 [106b:1801]'
SH
cat >"$t2_bin/pacman" <<'SH'
#!/bin/bash
if [[ $1 == -Qq ]]; then
  (( ${PKG_QUERY_STATUS:-0} == 0 )) || exit "$PKG_QUERY_STATUS"
  [[ ${TINY_DFR:-0} == 1 ]] && echo tiny-dfr
fi
exit 0
SH
cat >"$t2_bin/systemctl" <<'SH'
#!/bin/bash
exit 0
SH
cat >"$t2_bin/limine" <<'SH'
#!/bin/bash
[[ ${LIMINE_FAIL:-0} == 0 ]] || exit 27
echo rebuild >>"$T2_LOG"
SH
chmod +x "$t2_bin"/*
t2_body="$tmp/t2-body.sh"; script_copy 1785944594 "$t2_body"
sed -i -e "s|/usr/bin/lspci|$t2_bin/lspci|g" -e "s|/usr/bin/pacman|$t2_bin/pacman|g" -e "s|/usr/bin/systemctl|$t2_bin/systemctl|g" -e "s|/usr/bin/limine-mkinitcpio|$t2_bin/limine|g" -e "s|/var/lib/omarchy/migrations/1785944594|$tmp/t2.marker|g" -e "s|/etc/limine-entry-tool.d/t2-mac.conf|$tmp/t2.conf|g" -e "s|/etc/t2fand.conf|$tmp/fan.conf|g" -e "s|/proc/cmdline|$tmp/cmdline|g" "$t2_body"
if T2_QUERY_STATUS=7 root_run "$t2_body" --machine; then fail "T2 discovery error is treated as inapplicable"; fi
[[ ! -e $tmp/t2.marker ]] || fail "T2 discovery error publishes completion"
printf 'options=pcie_ports=compat\n' >"$tmp/t2.conf"; printf '[Fan1]\n' >"$tmp/fan.conf"; : >"$tmp/cmdline"; : >"$tmp/t2.log"
if T2_PRESENT=1 TINY_DFR=1 LIMINE_FAIL=1 T2_LOG="$tmp/t2.log" root_run "$t2_body" --machine; then fail "T2 rebuild failure publishes completion"; fi
[[ ! -e $tmp/t2.marker ]] || fail "T2 mutation failure is not retryable"
T2_PRESENT=1 TINY_DFR=1 T2_LOG="$tmp/t2.log" root_run "$t2_body" --machine
[[ -e $tmp/t2.marker ]] || fail "T2 retry did not publish completion"
grep -Fq 'pm_async=off mem_sleep_default=deep' "$tmp/t2.conf" || fail "T2 retry did not repair boot parameters"
grep -Fq '[Fan2]' "$tmp/fan.conf" || fail "T2 retry did not add the second fan"
[[ $(grep -c '^rebuild$' "$tmp/t2.log") == 1 ]] || fail "T2 retry did not run exactly one successful rebuild"
T2_PRESENT=1 root_run "$t2_body" --machine
pass "T2 machine body preserves discovery and rebuild failures, completes a retry, and replays without mutation"

t2_dispatch="$tmp/t2-dispatch.sh"; script_copy 1785944594 "$t2_dispatch"
t2_dispatch_marker="$tmp/t2-dispatch.marker"; t2_dispatch_lock="$tmp/t2-dispatch.lock"; t2_dispatch_log="$tmp/t2-dispatch.log"
t2_dispatch_conf="$tmp/t2-dispatch.conf"; t2_dispatch_fan="$tmp/t2-dispatch-fan.conf"; t2_dispatch_cmdline="$tmp/t2-dispatch-cmdline"
t2_dispatch_lspci="$tmp/t2-dispatch-lspci"; t2_dispatch_pacman="$tmp/t2-dispatch-pacman"; t2_dispatch_limine="$tmp/t2-dispatch-limine"; t2_dispatch_sudo="$tmp/t2-dispatch-sudo"
printf 'options=pm_async=off mem_sleep_default=deep\n' >"$t2_dispatch_conf"
printf '[Fan2]\n' >"$t2_dispatch_fan"
printf 'quiet pm_async=off mem_sleep_default=deep\n' >"$t2_dispatch_cmdline"
touch "$tmp/t2-fail-once"
touch "$tmp/t2-present"
cat >"$t2_dispatch_lspci" <<SH
#!/bin/bash
[[ -e '$tmp/t2-present' ]] && echo '00:00.0 ISA bridge [0601]: Apple Inc. T2 [106b:1801]'
exit 0
SH
cat >"$t2_dispatch_pacman" <<'SH'
#!/bin/bash
[[ $1 == -Qq ]] && exit 0
exit 91
SH
cat >"$t2_dispatch_limine" <<SH
#!/bin/bash
printf 'rebuild\n' >>'$t2_dispatch_log'
if [[ -e '$tmp/t2-fail-once' ]]; then
  rm -f '$tmp/t2-fail-once'
  exit 27
fi
SH
cat >"$t2_dispatch_sudo" <<SH
#!/bin/bash
[[ \$1 == -N && \$2 == -- ]] || exit 90
printf 'sudo\n' >>'$t2_dispatch_log'
shift 2
exec "\$@"
SH
chmod +x "$t2_dispatch_lspci" "$t2_dispatch_pacman" "$t2_dispatch_limine" "$t2_dispatch_sudo"
sed -i -e "s|/usr/bin/lspci|$t2_dispatch_lspci|g" -e "s|/usr/bin/pacman|$t2_dispatch_pacman|g" -e "s|/usr/bin/limine-mkinitcpio|$t2_dispatch_limine|g" -e "s|/usr/bin/sudo|$t2_dispatch_sudo|g" -e "s|/run/omarchy-t2-hardware-migration.lock|$t2_dispatch_lock|g" -e "s|/usr/share/omarchy/migrations/1785944594.sh|$t2_dispatch|g" -e "s|/var/lib/omarchy/migrations/1785944594|$t2_dispatch_marker|g" -e "s|/etc/limine-entry-tool.d/t2-mac.conf|$t2_dispatch_conf|g" -e "s|/etc/t2fand.conf|$t2_dispatch_fan|g" -e "s|/proc/cmdline|$t2_dispatch_cmdline|g" "$t2_dispatch"
if root_run "$t2_dispatch" --machine; then fail "T2 failed rebuild publishes completion in full retry fixture"; fi
[[ ! -e $t2_dispatch_marker && $(grep -c '^rebuild$' "$t2_dispatch_log") == 1 ]] || fail "T2 failed rebuild did not remain pending"
root_run "$t2_dispatch"
[[ -e $t2_dispatch_marker && $(grep -c '^rebuild$' "$t2_dispatch_log") == 2 && $(grep -c '^sudo$' "$t2_dispatch_log") == 1 ]] || fail "T2 no-argument dispatch did not retry and mark an already-correct persistent configuration"
root_run "$t2_dispatch"
[[ $(grep -c '^sudo$' "$t2_dispatch_log") == 1 && $(grep -c '^rebuild$' "$t2_dispatch_log") == 2 ]] || fail "T2 marked replay entered the privileged transaction"
rm -f "$t2_dispatch_marker" "$tmp/t2-present"
root_run "$t2_dispatch"
[[ $(grep -c '^sudo$' "$t2_dispatch_log") == 1 && ! -e $t2_dispatch_marker ]] || fail "confirmed non-T2 hardware entered the privileged transaction"
pass "T2 full no-argument dispatch retries an unmarked failed rebuild and keeps marked or confirmed non-T2 runs unprivileged"

cups_bin="$tmp/cups-bin"; mkdir "$cups_bin"; printf '#!/bin/bash\nexit 9\n' >"$cups_bin/pacman"; chmod +x "$cups_bin/pacman"
cups_body="$tmp/cups-body.sh"; script_copy 1787815267 "$cups_body"
sed -i -e "s|/usr/bin/pacman|$cups_bin/pacman|g" -e "s|/var/lib/omarchy/migrations/1787815267|$tmp/cups.marker|g" "$cups_body"
if root_run "$cups_body" --machine; then fail "CUPS package discovery error is treated as absence"; fi
[[ ! -e $tmp/cups.marker ]] || fail "CUPS discovery error publishes completion"
pass "CUPS machine body preserves package discovery errors for retry"

cat >"$cups_bin/pacman" <<'SH'
#!/bin/bash
[[ $1 == -Qq ]] && { printf 'cups\n'; exit 0; }
exit 0
SH
cat >"$cups_bin/getent" <<'SH'
#!/bin/bash
if (( $# == 2 )) && [[ $1 == passwd && $2 == cups-browsed ]]; then
  echo 'cups-browsed:x:209:209:CUPS printer discovery:/:/usr/bin/nologin'
elif (( $# == 2 )) && [[ $1 == group && $2 == cups-browsed ]]; then
  echo 'cups-browsed:x:209:'
elif (( $# == 1 )) && [[ $1 == passwd ]]; then
  exit "${NSS_ENUM_STATUS:-0}"
else
  exit 2
fi
SH
cat >"$cups_bin/systemctl" <<'SH'
#!/bin/bash
[[ $1 == is-active ]] && exit 3
[[ $1 == is-enabled ]] && { echo disabled; exit 1; }
[[ ${CUPS_MUTATE_FAIL:-0} == 0 ]] || exit 23
exit 0
SH
chmod +x "$cups_bin"/*
sed -i -e "s|/usr/bin/getent|$cups_bin/getent|g" -e "s|/usr/bin/systemctl|$cups_bin/systemctl|g" "$cups_body"
if NSS_ENUM_STATUS=8 root_run "$cups_body" --machine; then fail "CUPS full passwd enumeration failure is treated as empty output"; fi
[[ ! -e $tmp/cups.marker ]] || fail "CUPS NSS enumeration failure publishes completion"
if NSS_ENUM_STATUS=0 CUPS_MUTATE_FAIL=1 root_run "$cups_body" --machine; then fail "CUPS service mutation failure publishes completion"; fi
[[ ! -e $tmp/cups.marker ]] || fail "CUPS service mutation failure is not retryable"
NSS_ENUM_STATUS=0 root_run "$cups_body" --machine
[[ -e $tmp/cups.marker ]] || fail "CUPS NSS enumeration failure is not retryable"
NSS_ENUM_STATUS=8 root_run "$cups_body" --machine
pass "CUPS NSS and service mutation failures remain pending, retry successfully, and replay without querying NSS"

for transformed in "$fido_body" "$bt_body" "$t2_body" "$cups_body"; do
  gate_output="$tmp/$(basename "$transformed").gate-output"
  set +e
  /usr/bin/bash -p "$transformed" --machine >"$gate_output" 2>&1
  gate_status=$?
  set -e
  [[ $gate_status == 1 ]] || fail "$(basename "$transformed") returns $gate_status instead of the root-gate status"
  grep -Fq 'its machine phase requires root' "$gate_output" || fail "$(basename "$transformed") did not execute the non-root machine gate"
  if root_run "$transformed" --unexpected >/dev/null 2>&1; then fail "$(basename "$transformed") accepts an unexpected argument"; fi
done
pass "all transformed production dispatchers preserve their EUID and argument gates"

for id in 1785944594 1786380259 1787494718 1787815267; do
  source_file="$ROOT/migrations/$id.sh"
  grep -Fq '/usr/bin/env -i PATH=/usr/bin:/bin' "$source_file" || fail "$id inherits caller environment"
  grep -Fq "/usr/share/omarchy/migrations/$id.sh --machine" "$source_file" || fail "$id lacks a fixed packaged target"
  ! grep -Eq 'OMARCHY_[A-Z_]+:-?/' "$source_file" || fail "$id gives caller path authority"
done
pass "machine phases retain fixed paths and a clean privileged environment"
