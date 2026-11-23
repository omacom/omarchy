#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

mock_path="$test_tmp/pkg-drop-bin"
mkdir -p "$mock_path"

cat >"$mock_path/pacman" <<'EOF'
#!/bin/bash
if [[ $1 == "-Qq" ]]; then
  if [[ ${TEST_PACKAGES_EMPTY:-0} == "0" ]]; then
    printf '%s\n' exact-package provider-package
  fi
  exit "${TEST_QUERY_STATUS:-0}"
fi
EOF

cat >"$mock_path/sudo" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >"$TEST_TMP/pkg-drop-command"
exit "${TEST_REMOVE_STATUS:-0}"
EOF

chmod +x "$mock_path/pacman" "$mock_path/sudo"

PATH="$mock_path:$PATH" TEST_TMP="$test_tmp" \
  "$ROOT/bin/omarchy-pkg-drop" exact-package virtual-package provider-package exact-package

[[ $(<"$test_tmp/pkg-drop-command") == "pacman -Rns --noconfirm exact-package provider-package" ]] ||
  fail "package removal targets exact installed names only"
pass "package removal ignores providers and duplicate arguments"

rm "$test_tmp/pkg-drop-command"
if PATH="$mock_path:$PATH" TEST_TMP="$test_tmp" TEST_QUERY_STATUS=1 \
  "$ROOT/bin/omarchy-pkg-drop" exact-package >"$test_tmp/output" 2>&1; then
  fail "failed package discovery must fail removal even with partial output"
fi
[[ ! -e $test_tmp/pkg-drop-command ]] || fail "failed discovery must not request privileges"
pass "package removal propagates discovery errors before requesting privileges"

PATH="$mock_path:$PATH" TEST_TMP="$test_tmp" TEST_PACKAGES_EMPTY=1 \
  "$ROOT/bin/omarchy-pkg-drop" exact-package
[[ ! -e $test_tmp/pkg-drop-command ]] || fail "empty package database must not request privileges"
pass "an empty package database is a successful no-op"

if PATH="$mock_path:$PATH" TEST_TMP="$test_tmp" TEST_REMOVE_STATUS=1 \
  "$ROOT/bin/omarchy-pkg-drop" exact-package; then
  fail "failed package transaction must fail removal"
fi
pass "package removal propagates transaction failures"

# omarchy-pkg-add queues packages when OMARCHY_PKG_DEFER=1 with a queue file,
# skips already-installed queued packages on flush, and folds queued packages
# into the next immediate install.
add_bin="$test_tmp/pkg-add-bin"
mkdir -p "$add_bin"
cat >"$add_bin/pacman" <<'EOF'
#!/bin/bash
if [[ $1 == "-Q" ]]; then
  pkg="${!#}"
  grep -qxF "$pkg" "$TEST_TMP/installed" 2>/dev/null
  exit $?
fi
if [[ $1 == "-S" ]]; then
  printf '%s\n' "$*" >>"$TEST_TMP/pkg-add-calls"
  for arg in "$@"; do
    [[ $arg == -* ]] && continue
    echo "$arg" >>"$TEST_TMP/installed"
  done
  exit 0
fi
EOF
cat >"$add_bin/sudo" <<'EOF'
#!/bin/bash
exec "$@"
EOF
chmod +x "$add_bin/pacman" "$add_bin/sudo"

printf 'already-installed\n' >"$test_tmp/installed"
queue_file="$test_tmp/pkg-queue"
: >"$queue_file"

PATH="$add_bin:$ROOT/bin:$PATH" TEST_TMP="$test_tmp" OMARCHY_PKG_QUEUE_FILE="$queue_file" OMARCHY_PKG_DEFER=1 \
  "$ROOT/bin/omarchy-pkg-add" pkg-a already-installed pkg-b
PATH="$add_bin:$ROOT/bin:$PATH" TEST_TMP="$test_tmp" OMARCHY_PKG_QUEUE_FILE="$queue_file" OMARCHY_PKG_DEFER=1 \
  "$ROOT/bin/omarchy-pkg-add" pkg-b pkg-c
[[ ! -e $test_tmp/pkg-add-calls ]] || fail "deferred pkg-add must not invoke pacman immediately"

PATH="$add_bin:$ROOT/bin:$PATH" TEST_TMP="$test_tmp" OMARCHY_PKG_QUEUE_FILE="$queue_file" \
  "$ROOT/bin/omarchy-pkg-add" pkg-d
[[ $(<"$test_tmp/pkg-add-calls") == "-S --noconfirm --needed -- pkg-a pkg-b pkg-c pkg-d" ]] ||
  fail "immediate pkg-add flushes deduplicated missing queued packages in one transaction" "$(<"$test_tmp/pkg-add-calls")"
