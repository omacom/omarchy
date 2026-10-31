#!/bin/bash

set -euo pipefail
source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"
lab_vm="$ROOT/bin/omarchy-lab-vm"
resize_helper="$ROOT/default/lab-vm/display-resize"

tmpdir=$(mktemp -d)
export HOME="$tmpdir/home"
mkdir -p "$HOME"
trap 'rm -rf "$tmpdir"' EXIT

(
  # shellcheck disable=SC1090
  source "$lab_vm"
  run_virsh() {
    printf '%s\n' "$NAME"
    seq 1 100000
  }
  have_domain && domain_running
) || fail "domain probes consume all virsh output without a pipefail race"
pass "domain probes do not race virsh output"

# shellcheck disable=SC1090
source "$lab_vm"

[[ $(lab_resource_plan 123 32) == "4 8 8 16 16 32 24 92" ]] ||
  fail "large hosts keep workload-based profiles and custom headroom"
[[ $(lab_resource_plan 31 16) == "4 8 8 16 12 20 12 20" ]] ||
  fail "ordinary hosts cap high profiles to retained host capacity"
[[ $(lab_resource_plan 7 4) == "3 4 3 4 3 4 3 4" ]] ||
  fail "small hosts keep a viable bounded Lab allocation"
if rg -q '^RAM_DEFAULT=\|^CORES_DEFAULT=' "$lab_vm"; then
  fail "Lab installer defaults must derive from host hardware"
fi
rg -q 'safe limit:' "$lab_vm" || fail "Lab installer explains its host-safe limits"
pass "Lab installer derives resource recommendations from host hardware"

for ratio in 16:9 16:10 3:2 4:3 21:9 32:9; do
  valid_aspect_ratio "$ratio" || fail "common aspect ratio is accepted" "$ratio"
done
if valid_aspect_ratio 5:4; then
  fail "unsupported aspect ratios are rejected"
fi
omarchy-menu-select() { printf '16:10\tProductivity\n'; }
[[ $(pick_aspect_ratio) == "16:10" ]] || fail "aspect picker returns the selected ratio without its description"
unset -f omarchy-menu-select

read -r guest_width guest_height outer_width outer_height < <(
  aspect_window_size 16:9 2460 883 0 47 5040 1334
)
[[ $guest_width == 2288 && $guest_height == 1287 && $outer_width == 2288 && $outer_height == 1334 ]] ||
  fail "16:9 is exact and fits beneath host chrome" "$guest_width $guest_height $outer_width $outer_height"

read -r guest_width guest_height outer_width outer_height < <(
  aspect_window_size 21:9 1920 1080 0 47 5000 2000
)
[[ $guest_width == 4557 && $guest_height == 1953 && $outer_width == 4557 && $outer_height == 2000 ]] ||
  fail "aspect resizing maximizes the viewer within the host monitor" "$guest_width $guest_height $outer_width $outer_height"

read -r guest_width guest_height outer_width outer_height < <(
  aspect_window_size 16:10 1009 1074 0 48 3840 1334 125
)
[[ $guest_width == 1632 && $guest_height == 1020 && $outer_width == 2040 && $outer_height == 1323 ]] ||
  fail "aspect sizing accounts for viewer zoom" "$guest_width $guest_height $outer_width $outer_height"
pass "common aspect ratios preserve exact guest dimensions and maximize the host monitor"

aspect_calls="$tmpdir/aspect-calls"
have_domain() { return 0; }
domain_running() { return 0; }
ensure_viewer() { :; }
wait_ssh() { :; }
ensure_guest_display_resize() { :; }
wait_viewer_geometry() { printf '%s\n' '0xabc 2460 930 1 false 2460 883 0 47'; }
viewer_monitor_available_geometry() { printf '%s\n' '40 66 5040 1334'; }
wait_guest_display_update() { printf '%s\n' '2288 1287'; }
hypr_dispatch() { printf '%s\n' "$*" >>"$aspect_calls"; }

resize_viewer_aspect 16:9 >/dev/null
rg -q 'float.*address:0xabc' "$aspect_calls" || fail "aspect control floats a tiled viewer"
rg -q 'move.*x = 40, y = 66' "$aspect_calls" || fail "aspect control makes room before enlarging the viewer"
rg -q 'resize.*x = 2288, y = 1334' "$aspect_calls" || fail "aspect control resizes the viewer around exact guest dimensions"
rg -q 'center.*address:0xabc' "$aspect_calls" || fail "aspect control centers the resized viewer"
pass "aspect control floats, resizes, and centers the live viewer"

