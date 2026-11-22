#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT
export OMARCHY_PCI_DEVICES_PATH="$tmp_dir/pci" OMARCHY_MEMINFO="$tmp_dir/meminfo"
export OMARCHY_AMD_GPU_MEMORY_CONF="$tmp_dir/limine-entry-tool.d/amd-gpu-memory.conf"
page_kib=$(( $(getconf PAGESIZE) / 1024 ))

# fwupdmgr, keeping the BIOS settings in a JSON file and refusing a value
# the firmware doesn't list, as fwupd does. fwupdtool, used where systemd
# isn't running (the installer's chroot), records each call.
export FWUPD_SETTINGS="$tmp_dir/bios-settings.json"
mkdir -p "$tmp_dir/bin"
cat > "$tmp_dir/bin/fwupdmgr" <<'STUB'
#!/bin/bash
[[ $1 == "--no-reboot-check" ]] && shift
if [[ $1 == "get-bios-settings" ]]; then
  cat "$FWUPD_SETTINGS"
elif [[ $1 == "set-bios-setting" ]]; then
  jq -e --arg id "$2" --arg value "$3" '.BiosSettings[] | select(.BiosSettingId == $id) | .BiosSettingPossibleValues | index($value)' "$FWUPD_SETTINGS" >/dev/null || exit 1
  jq --arg id "$2" --arg value "$3" '(.BiosSettings[] | select(.BiosSettingId == $id)).BiosSettingCurrentValue = $value' "$FWUPD_SETTINGS" > "$FWUPD_SETTINGS.new"
  mv "$FWUPD_SETTINGS.new" "$FWUPD_SETTINGS"
fi
STUB
printf '#!/bin/bash\necho "$*" >> "$FWUPD_SETTINGS.tool"\nexec fwupdmgr "$@"\n' > "$tmp_dir/bin/fwupdtool"
chmod +x "$tmp_dir/bin/fwupdmgr" "$tmp_dir/bin/fwupdtool"
export OMARCHY_SYSTEMD_RUN="$tmp_dir/run-systemd"
mkdir -p "$OMARCHY_SYSTEMD_RUN"
echo '{"BiosSettings": []}' > "$FWUPD_SETTINGS"
export PATH="$tmp_dir/bin:$PATH"

gpu() { mkdir -p "$OMARCHY_PCI_DEVICES_PATH/$1"; echo "$2" > "$OMARCHY_PCI_DEVICES_PATH/$1/vendor"; echo "$3" > "$OMARCHY_PCI_DEVICES_PATH/$1/class"; }
setting() { jq -r --arg id "$1" '.BiosSettings[] | select(.BiosSettingId == $id) | .BiosSettingCurrentValue' "$FWUPD_SETTINGS"; }
vram_gib() { echo $(( $2 * 1024 * 1024 * 1024 )) > "$OMARCHY_PCI_DEVICES_PATH/$1/mem_info_vram_total"; }
ram_gib() { echo "MemTotal:       $(( $1 * 1024 * 1024 )) kB" > "$OMARCHY_MEMINFO"; }
apply() { "$ROOT/bin/omarchy-apply-amd-gpu-memory" >/dev/null; }

ram_gib 64
gpu 0000:00:02.0 0x8086 0x030000
gpu 0000:c3:00.1 0x1002 0x040300
apply
[[ ! -e $OMARCHY_AMD_GPU_MEMORY_CONF ]] || fail "a machine without an AMD GPU is left alone"
pass "a machine without an AMD GPU, even with AMD audio, is left alone"

gpu 0000:c3:00.0 0x1002 0x038000
ram_gib 16
apply
[[ ! -e $OMARCHY_AMD_GPU_MEMORY_CONF ]] || fail "16 GB keeps the kernel's half, which is as high"
pass "16 GB keeps the kernel's half, which is as high"

ram_gib 64
apply
grep -Fxq "KERNEL_CMDLINE[default]+=\" ttm.pages_limit=$(( 56 * 1024 * 1024 / page_kib ))\"" "$OMARCHY_AMD_GPU_MEMORY_CONF" ||
  fail "a 64 GB AMD machine lets the GPU map 56 GiB" "$(cat "$OMARCHY_AMD_GPU_MEMORY_CONF")"
pass "a 64 GB AMD machine lets the GPU map 56 GiB"

# A 64 GB APU whose firmware carves out 32 GB of VRAM boots with 32 GB. HP's
# own setting and amdgpu's both offer the carveout, and a discrete AMD GPU,
# with VRAM chips of its own, sorts after the APU.
gpu 0000:e3:00.0 0x1002 0x030000
vram_gib 0000:e3:00.0 16
echo Samsung > "$OMARCHY_PCI_DEVICES_PATH/0000:e3:00.0/mem_info_vram_vendor"
vram_gib 0000:c3:00.0 32
cat > "$FWUPD_SETTINGS" <<'JSON'
{"BiosSettings": [
  {"BiosSettingId": "com.amd-gpu.uma_carveout", "AppstreamId": "org.fwupd.bios.video-memory", "BiosSettingReadOnly": false,
   "BiosSettingCurrentValue": "(32 GB)", "BiosSettingPossibleValues": ["(512 MB)", "(1 GB)", "(16 GB)", "(32 GB)"]},
  {"BiosSettingId": "com.hp-bioscfg.Dedicated_Graphics_Memory", "AppstreamId": "org.fwupd.bios.video-memory", "BiosSettingReadOnly": false,
   "BiosSettingCurrentValue": "32 GB", "BiosSettingPossibleValues": ["16 GB", "32 GB", "512 MB", "1 GB"]}
]}
JSON
ram_gib 32
apply
[[ $(setting com.hp-bioscfg.Dedicated_Graphics_Memory) == "512 MB" ]] ||
  fail "a 32 GB carveout shrinks to the smallest size, through HP's own setting" "$(cat "$FWUPD_SETTINGS")"
