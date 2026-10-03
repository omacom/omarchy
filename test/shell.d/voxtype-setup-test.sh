#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

# Mount private configuration directories instead of touching the live desktop
# or replacing HOME. Every external side effect below is a PATH fixture.
if [[ ${1:-} != "--isolated" ]]; then
  if ! command -v bwrap >/dev/null; then
    skip "bubblewrap unavailable; skipping isolated Voxtype setup tests"
    exit 0
  fi
  scratch=$(mktemp -d)
  trap 'rm -rf "$scratch"' EXIT
  bwrap --ro-bind / / --dev /dev --tmpfs "$HOME/.config" --tmpfs "$HOME/.local" \
    --bind "$scratch" "$scratch" -- /bin/bash "$0" --isolated "$scratch"
  exit
fi

scratch=$2
export OMARCHY_PATH="$ROOT"
export XDG_RUNTIME_DIR="$scratch/runtime"
export VOXTYPE_TEST_LOG="$scratch/calls"
mkdir -p "$scratch/bin" "$XDG_RUNTIME_DIR/voxtype"
export PATH="$scratch/bin:$ROOT/bin:$PATH"

cat >"$scratch/bin/mock" <<'MOCK'
#!/bin/bash
set -eu
name=${0##*/}
printf '%s %s\n' "$name" "$*" >>"$VOXTYPE_TEST_LOG"
case $name in
  gum|hyprctl|omarchy-restart-shell|omarchy-notification-send) ;;
  omarchy-hw-vulkan) exit "${NO_VULKAN:-0}" ;;
  omarchy-pkg-add)
    if [[ $* == "voxtype-cohere-vulkan" ]]; then exit "${PACKAGE_FAILURE:-0}"; fi
    ;;
  voxtype-cohere-vulkan)
    if [[ ${RECORD_DURING_PROBE:-0} == 1 ]]; then printf 'recording\n' >"$XDG_RUNTIME_DIR/voxtype/state"; fi
    exit "${PROBE_FAILURE:-0}"
    ;;
  sha256sum)
    read -r checksum filename
    [[ -f $filename && ${HASH_FAILURE:-0} == 0 ]]
    ;;
  curl)
    if [[ $* == *"/health"* ]]; then
      printf '%s\n' "${HEALTH:-null}"
    else
      while (( $# )); do
        if [[ $1 == "--output" ]]; then shift; printf 'test model\n' >"$1"; break; fi
        shift
      done
      exit "${DOWNLOAD_FAILURE:-0}"
    fi
    ;;
  systemctl)
    if [[ $* == *"is-active"* ]]; then exit 1; fi
    if [[ $* == *"restart voxtype-cohere-vulkan.service"* ]]; then exit "${SERVICE_FAILURE:-0}"; fi
    ;;
  voxtype)
    if [[ $* == *"daemon"* ]]; then
      printf 'api-key-present=%s\n' "${VOXTYPE_WHISPER_API_KEY:+yes}" >>"$VOXTYPE_TEST_LOG"
    fi
    ;;
esac
MOCK
chmod +x "$scratch/bin/mock"
for cmd in gum hyprctl omarchy-restart-shell omarchy-notification-send omarchy-hw-vulkan omarchy-pkg-add voxtype-cohere-vulkan sha256sum curl systemctl voxtype; do
  ln -s mock "$scratch/bin/$cmd"
done

config="$HOME/.config/voxtype/config.toml"
dropin="$HOME/.config/systemd/user/voxtype.service.d/40-omarchy-cohere.conf"
service="$HOME/.config/systemd/user/voxtype-cohere-vulkan.service"

reset_fixture() {
  rm -rf "$HOME/.config/voxtype" "$HOME/.config/systemd" "$HOME/.local/share/voxtype"
  : >"$VOXTYPE_TEST_LOG"
  printf 'idle\n' >"$XDG_RUNTIME_DIR/voxtype/state"
  unset NO_VULKAN PACKAGE_FAILURE PROBE_FAILURE DOWNLOAD_FAILURE HASH_FAILURE SERVICE_FAILURE RECORD_DURING_PROBE
}

