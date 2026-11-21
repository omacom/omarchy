#!/bin/bash
set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT
mkdir -p "$test_tmp/bin"
export NVIDIA_SETUP_LOG="$test_tmp/actions" NVIDIA_SETUP_CONFIG="$test_tmp/config"
cat >"$test_tmp/bin/sudo" <<'STUB'
#!/bin/bash
printf '%s\n' "$*" >>"$NVIDIA_SETUP_LOG"
case $1 in
  install) cp "$3" "$NVIDIA_SETUP_CONFIG" ;;
  systemctl) [[ ${NVIDIA_SETUP_FAIL:-} != services ]] ;;
  limine-mkinitcpio) [[ ${NVIDIA_SETUP_FAIL:-} != boot ]] ;;
  *) exit 1 ;;
esac
STUB
cat >"$test_tmp/bin/omarchy-hw-x86" <<'STUB'
#!/bin/bash
[[ ${NVIDIA_SETUP_PLATFORM:-x86} == x86 ]]
STUB
cat >"$test_tmp/bin/omarchy-hw-nvidia" <<'STUB'
#!/bin/bash
[[ ${NVIDIA_SETUP_GPU:-nvidia} == nvidia ]]
STUB
cat >"$test_tmp/bin/modinfo" <<'STUB'
#!/bin/bash
[[ ${NVIDIA_SETUP_DRIVER:-supported} == supported ]] && echo 'NVreg_UseKernelSuspendNotifiers:int'
STUB
chmod +x "$test_tmp/bin/"*
export PATH="$test_tmp/bin:$PATH"
setup="$ROOT/bin/omarchy-setup-nvidia-suspend"
for scenario in platform gpu driver args; do
  : >"$NVIDIA_SETUP_LOG"
  case $scenario in
    platform) env NVIDIA_SETUP_PLATFORM=arm "$setup" >"$test_tmp/out" 2>&1 && fail "unsupported platform accepted" ;;
    gpu) env NVIDIA_SETUP_GPU=amd "$setup" >"$test_tmp/out" 2>&1 && fail "non-NVIDIA machine accepted" ;;
    driver) env NVIDIA_SETUP_DRIVER=old "$setup" >"$test_tmp/out" 2>&1 && fail "unsupported driver accepted" ;;
    args) "$setup" unknown >"$test_tmp/out" 2>&1 && fail "unknown argument accepted" ;;
  esac
  [[ ! -s $NVIDIA_SETUP_LOG ]] || fail "unsupported setup performed privileged changes"
done
pass "NVIDIA sleep setup rejects unsupported hardware, drivers and arguments before mutation"
"$setup" >"$test_tmp/out" 2>&1
[[ $(wc -l <"$NVIDIA_SETUP_LOG") == 3 ]] || fail "setup did not perform all three configuration phases"
sed -n '2p' "$NVIDIA_SETUP_LOG" | grep -Fx 'systemctl enable nvidia-suspend.service nvidia-resume.service nvidia-hibernate.service' || fail "setup must enable, never start, GPU sleep services"
[[ $(tail -1 "$NVIDIA_SETUP_LOG") == limine-mkinitcpio ]] || fail "setup rebuilds installed UKIs after configuring sleep"
grep -q 'Reboot before testing' "$test_tmp/out" || fail "setup must explain activation requires a reboot"
pass "NVIDIA sleep setup configures services and rebuilds boot images without suspending the GPU"
for phase in services boot; do
  if env NVIDIA_SETUP_FAIL="$phase" "$setup" >"$test_tmp/out" 2>&1; then
    fail "failed $phase phase reported success"
  fi
  ! grep -q 'Reboot before testing' "$test_tmp/out" || fail "partial setup claimed completion"
done
pass "NVIDIA sleep setup reports service and boot rebuild failures"