resize_home="$tmpdir/resize-home"
resize_drm="$tmpdir/drm"
resize_bin="$tmpdir/resize-bin"
resize_calls="$tmpdir/resize-calls"
resize_monitors="$resize_home/.config/hypr/monitors.lua"
mkdir -p "$resize_home/.config/hypr" "$resize_drm/card1-Virtual-1" "$resize_bin"
printf '%s\n' 'hl.monitor({ output = "", mode = "preferred", position = "auto", scale = "auto" })' >"$resize_monitors"
printf '%s\n' connected >"$resize_drm/card1-Virtual-1/status"
printf '%s\n' 1440x900 >"$resize_drm/card1-Virtual-1/modes"

cat >"$resize_bin/hyprctl" <<'SH'
#!/bin/bash
if [[ $1 == "monitors" && ${2:-} == "-j" ]]; then
  printf '%s\n' '[{"name":"Virtual-1","width":1280,"height":800}]'
else
  printf '%s\n' "$*" >>"$RESIZE_CALLS"
fi
SH
cat >"$resize_bin/wtype" <<'SH'
#!/bin/bash
printf 'wtype %s\n' "$*" >>"$RESIZE_CALLS"
SH
chmod +x "$resize_bin/hyprctl" "$resize_bin/wtype"

PATH="$resize_bin:$PATH" \
  HOME="$resize_home" \
  HYPRLAND_INSTANCE_SIGNATURE=test \
  OMARCHY_LAB_DRM_ROOT="$resize_drm" \
  OMARCHY_LAB_MONITORS_LUA="$resize_monitors" \
  RESIZE_CALLS="$resize_calls" \
  "$resize_helper" --once

rg -q 'output = "Virtual-1", mode = "1440x900"' "$resize_monitors" ||
  fail "display-resize writes the virtio-gpu mode to monitors.lua"
[[ $(rg -c '^-- BEGIN OMARCHY-LAB-SPICE$' "$resize_monitors") == 1 ]] ||
  fail "display-resize writes one managed monitor block"
rg -qx reload "$resize_calls" || fail "display-resize reloads Hyprland"
rg -q 'force_renderer_reload' "$resize_calls" || fail "display-resize refreshes the SPICE scanout"
rg -q 'wtype -M shift -m shift' "$resize_calls" || fail "display-resize wakes the guest display"

printf '%s\n' 1600x950 >"$resize_drm/card1-Virtual-1/modes"
PATH="$resize_bin:$PATH" \
  HOME="$resize_home" \
  HYPRLAND_INSTANCE_SIGNATURE=test \
  OMARCHY_LAB_DRM_ROOT="$resize_drm" \
  OMARCHY_LAB_MONITORS_LUA="$resize_monitors" \
  RESIZE_CALLS="$resize_calls" \
  "$resize_helper" --once

rg -q 'output = "Virtual-1", mode = "1600x950"' "$resize_monitors" ||
  fail "display-resize replaces the managed mode"
[[ $(rg -c '^-- BEGIN OMARCHY-LAB-SPICE$' "$resize_monitors") == 1 ]] ||
  fail "display-resize stays idempotent across repeated resizes"
[[ $(tail -n 5 "$resize_monitors" | rg -c '^$') == 1 ]] ||
  fail "display-resize does not accumulate blank lines"
pass "display-resize applies changing virtio modes idempotently"

bytes=$(disk_bytes_from_spec 80G)
[[ $bytes == 85899345920 ]] || fail "80G is 80 GiB in bytes" "$bytes"
read -r boot_start boot_size main_start main_size <<<"$(disk_layout "$bytes")"
[[ $boot_start == 1048576 && $boot_size == 2147483648 && $main_start == 2148532224 && $main_size == 83749765120 ]] ||
  fail "full-disk partition layout matches the ISO configurator" "$boot_start $boot_size $main_start $main_size"
pass "full-disk partition layout matches the ISO configurator"

hash=$(printf '%s' lab | openssl passwd -6 -stdin)
write_cidata_files "$tmpdir/cidata" lab "$hash" omarchy-lab UTC us "$bytes" "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI lab@host"

jq -e '.omarchy_install.mode == "full_disk"' "$tmpdir/cidata/user_configuration.json" >/dev/null ||
  fail "cidata is a full-disk install"
jq -e '.omarchy_install.defer_provisioning == false' "$tmpdir/cidata/user_configuration.json" >/dev/null ||
  fail "cidata is not deferred provisioning"
jq -e '.disk_config.device_modifications[0].device == "/dev/vda"' "$tmpdir/cidata/user_configuration.json" >/dev/null ||
  fail "cidata targets the virtio disk"
jq -e 'has("disk_encryption") | not' "$tmpdir/cidata/user_configuration.json" >/dev/null &&
  jq -e '.disk_config | has("disk_encryption") | not' "$tmpdir/cidata/user_configuration.json" >/dev/null ||
  fail "cidata does not request LUKS"
