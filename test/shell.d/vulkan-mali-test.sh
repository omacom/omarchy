#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp=$(mktemp -d)
trap 'rm -rf "$tmp"' EXIT

mkdir -p "$tmp/bin"
cat >"$tmp/bin/omarchy-hw-pci" <<'SH'
#!/bin/bash
exit 1
SH
cat >"$tmp/bin/omarchy-hw-aarch64-qualcomm" <<'SH'
#!/bin/bash
exit 1
SH
cat >"$tmp/bin/omarchy-hw-aarch64" <<'SH'
#!/bin/bash
[[ ${FAKE_ARCH:-aarch64} == "aarch64" ]]
SH
cat >"$tmp/bin/omarchy-pkg-add" <<'SH'
#!/bin/bash
printf '%s\n' "$*"
SH
chmod +x "$tmp/bin"/*

run_vulkan() {
  PATH="$tmp/bin:$PATH" OMARCHY_DRM_DEVICES="$tmp/drm" OMARCHY_ACPI_DEVICES="$tmp/acpi" \
    bash -e -c 'source "$1"' bash "$ROOT/install/hardware/vulkan.sh"
}

reset_sysfs() {
  rm -rf "$tmp/drm" "$tmp/acpi"
  mkdir -p "$tmp/drm" "$tmp/acpi"
}

# Bound panthor DRM node selects vulkan-panfrost; display-only linlondp does not.
reset_sysfs
mkdir -p "$tmp/drm/card0/device" "$tmp/drivers/linlondp"
ln -s "$tmp/drivers/linlondp" "$tmp/drm/card0/device/driver"
[[ -z $(run_vulkan) ]] || fail "display-only DRM driver does not install vulkan-panfrost"

mkdir -p "$tmp/drm/renderD128/device" "$tmp/drivers/panthor"
ln -s "$tmp/drivers/panthor" "$tmp/drm/renderD128/device/driver"
[[ $(run_vulkan) == "vulkan-panfrost" ]] || fail "panthor DRM driver installs vulkan-panfrost"
[[ -z $(FAKE_ARCH=x86_64 run_vulkan) ]] || fail "x86_64 ignores ARM Mali detection"
pass "Mali DRM driver detection selects vulkan-panfrost only on aarch64"

# ACPI CIXH5000 selects vulkan-panfrost before panthor binds, unless _STA marks it disabled.
reset_sysfs
mkdir -p "$tmp/acpi/CIXH5000:00"
printf '0\n' >"$tmp/acpi/CIXH5000:00/status"
[[ -z $(run_vulkan) ]] || fail "disabled ACPI CIXH5000 GPU is ignored"

printf '15\n' >"$tmp/acpi/CIXH5000:00/status"
[[ $(run_vulkan) == "vulkan-panfrost" ]] || fail "enabled ACPI CIXH5000 GPU installs vulkan-panfrost"
pass "ACPI CIXH5000 status gating selects vulkan-panfrost only when present and enabled"