[[ ! -s $queue_file ]] || fail "queue file must be empty after flush"
pass "pkg-add batches deferred packages into a single pacman transaction"

# Failed pacman transactions must leave the queue intact instead of truncating it.
cat >"$add_bin/pacman" <<'EOF'
#!/bin/bash
if [[ $1 == "-Q" ]]; then
  pkg="${!#}"
  grep -qxF "$pkg" "$TEST_TMP/installed" 2>/dev/null
  exit $?
fi
if [[ $1 == "-S" ]]; then
  printf '%s\n' "$*" >>"$TEST_TMP/pkg-add-calls"
  if [[ ${TEST_PACMAN_FAIL:-0} == "1" ]]; then
    exit 1
  fi
  for arg in "$@"; do
    [[ $arg == -* ]] && continue
    echo "$arg" >>"$TEST_TMP/installed"
  done
  exit 0
fi
EOF
cat >"$add_bin/systemctl" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_TMP/systemctl-calls"
exit "${TEST_SYSTEMCTL_FAIL:-0}"
EOF
chmod +x "$add_bin/pacman" "$add_bin/systemctl"

rm -f "$test_tmp/pkg-add-calls" "$test_tmp/systemctl-calls"
printf 'pkg-fail\n' >"$queue_file"
service_queue="$test_tmp/service-queue"
printf 'intel_lpmd.service\nthermald.service\nintel_lpmd.service\n' >"$service_queue"

if PATH="$add_bin:$ROOT/bin:$PATH" TEST_TMP="$test_tmp" TEST_PACMAN_FAIL=1 \
  OMARCHY_PKG_QUEUE_FILE="$queue_file" OMARCHY_SERVICE_QUEUE_FILE="$service_queue" \
  bash -eE "$ROOT/install/helpers/flush-packages.sh"; then
  fail "flush-packages.sh must fail when pacman fails"
fi
[[ $(<"$queue_file") == "pkg-fail" ]] || fail "failed pacman transaction must preserve package queue"
[[ ! -e $test_tmp/systemctl-calls ]] || fail "failed pacman transaction must not enable queued services"
[[ -s $service_queue ]] || fail "failed pacman transaction must preserve service queue"
pass "failed package flush preserves both package and service queues"

# Succeeding flush installs queued packages, enables deduplicated services once,
# and empties both queues.
rm -f "$test_tmp/pkg-add-calls" "$test_tmp/systemctl-calls"
PATH="$add_bin:$ROOT/bin:$PATH" TEST_TMP="$test_tmp" \
  OMARCHY_PKG_QUEUE_FILE="$queue_file" OMARCHY_SERVICE_QUEUE_FILE="$service_queue" \
  bash -eE "$ROOT/install/helpers/flush-packages.sh"
[[ $(<"$test_tmp/pkg-add-calls") == "-S --noconfirm --needed -- pkg-fail" ]] ||
  fail "flush-packages.sh installs queued packages"
[[ $(<"$test_tmp/systemctl-calls") == "enable intel_lpmd.service thermald.service" ]] ||
  fail "flush-packages.sh enables deduplicated services in one call" "$(<"$test_tmp/systemctl-calls")"
[[ ! -s $queue_file && ! -s $service_queue ]] || fail "successful flush empties both queues"
pass "flush-packages.sh installs queued packages and batches service enablement"

# Queued services are still enabled even when all queued packages are already installed.
rm -f "$test_tmp/pkg-add-calls" "$test_tmp/systemctl-calls"
printf 'already-installed\n' >"$queue_file"
printf 'thermald.service\n' >"$service_queue"
PATH="$add_bin:$ROOT/bin:$PATH" TEST_TMP="$test_tmp" \
  OMARCHY_PKG_QUEUE_FILE="$queue_file" OMARCHY_SERVICE_QUEUE_FILE="$service_queue" \
  bash -eE "$ROOT/install/helpers/flush-packages.sh"
[[ ! -e $test_tmp/pkg-add-calls ]] || fail "already-installed queued packages must not invoke pacman -S"
[[ $(<"$test_tmp/systemctl-calls") == "enable thermald.service" ]] ||
  fail "queued services must still be enabled when packages are already installed"
[[ ! -s $queue_file && ! -s $service_queue ]] || fail "both queues are cleared when packages were already installed"
pass "flush-packages.sh enables queued services when packages are already installed"

# run_logged skips strictly ARM-only leaves on x86_64 at execution time while
# running all leaves on aarch64 and keeping hardware/all.sh pure run_logged lines
# so image builds enumerate the full ordered list.
hw_x86_bin="$test_tmp/uname-x86"
hw_arm_bin="$test_tmp/uname-arm"
mkdir -p "$hw_x86_bin" "$hw_arm_bin"
printf '#!/bin/bash\n[[ ${1:-} == -m ]] && { echo x86_64; exit 0; }\nexec /usr/bin/uname "$@"\n' >"$hw_x86_bin/uname"
printf '#!/bin/bash\n[[ ${1:-} == -m ]] && { echo aarch64; exit 0; }\nexec /usr/bin/uname "$@"\n' >"$hw_arm_bin/uname"
chmod +x "$hw_x86_bin/uname" "$hw_arm_bin/uname"