reset_fixture
omarchy-voxtype-install >/dev/null
[[ -f $dropin && -f $service && -f ${config%/*}/omarchy-osd ]] || fail "fresh install enables proven Cohere and shell visuals"
rg -q '^mode = "paste"' "$config" || fail "fresh install defaults to paste"
pass "fresh install defaults to paste, shell visuals, and proven Cohere"

for reason in NO_VULKAN PACKAGE_FAILURE PROBE_FAILURE DOWNLOAD_FAILURE HASH_FAILURE SERVICE_FAILURE; do
  reset_fixture
  export "$reason=1"
  omarchy-voxtype-install >/dev/null 2>&1
  [[ ! -f $dropin ]] || fail "$reason leaves fallback selected"
  rg -q 'voxtype setup --download' "$VOXTYPE_TEST_LOG" || fail "$reason keeps fallback model available"
  rg -q 'voxtype setup systemd' "$VOXTYPE_TEST_LOG" || fail "$reason still installs daemon"
  pass "$reason retains configured Whisper fallback"
done

reset_fixture
mkdir -p "${config%/*}"
printf 'engine = "cohere"\n[output]\nmode = "type"\n' >"$config"
cp "$config" "$scratch/original.toml"
omarchy-voxtype-install >/dev/null
cmp "$config" "$scratch/original.toml" || fail "existing preferences preserved"
[[ ! -f $dropin && ! -f ${config%/*}/omarchy-osd ]] || fail "existing OSD and engine preserved"
pass "existing config, output, engine and OSD choices preserved"

reset_fixture
mkdir -p "${dropin%/*}"
printf 'previous drop-in\n' >"$dropin"
printf 'previous service\n' >"$service"
export SERVICE_FAILURE=1
if omarchy-voxtype-cohere enable >/dev/null 2>&1; then fail "failed service rejects activation"; fi
[[ $(<"$dropin") == "previous drop-in" && $(<"$service") == "previous service" ]] || fail "failed activation restores existing unit"
pass "failed activation preserves previous service and drop-in"

reset_fixture
printf 'recording\n' >"$XDG_RUNTIME_DIR/voxtype/state"
if omarchy-voxtype-cohere enable >/dev/null 2>&1; then fail "active recording rejects engine changes"; fi
[[ ! -s $VOXTYPE_TEST_LOG ]] || fail "recording check runs before external side effects"
pass "active recording rejects engine changes"

reset_fixture
export RECORD_DURING_PROBE=1
if omarchy-voxtype-cohere enable >/dev/null 2>&1; then fail "recording begun during setup rejects activation"; fi
[[ ! -f $dropin && ! -f $service ]] || fail "recording begun during setup leaves units untouched"
pass "recording begun during download or probe rejects activation"

reset_fixture
export VOXTYPE_WHISPER_API_KEY="test-placeholder"
export HEALTH='{"ready":true,"backend":"vulkan","model":"cohere-transcribe-vulkan"}'
omarchy-voxtype-daemon
rg -q -- '--remote-endpoint http://127.0.0.1:8178' "$VOXTYPE_TEST_LOG" || fail "ready Vulkan selects local endpoint"
rg -q '^api-key-present=$' "$VOXTYPE_TEST_LOG" || fail "local mode removes API key"
pass "ready Vulkan selects local endpoint without cloud credentials"

for health in '{}' '{"ready":true,"backend":"cpu","model":"cohere-transcribe-vulkan"}' '{"ready":true,"backend":"vulkan","model":"different"}'; do
  : >"$VOXTYPE_TEST_LOG"
  export HEALTH="$health"
  omarchy-voxtype-daemon 2>/dev/null
  rg -q '^voxtype daemon$' "$VOXTYPE_TEST_LOG" || fail "unready or wrong backend starts configured fallback"
done
pass "unready, CPU and wrong-model responses start configured fallback"
