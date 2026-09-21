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
# Status 3 covers inactive, failed and transitional states. Missing units print
# inactive and return 4 on the supported systemd version.
cat >"$bt_bin/systemctl" <<'SH'
#!/bin/bash
[[ $1 == is-active ]] || exit 2
if [[ -n ${BT_DAEMON_STATE:-} ]]; then
  printf '%s\n' "$BT_DAEMON_STATE"
elif (( ${BT_DAEMON_STATUS:-0} == 0 )); then
  echo active
else
  echo inactive
fi
exit "${BT_DAEMON_STATUS:-0}"
SH
chmod +x "$bt_bin"/*
bt_body="$tmp/bt-body.sh"; bt_marker="$tmp/bt.marker"; bt_conf="$tmp/main.conf"; printf 'AutoEnable=false\n' >"$bt_conf"
script_copy 1786380259 "$bt_body"
sed -i -e "s|/usr/bin/timeout|$bt_bin/timeout|g" -e "s|/usr/bin/bluetoothctl|$bt_bin/bluetoothctl|g" -e "s|/usr/bin/omarchy-bluetooth-power|$bt_bin/power|g" -e "s|/usr/bin/systemctl|$bt_bin/systemctl|g" -e "s|/var/lib/omarchy/migrations/1786380259|$bt_marker|g" -e "s|/etc/bluetooth/main.conf|$bt_conf|g" "$bt_body"
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
# No bluetoothd to ask, as on a machine without an adapter or with the service
# off, means the adapter has been off: that completes as off without asking
# (the query stand-in would fail if asked). An unknown service state stays
# pending.
for daemon in 3 4; do
  rm -f "$bt_marker"; : >"$tmp/bt.log"
  BT_LOG="$tmp/bt.log" BT_DAEMON_STATUS=$daemon BT_QUERY_FAIL=1 root_run "$bt_body" --machine || fail "Bluetooth without a daemon ($daemon) did not complete"
  [[ $(cat "$tmp/bt.log") == off && -e $bt_marker ]] || fail "Bluetooth without a daemon ($daemon) was not kept off"
done
rm -f "$bt_marker"; : >"$tmp/bt.log"
if BT_LOG="$tmp/bt.log" BT_DAEMON_STATUS=1 root_run "$bt_body" --machine; then fail "an unknown bluetooth.service state completed the migration"; fi
[[ ! -e $bt_marker && ! -s $tmp/bt.log ]] || fail "an unknown bluetooth.service state changed policy"
for daemon_state in failed activating deactivating reloading unknown; do
  rm -f "$bt_marker"; : >"$tmp/bt.log"
  if BT_LOG="$tmp/bt.log" BT_DAEMON_STATUS=3 BT_DAEMON_STATE=$daemon_state root_run "$bt_body" --machine; then
    fail "Bluetooth $daemon_state state completed as powered off"
  fi
  [[ ! -e $bt_marker && ! -s $tmp/bt.log ]] || fail "Bluetooth $daemon_state state changed power or completion"
done
BT_LOG="$tmp/bt.log" BT_POWER=yes root_run "$bt_body" --machine
[[ $(cat "$tmp/bt.log") == on && -e $bt_marker ]] || fail "Bluetooth failed-state retry did not preserve powered-on state"
pass "Bluetooth machine body preserves on/off state, keeps a machine without bluetoothd off, replays safely, and retries discovery and mutation failures"

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
printf '#!/bin/bash\necho active\n' >"$tmp/bt-dispatch-systemctl"; chmod +x "$tmp/bt-dispatch-systemctl"
cat >"$bt_dispatch_sudo" <<'SH'
#!/bin/bash
[[ $1 == -N && $2 == -- ]] || exit 90
shift 2
exec "$@"
SH
chmod +x "$bt_dispatch_power" "$bt_dispatch_ctl" "$bt_dispatch_timeout" "$bt_dispatch_sudo"
sed -i -e "s|/usr/bin/timeout|$bt_dispatch_timeout|g" -e "s|/usr/bin/bluetoothctl|$bt_dispatch_ctl|g" -e "s|/usr/bin/omarchy-bluetooth-power|$bt_dispatch_power|g" -e "s|/usr/bin/sudo|$bt_dispatch_sudo|g" -e "s|/usr/bin/systemctl|$tmp/bt-dispatch-systemctl|g" -e "s|/run/omarchy-bluetooth-state-migration.lock|$bt_dispatch_lock|g" -e "s|/usr/share/omarchy/migrations/1786380259.sh|$bt_dispatch|g" -e "s|/var/lib/omarchy/migrations/1786380259|$bt_dispatch_marker|g" -e "s|/etc/bluetooth/main.conf|$tmp/no-bt-conf|g" "$bt_dispatch"
root_run "$bt_dispatch" & bt_pid_one=$!
root_run "$bt_dispatch" & bt_pid_two=$!
wait "$bt_pid_one"; wait "$bt_pid_two"
[[ -e $bt_dispatch_marker && $(grep -c '^start$' "$bt_dispatch_log") == 1 && $(grep -c '^on$' "$bt_dispatch_log") == 1 ]] || fail "Bluetooth full dispatch is not serialized and replay safe"
pass "Bluetooth full no-argument dispatch preserves sudo arguments, clean environment, flock serialization, recheck, and marker replay"


# Stand-in for limine-entry-tool --get-cmdline linux-t2: applies = and += in order for
# the default key to the drop-in's active lines, stripping one pair of double
# quotes, the way Limine resolves the installer's format. T2_EFFECTIVE, when
# set, overrides the answer to model a form the rewrite cannot change.
write_entry_stub() {
  cat >"$1" <<SH
#!/bin/bash
[[ \${1:-} == --get-cmdline ]] || exit 64
# The real tool prints its usage and exits 0 without a kernel name.
[[ \${2:-} == linux-t2 ]] || { printf 'Invalid arguments\nUsage: limine-entry-tool [options] [--quiet]\n'; exit 0; }
[[ -z \${T2_EFFECTIVE:-} ]] || { printf '%s\n' "\$T2_EFFECTIVE"; exit 0; }
cmdline=""
[[ -f '$2' ]] || { echo; exit 0; }
while IFS= read -r line; do
  [[ \$line =~ ^[[:space:]]*# ]] && continue
  [[ \$line =~ ^KERNEL_CMDLINE\\[default\\](\\+?)=(.*)\$ ]] || continue
  value=\${BASH_REMATCH[2]}; [[ \$value == \\"*\\" ]] && { value=\${value#\\"}; value=\${value%\\"}; }
  if [[ -n \${BASH_REMATCH[1]} ]]; then cmdline+=" \$value"; else cmdline=\$value; fi
done <'$2'
printf '%s\n' "\$cmdline"
SH
  chmod +x "$1"
}
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
write_entry_stub "$t2_bin/entry" "$tmp/t2.conf"
sed -i -e "s|/usr/bin/lspci|$t2_bin/lspci|g" -e "s|/usr/bin/pacman|$t2_bin/pacman|g" -e "s|/usr/bin/systemctl|$t2_bin/systemctl|g" -e "s|/usr/bin/limine-mkinitcpio|$t2_bin/limine|g" -e "s|/usr/bin/limine-entry-tool|$t2_bin/entry|g" -e "s|/var/lib/omarchy/migrations/1785944594|$tmp/t2.marker|g" -e "s|/etc/limine-entry-tool.d/t2-mac.conf|$tmp/t2.conf|g" -e "s|/etc/t2fand.conf|$tmp/fan.conf|g" -e "s|/proc/cmdline|$tmp/cmdline|g" "$t2_body"
# A copy whose Limine reader can be made to fail with an I/O-style status.
printf '#!/bin/bash\n[[ ${T2_GREP_FAIL:-0} != 1 ]] || exit 2\nexec /usr/bin/grep "$@"\n' >"$t2_bin/grep"; chmod +x "$t2_bin/grep"
t2_grep_body="$tmp/t2-grep-body.sh"; sed -e "s|/usr/bin/grep -v|$t2_bin/grep -v|" "$t2_body" >"$t2_grep_body"
grep -qF "$t2_bin/grep -v" "$t2_grep_body" || fail "test could not redirect the Limine reader"
if T2_QUERY_STATUS=7 root_run "$t2_body" --machine; then fail "T2 discovery error is treated as inapplicable"; fi
[[ ! -e $tmp/t2.marker ]] || fail "T2 discovery error publishes completion"
printf 'KERNEL_CMDLINE[default]+=" intel_iommu=on pcie_ports=compat"\n' >"$tmp/t2.conf"; printf '[Fan1]\n' >"$tmp/fan.conf"; : >"$tmp/cmdline"; : >"$tmp/t2.log"
if T2_PRESENT=1 TINY_DFR=1 LIMINE_FAIL=1 T2_LOG="$tmp/t2.log" root_run "$t2_body" --machine; then fail "T2 rebuild failure publishes completion"; fi
[[ ! -e $tmp/t2.marker ]] || fail "T2 mutation failure is not retryable"
T2_PRESENT=1 TINY_DFR=1 T2_LOG="$tmp/t2.log" root_run "$t2_body" --machine
[[ -e $tmp/t2.marker ]] || fail "T2 retry did not publish completion"
grep -Fq 'pm_async=off mem_sleep_default=deep' "$tmp/t2.conf" || fail "T2 retry did not repair boot parameters"
grep -Fq '[Fan2]' "$tmp/fan.conf" || fail "T2 retry did not add the second fan"
[[ $(grep -c '^rebuild$' "$tmp/t2.log") == 1 ]] || fail "T2 retry did not run exactly one successful rebuild"
T2_PRESENT=1 root_run "$t2_body" --machine
# Completion means a successful rebuild of the new parameters. Without the
# drop-in, or with a drop-in that has neither the old nor the new parameters,
# there is nothing to rebuild, and no marker may stop a later run from
# rebuilding once the parameters are configured.
for layout in missing unrelated; do
  rm -f "$tmp/t2.marker"; : >"$tmp/t2.log"; printf '[Fan1]\n[Fan2]\n' >"$tmp/fan.conf"
  if [[ $layout == missing ]]; then rm -f "$tmp/t2.conf"; else printf 'options=quiet\n' >"$tmp/t2.conf"; fi
  T2_PRESENT=1 T2_LOG="$tmp/t2.log" root_run "$t2_body" --machine
  [[ ! -e $tmp/t2.marker && ! -s $tmp/t2.log ]] || fail "T2 $layout drop-in published completion without a rebuild"
done
# Commented-out parameters are not configured: no rebuild, no marker, and a
# commented old parameter is not rewritten.
for commented in '# options=pm_async=off mem_sleep_default=deep' '#options=pcie_ports=compat'; do
  rm -f "$tmp/t2.marker"; : >"$tmp/t2.log"; printf '%s\noptions=quiet\n' "$commented" >"$tmp/t2.conf"
  T2_PRESENT=1 T2_LOG="$tmp/t2.log" root_run "$t2_body" --machine
  [[ ! -e $tmp/t2.marker && ! -s $tmp/t2.log ]] || fail "T2 treated a commented parameter as configured: $commented"
  grep -qxF "$commented" "$tmp/t2.conf" || fail "T2 rewrote a commented parameter: $commented"
done
# Near-miss tokens are not the parameters, and are never rewritten.
for near in 'KERNEL_CMDLINE[default]+=" not_pm_async=off mem_sleep_default=deepfake"' 'KERNEL_CMDLINE[default]+=" xpcie_ports=compat"'; do
  rm -f "$tmp/t2.marker"; : >"$tmp/t2.log"; printf '%s\n' "$near" >"$tmp/t2.conf"
  T2_PRESENT=1 T2_LOG="$tmp/t2.log" root_run "$t2_body" --machine
  [[ ! -e $tmp/t2.marker && ! -s $tmp/t2.log ]] || fail "T2 treated a near-miss token as a parameter: $near"
  grep -qxF "$near" "$tmp/t2.conf" || fail "T2 rewrote a near-miss token: $near"
done
# Decisions follow Limine's effective command line, not the drop-in's text:
# a later = override, another kernel's key, and an unquoted assignment.
t2_case() {
  rm -f "$tmp/t2.marker"; : >"$tmp/t2.log"; printf '%b\n' "$1" >"$tmp/t2.conf"
  T2_PRESENT=1 T2_LOG="$tmp/t2.log" root_run "$t2_body" --machine
}
t2_case 'KERNEL_CMDLINE[default]+=" pcie_ports=compat"\nKERNEL_CMDLINE[default]=" quiet"'
[[ ! -e $tmp/t2.marker && ! -s $tmp/t2.log ]] || fail "T2 acted on an overridden parameter"
grep -qF 'pcie_ports=compat' "$tmp/t2.conf" || fail "T2 rewrote a parameter Limine does not apply"
t2_case 'KERNEL_CMDLINE[linux-zen]+=" pm_async=off mem_sleep_default=deep"'
[[ ! -e $tmp/t2.marker && ! -s $tmp/t2.log ]] || fail "T2 certified parameters that belong to another kernel"
t2_case 'KERNEL_CMDLINE[default]+=pm_async=off mem_sleep_default=deep'
[[ -e $tmp/t2.marker && $(grep -c '^rebuild$' "$tmp/t2.log") == 1 ]] || fail "T2 missed an unquoted assignment Limine applies"
# Repeated old tokens are all replaced before completion is certified.
t2_case 'KERNEL_CMDLINE[default]+=" pcie_ports=compat pcie_ports=compat"'
[[ -e $tmp/t2.marker ]] && ! grep -q 'pcie_ports=compat' "$tmp/t2.conf" || fail "T2 left a repeated old parameter behind" "$(cat "$tmp/t2.conf")"
# A form the rewrite cannot change stays pending rather than certified.
rm -f "$tmp/t2.marker"; : >"$tmp/t2.log"; printf 'KERNEL_CMDLINE[default]+=" pcie_ports=compat"\n' >"$tmp/t2.conf"
if T2_PRESENT=1 T2_EFFECTIVE='quiet pcie_ports=compat' T2_LOG="$tmp/t2.log" root_run "$t2_body" --machine; then fail "T2 completed while Limine still applies the old parameter"; fi
[[ ! -e $tmp/t2.marker && ! -s $tmp/t2.log ]] || fail "T2 rebuilt or certified with the old parameter still effective"
# Limine's usage text, printed with status 0, is not a command line.
rm -f "$tmp/t2.marker"; : >"$tmp/t2.log"; printf 'KERNEL_CMDLINE[default]+=" pm_async=off mem_sleep_default=deep"\n' >"$tmp/t2.conf"
if T2_PRESENT=1 T2_EFFECTIVE=$'Invalid arguments\nUsage: limine-entry-tool [options] [--quiet]' T2_LOG="$tmp/t2.log" root_run "$t2_body" --machine; then fail "T2 completed on Limine's usage text"; fi
[[ ! -e $tmp/t2.marker && ! -s $tmp/t2.log ]] || fail "T2 rebuilt or certified from Limine's usage text"
# A drop-in that cannot be read is neither configured nor unconfigured.
rm -f "$tmp/t2.marker"; printf 'KERNEL_CMDLINE[default]+=" pcie_ports=compat"\n' >"$tmp/t2.conf"
if T2_PRESENT=1 T2_GREP_FAIL=1 T2_LOG="$tmp/t2.log" root_run "$t2_grep_body" --machine; then fail "a Limine read error was treated as nothing to repair"; fi
[[ ! -e $tmp/t2.marker ]] || fail "a Limine read error published completion"
printf 'KERNEL_CMDLINE[default]+=" intel_iommu=on pm_async=off mem_sleep_default=deep"\n' >"$tmp/t2.conf"
T2_PRESENT=1 T2_LOG="$tmp/t2.log" root_run "$t2_body" --machine
[[ -e $tmp/t2.marker && $(grep -c '^rebuild$' "$tmp/t2.log") == 1 ]] || fail "T2 parameters configured later were not rebuilt"
pass "T2 machine body preserves discovery and rebuild failures, completes a retry, and replays without mutation"

t2_dispatch="$tmp/t2-dispatch.sh"; script_copy 1785944594 "$t2_dispatch"
t2_dispatch_marker="$tmp/t2-dispatch.marker"; t2_dispatch_lock="$tmp/t2-dispatch.lock"; t2_dispatch_log="$tmp/t2-dispatch.log"
t2_dispatch_conf="$tmp/t2-dispatch.conf"; t2_dispatch_fan="$tmp/t2-dispatch-fan.conf"; t2_dispatch_cmdline="$tmp/t2-dispatch-cmdline"
t2_dispatch_lspci="$tmp/t2-dispatch-lspci"; t2_dispatch_pacman="$tmp/t2-dispatch-pacman"; t2_dispatch_limine="$tmp/t2-dispatch-limine"; t2_dispatch_sudo="$tmp/t2-dispatch-sudo"
printf 'KERNEL_CMDLINE[default]+=" intel_iommu=on pm_async=off mem_sleep_default=deep"\n' >"$t2_dispatch_conf"
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
write_entry_stub "$tmp/t2-dispatch-entry" "$t2_dispatch_conf"
sed -i -e "s|/usr/bin/limine-entry-tool|$tmp/t2-dispatch-entry|g" -e "s|/usr/bin/lspci|$t2_dispatch_lspci|g" -e "s|/usr/bin/pacman|$t2_dispatch_pacman|g" -e "s|/usr/bin/limine-mkinitcpio|$t2_dispatch_limine|g" -e "s|/usr/bin/sudo|$t2_dispatch_sudo|g" -e "s|/run/omarchy-t2-hardware-migration.lock|$t2_dispatch_lock|g" -e "s|/usr/share/omarchy/migrations/1785944594.sh|$t2_dispatch|g" -e "s|/var/lib/omarchy/migrations/1785944594|$t2_dispatch_marker|g" -e "s|/etc/limine-entry-tool.d/t2-mac.conf|$t2_dispatch_conf|g" -e "s|/etc/t2fand.conf|$t2_dispatch_fan|g" -e "s|/proc/cmdline|$t2_dispatch_cmdline|g" "$t2_dispatch"
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
# cups-browsed is not installed by default: systemctl then reports no such
# unit, 4 from is-active and not-found from is-enabled.
if [[ $1 == is-active ]]; then
  case ${CUPS_BROWSED_STATE:-not-found} in not-found) exit 4 ;; error) exit 1 ;; *) exit 3 ;; esac
fi
if [[ $1 == is-enabled ]]; then
  case ${CUPS_BROWSED_STATE:-not-found} in not-found) echo not-found; exit 4 ;; disabled) echo disabled; exit 1 ;; *) echo "$CUPS_BROWSED_STATE"; exit 0 ;; esac
fi
[[ -z ${CUPS_LOG:-} ]] || echo "systemctl $*" >>"$CUPS_LOG"
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
# systemctl is-enabled exits 0 for static and similar units too; only an
# enabled cups-browsed may be restarted.
for state in static indirect alias enabled; do
  rm -f "$tmp/cups.marker"; : >"$tmp/cups.log"
  CUPS_BROWSED_STATE=$state CUPS_LOG="$tmp/cups.log" root_run "$cups_body" --machine
  if [[ $state == enabled ]]; then
    grep -qx 'systemctl restart cups-browsed.service' "$tmp/cups.log" || fail "an enabled cups-browsed was not restarted"
  elif grep -q 'restart cups-browsed.service' "$tmp/cups.log"; then
    fail "a $state cups-browsed was restarted as if it were enabled"
  fi
done
# The default install has no cups-browsed unit at all; that completes. A
# service query that fails outright stays pending.
rm -f "$tmp/cups.marker"; : >"$tmp/cups.log"
CUPS_BROWSED_STATE=not-found CUPS_LOG="$tmp/cups.log" root_run "$cups_body" --machine || fail "CUPS hardening failed without a cups-browsed unit"
[[ -e $tmp/cups.marker ]] && ! grep -q 'cups-browsed' "$tmp/cups.log" || fail "CUPS hardening without cups-browsed did not complete cleanly"
rm -f "$tmp/cups.marker"
if CUPS_BROWSED_STATE=error root_run "$cups_body" --machine; then fail "an unknown cups-browsed state completed CUPS hardening"; fi
[[ ! -e $tmp/cups.marker ]] || fail "an unknown cups-browsed state published completion"
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