list_hw_executed() {
  local bin_dir=$1
  PATH="$bin_dir:$ROOT/bin:$PATH" OMARCHY_INSTALL="$ROOT/install" \
    bash -c '
      source "$OMARCHY_INSTALL/helpers/logging.sh"
      run_logged() {
        omarchy_skip_leaf "$1" && return 0
        printf "%s\n" "${1#"$OMARCHY_INSTALL"/}"
      }
      source "$OMARCHY_INSTALL/hardware/all.sh"
    '
}

list_hw_enumerated() {
  local bin_dir=$1
  PATH="$bin_dir:$ROOT/bin:$PATH" OMARCHY_INSTALL="$ROOT/install" \
    bash -c 'run_logged() { printf "%s\n" "${1#"$OMARCHY_INSTALL"/}"; }; source "$OMARCHY_INSTALL/hardware/all.sh"'
}

hw_x86=$(list_hw_executed "$hw_x86_bin")
hw_arm=$(list_hw_executed "$hw_arm_bin")
hw_enum=$(list_hw_enumerated "$hw_x86_bin")

[[ $hw_arm == "$hw_enum" ]] || fail "aarch64 execution and image enumeration must match the full ordered hardware leaf list"
! grep -qx 'hardware/qualcomm/firmware.sh' <<<"$hw_x86" || fail "x86 execution must skip Qualcomm leaves"
! grep -qx 'hardware/gb10/sleep.sh' <<<"$hw_x86" || fail "x86 execution must skip GB10 leaves"
! grep -qx 'hardware/n1x.sh' <<<"$hw_x86" || fail "x86 execution must skip N1x leaf"
grep -qx 'hardware/nvidia.sh' <<<"$hw_x86" || fail "x86 execution must keep mixed nvidia.sh leaf"
grep -qx 'hardware/fix-fkeys.sh' <<<"$hw_x86" || fail "x86 execution must keep fix-fkeys.sh"
grep -qx 'hardware/apple/fix-brcmfmac-supplicant.sh' <<<"$hw_x86" || fail "x86 execution must keep mixed Apple Broadcom leaf"
grep -qx 'hardware/qualcomm/firmware.sh' <<<"$hw_enum" || fail "image enumeration on x86 must include ARM leaves"
pass "run_logged skips strictly ARM-only leaves on x86 while preserving full image enumeration"

# install/hardware/network.sh batches systemctl disable and falls back per-unit on error.
# Copy the script with /etc/systemd/network pointed at test_tmp so host files are never touched.
net_bin="$test_tmp/net-bin"
net_dir="$test_tmp/etc/systemd/network"
net_script="$test_tmp/network-test-copy.sh"
mkdir -p "$net_bin" "$net_dir"
sed "s|/etc/systemd/network|$net_dir|g" "$ROOT/install/hardware/network.sh" >"$net_script"
cat >"$net_bin/systemctl" <<'EOF'
#!/bin/bash
printf '%s\n' "$*" >>"$TEST_TMP/net-systemctl"
if [[ $1 == "disable" && ${TEST_BATCH_FAIL:-0} == "1" ]] && (( $# > 2 )); then
  exit 1
fi
exit 0
EOF
chmod +x "$net_bin/systemctl"

rm -f "$test_tmp/net-systemctl"
PATH="$net_bin:$PATH" TEST_TMP="$test_tmp" bash -eE "$net_script"
grep -qx 'disable iwd.service systemd-networkd.service systemd-networkd.socket systemd-networkd-varlink.socket systemd-networkd-varlink-metrics.socket systemd-networkd-resolve-hook.socket systemd-networkd-wait-online.service' "$test_tmp/net-systemctl" ||
  fail "network.sh batches all 7 systemctl disable units into one call" "$(cat "$test_tmp/net-systemctl")"
grep -qx 'mask systemd-networkd-wait-online.service' "$test_tmp/net-systemctl" ||
  fail "network.sh keeps wait-online mask separate"

rm -f "$test_tmp/net-systemctl"
PATH="$net_bin:$PATH" TEST_TMP="$test_tmp" TEST_BATCH_FAIL=1 bash -eE "$net_script"
(( $(grep -c '^disable ' "$test_tmp/net-systemctl") == 8 )) ||
  fail "network.sh falls back to per-unit disable when batch disable fails" "$(cat "$test_tmp/net-systemctl")"
pass "network.sh batches systemctl disable with per-unit fallback"
