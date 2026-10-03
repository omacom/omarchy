#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin"

# Packages are not installed and no file manager opens here; vulkaninfo reports
# whatever device the case asks for, or fails the way it does when no device
# enumerates.
printf '#!/bin/bash\nexit 0\n' >"$tmp/bin/omarchy-pkg-add"
printf '#!/bin/bash\nexit 0\n' >"$tmp/bin/nautilus"
cat >"$tmp/bin/vulkaninfo" <<'SH'
#!/bin/bash
[[ -n ${VULKAN_DEVICE_TYPE:-} ]] || exit 1
echo "GPU0:"
echo "	deviceType         = PHYSICAL_DEVICE_TYPE_$VULKAN_DEVICE_TYPE"
for ((line = 0; line < ${VULKAN_SUMMARY_TAIL:-0}; line++)); do
  echo "	driverInfo         = Mesa 26.2.2"
done
SH
chmod +x "$tmp/bin/"*

video_driver_for() {
  local home="$tmp/home-$1"

  mkdir -p "$home"
  HOME="$home" VULKAN_DEVICE_TYPE=$1 PATH="$tmp/bin:$PATH" \
    "$ROOT/bin/omarchy-install-gaming-retroarch" >/dev/null
  sed -n 's/^video_driver = "\(.*\)"$/\1/p' "$home/.config/retroarch/retroarch.cfg"
}

for type in INTEGRATED_GPU DISCRETE_GPU VIRTUAL_GPU; do
  [[ $(video_driver_for "$type") == "vulkan" ]] || fail "RetroArch uses Vulkan on a $type"
done
pass "RetroArch uses Vulkan when a GPU provides a Vulkan device"

# Lavapipe enumerates as a CPU device: RetroArch would start, but software
# Vulkan is far slower than the GPU's OpenGL.
[[ $(video_driver_for CPU) == "glcore" ]] || fail "RetroArch skips a CPU-only Vulkan device"
pass "RetroArch skips a CPU-only Vulkan device"

[[ $(video_driver_for "") == "glcore" ]] || fail "RetroArch falls back to glcore without a Vulkan device"
pass "RetroArch falls back to glcore without a Vulkan device"

# Existing installs: the migration moves a config the old installer left on
# Vulkan to glcore when no GPU enumerates, and touches nothing else.
migration=$(grep -rl "Switch RetroArch to the glcore video driver" "$ROOT/migrations" | head -n 1 || true)
[[ -n $migration ]] || fail "the RetroArch video driver migration exists"
printf '#!/bin/bash\necho "$*" >>"%s/pkg-add.log"\n' "$tmp" >"$tmp/bin/omarchy-pkg-add"

migrate() {
  local driver=$1 type=$2 home="$tmp/migrate-home"

  rm -rf "$home" "$tmp/pkg-add.log"
  if [[ -n $driver ]]; then
    mkdir -p "$home/.config/retroarch"
    printf 'menu_driver = "xmb"\nvideo_driver = "%s"\n' "$driver" >"$home/.config/retroarch/retroarch.cfg"
  fi
  HOME="$home" VULKAN_DEVICE_TYPE=$type PATH="$tmp/bin:$PATH" bash -euo pipefail "$migration" >/dev/null
  sed -n 's/^video_driver = "\(.*\)"$/\1/p' "$home/.config/retroarch/retroarch.cfg" 2>/dev/null || true
}

[[ $(migrate vulkan "") == "glcore" ]] || fail "the migration switches a Vulkan config to glcore without a GPU device"
grep -qx "vulkan-tools" "$tmp/pkg-add.log" || fail "the migration installs vulkan-tools for its device check"
pass "the migration switches a Vulkan config to glcore when no GPU provides Vulkan"

[[ $(migrate vulkan INTEGRATED_GPU) == "vulkan" ]] || fail "the migration keeps Vulkan on a GPU that provides it"
# A long summary after the device line: a grep that quits at the first match
# would leave vulkaninfo to die of SIGPIPE, which pipefail reads as no GPU.
[[ $(VULKAN_SUMMARY_TAIL=200000 migrate vulkan DISCRETE_GPU) == "vulkan" ]] ||
  fail "the migration keeps Vulkan when vulkaninfo prints more after the device"
pass "the migration keeps Vulkan on a GPU that provides it"

[[ $(migrate gl "") == "gl" && ! -e $tmp/pkg-add.log ]] || fail "the migration leaves a user's own driver alone"
[[ -z $(migrate "" "") && ! -e $tmp/pkg-add.log ]] || fail "the migration skips machines without RetroArch"
pass "the migration leaves other drivers and machines without RetroArch alone"