[[ $(setting com.amd-gpu.uma_carveout) == "(32 GB)" ]] || fail "amdgpu's setting is left to HP's" "$(cat "$FWUPD_SETTINGS")"
pass "a 32 GB carveout shrinks to the smallest size, through HP's own setting"
cap_63_5="KERNEL_CMDLINE[default]+=\" ttm.pages_limit=$(( (63 * 1024 + 512) * 1024 / page_kib - 8 * 1024 * 1024 / page_kib ))\""
grep -Fxq "$cap_63_5" "$OMARCHY_AMD_GPU_MEMORY_CONF" ||
  fail "the cap is sized for the 63.5 GiB the next boot sees" "$(cat "$OMARCHY_AMD_GPU_MEMORY_CONF")"
pass "the cap is sized for the 63.5 GiB the next boot sees"

# Run again before the reboot: the setting reads back as the smallest, but
# this boot's VRAM still says 32 GB, so the cap stays the same.
apply
grep -Fxq "$cap_63_5" "$OMARCHY_AMD_GPU_MEMORY_CONF" ||
  fail "a second run before the reboot keeps the cap" "$(cat "$OMARCHY_AMD_GPU_MEMORY_CONF")"
pass "a second run before the reboot keeps the cap"

# Without HP's setting, amdgpu's is written in its own "(512 MB)" form.
jq '.BiosSettings |= map(select(.BiosSettingId == "com.amd-gpu.uma_carveout"))' "$FWUPD_SETTINGS" > "$FWUPD_SETTINGS.new"
mv "$FWUPD_SETTINGS.new" "$FWUPD_SETTINGS"
apply
[[ $(setting com.amd-gpu.uma_carveout) == "(512 MB)" ]] || fail "amdgpu's setting shrinks without a vendor one" "$(cat "$FWUPD_SETTINGS")"
pass "amdgpu's setting shrinks without a vendor one"

# The picker's list: this boot's VRAM, the next boot's, then every size.
[[ $("$ROOT/bin/omarchy-apply-amd-gpu-memory" --options | tr '\n' ',') == "32 GB,512 MB,512 MB,1 GB,16 GB,32 GB," ]] ||
  fail "--options lists the VRAM now, from the next boot, and every size" "$("$ROOT/bin/omarchy-apply-amd-gpu-memory" --options)"
pass "--options lists the VRAM now, from the next boot, and every size"

# A user picks 16 GB of VRAM on a 32 GB APU booted at 512 MB: the next boot
# sees 16 GB, where the kernel's half is as high, so the cap goes.
echo $(( 512 * 1024 * 1024 )) > "$OMARCHY_PCI_DEVICES_PATH/0000:c3:00.0/mem_info_vram_total"
echo "MemTotal:       $(( (31 * 1024 + 512) * 1024 )) kB" > "$OMARCHY_MEMINFO"
apply
[[ -e $OMARCHY_AMD_GPU_MEMORY_CONF ]] || fail "a 32 GB APU at 512 MB of VRAM gets a cap"
"$ROOT/bin/omarchy-apply-amd-gpu-memory" "16 GB" >/dev/null
[[ $(setting com.amd-gpu.uma_carveout) == "(16 GB)" ]] || fail "a picked size is set" "$(cat "$FWUPD_SETTINGS")"
[[ ! -e $OMARCHY_AMD_GPU_MEMORY_CONF ]] || fail "a 16 GB carveout on 32 GB drops the cap" "$(cat "$OMARCHY_AMD_GPU_MEMORY_CONF")"
pass "a picked 16 GB carveout on 32 GB is set and drops the cap"

if "$ROOT/bin/omarchy-apply-amd-gpu-memory" "6 GB" >/dev/null 2>&1; then
  fail "a size the firmware doesn't offer is refused"
fi
[[ $(setting com.amd-gpu.uma_carveout) == "(16 GB)" ]] || fail "a refused size leaves the carveout alone"
pass "a size the firmware doesn't offer is refused"

# The installer's chroot runs no systemd, so fwupd's plugins run in fwupdtool.
rmdir "$OMARCHY_SYSTEMD_RUN"
"$ROOT/bin/omarchy-apply-amd-gpu-memory" "1 GB" >/dev/null
[[ $(setting com.amd-gpu.uma_carveout) == "(1 GB)" && -s $FWUPD_SETTINGS.tool ]] ||
  fail "without systemd, the carveout is set through fwupdtool" "$(cat "$FWUPD_SETTINGS")"
pass "without systemd, the carveout is set through fwupdtool"