jq -e '.custom_commands[] | select(test("NOPASSWD"))' "$tmpdir/cidata/user_configuration.json" >/dev/null ||
  fail "cidata enables passwordless sudo"
jq -e '.custom_commands[] | select(test("Autologin"))' "$tmpdir/cidata/user_configuration.json" >/dev/null ||
  fail "cidata enables SDDM autologin"
jq -e '.custom_commands[] | select(test("omarchy_resume"))' "$tmpdir/cidata/user_configuration.json" >/dev/null ||
  fail "cidata strips hibernation resume on unencrypted /dev/vda2"
[[ $(<"$tmpdir/cidata/user_encrypt_installation.txt") == false ]] ||
  fail "cidata encryption flag is false"
grep -qx 'ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAI lab@host' "$tmpdir/cidata/authorized_keys" ||
  fail "cidata carries the lab SSH key"
jq -e --arg hash "$hash" '.users[0].username == "lab" and .users[0].sudo == true and .users[0].enc_password == $hash' \
  "$tmpdir/cidata/user_credentials.json" >/dev/null ||
  fail "cidata credentials match the lab user"
pass "cidata is an unencrypted autologin lab install"

wan=$(ufw_rule_specs wlp9s0)
printf '%s\n' "$wan" | rg -q "to any port 67" || fail "UFW specs allow DHCP to any"
printf '%s\n' "$wan" | rg -q "out on wlp9s0" || fail "UFW specs forward only to the uplink"
if printf '%s\n' "$wan" | rg -q '^allow in on virbr0$'; then
  fail "UFW specs must not allow every port on virbr0"
fi
pass "UFW specs stay scoped to DHCP, DNS, and NAT"

url=$(iso_url 4.0.2)
[[ $url == "https://iso.omarchy.org/omarchy-4.0.2.iso" ]] || fail "ISO URL is versioned on iso.omarchy.org" "$url"
pass "ISO URL is versioned on iso.omarchy.org"

args=$(virt_install_args 16384 8 /var/lib/libvirt/images/omarchy-4.0.2.iso /var/lib/libvirt/images/omarchy-lab.base.qcow2 /var/lib/libvirt/images/omarchy-lab.cidata.iso | tr '\0' '\n')
printf '%s\n' "$args" | rg -qx -- '--connect' || fail "virt-install pins qemu:///system"
printf '%s\n' "$args" | rg -q 'qemu:///system' || fail "virt-install uses the system URI"
printf '%s\n' "$args" | rg -q 'OVMF_CODE.4m.fd' || fail "virt-install boots OVMF"
if printf '%s\n' "$args" | rg -q "$HOME/"; then
  fail "virt-install must not point at files under HOME"
fi
pass "virt-install args stay in the libvirt image pool"

block=$(ssh_config_block lab)
printf '%s\n' "$block" | rg -q '^Host omarchy-lab$' || fail "SSH config defines Host omarchy-lab"
printf '%s\n' "$block" | rg -q 'omarchy-lab-vm ip' || fail "SSH config looks up the current lease"
printf '%s\n' "$block" | rg -q 'StrictHostKeyChecking no' || fail "SSH config allows rotating guest host keys"
printf '%s\n' "$block" | rg -q 'UserKnownHostsFile /dev/null' || fail "SSH config does not persist rotating guest host keys"
pass "SSH config uses a ProxyCommand against the current lease"

mkdir -p "$HOME/.ssh"
cat >"$HOME/.ssh/config" <<'EOF'
Host omarchy-lab
  HostName 192.168.122.202
  User lab
  IdentityFile ~/.ssh/omarchy-lab

# BEGIN OMARCHY-LAB-VM
Host omarchy-lab
  User lab
# END OMARCHY-LAB-VM
EOF
write_ssh_config lab
host_count=$(grep -c '^Host omarchy-lab$' "$HOME/.ssh/config" || true)
((host_count == 1)) || fail "write_ssh_config leaves a single Host omarchy-lab" "count=$host_count"
grep -q '192.168.122.202' "$HOME/.ssh/config" && fail "write_ssh_config drops the leftover HostName"
pass "write_ssh_config replaces leftover Host omarchy-lab stanzas"

touch "$HOME/.ssh/omarchy-lab" "$HOME/.ssh/omarchy-lab.pub" "$HOME/.ssh/omarchy-lab.known_hosts"
remove_ssh_artifacts
[[ ! -f $HOME/.ssh/omarchy-lab && ! -f $HOME/.ssh/omarchy-lab.pub && ! -f $HOME/.ssh/omarchy-lab.known_hosts ]] ||
  fail "remove deletes the lab key pair and known_hosts"
grep -q '^Host omarchy-lab$' "$HOME/.ssh/config" && fail "remove deletes Host omarchy-lab"
pass "remove wipes lab SSH keys and config"
