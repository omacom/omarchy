#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

test_tmp=$(mktemp -d)
trap 'rm -rf "$test_tmp"' EXIT

stub_bin="$test_tmp/bin"
mkdir -p "$stub_bin"

# nmcli translates its state words, so it answers in German unless asked for C.
cat >"$stub_bin/nmcli" <<'SH'
#!/bin/bash
[[ -z ${NM_STATUS:-} ]] || exit "$NM_STATUS"
if [[ ${LC_ALL:-} != "C" ]]; then
  printf 'aktiviert:aktiviert\nwifi:verbunden\n'
elif [[ $* == *general ]]; then
  echo "${NM_RADIOS:-enabled:enabled}"
else
  printf 'ethernet:connected\n%b' "${NM_WIFI:-wifi:connected\n}"
fi
SH

# Units named in SHIPPED come from a package; anything else was made here. An
# instance's file is its template's, as systemd reports it.
cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash
case "$*" in
  "is-active --quiet bluetooth.service") exit 0 ;;
  list-units*) printf '%b' "${FAILED_UNITS:-}" ;;
  "show -p FragmentPath --value "*)
    unit=${!#}
    [[ $unit == *@* ]] && unit="${unit%%@*}@.${unit##*.}"
    if [[ " ${SHIPPED:-} " == *" $unit "* ]]; then
      echo "/usr/lib/systemd/system/$unit"
    else
      echo "/etc/systemd/system/$unit"
    fi
    ;;
esac
SH

cat >"$stub_bin/bluetoothctl" <<'SH'
#!/bin/bash
case $1 in
  list) printf 'Waiting to connect to bluetoothd...\nController AA:BB:CC:DD:EE:FF machine [default]\n' ;;
  show) echo "Powered: ${BT_POWERED:-yes}" ;;
esac
SH

# The host's own names must not decide what the report says.
cat >"$stub_bin/uname" <<'SH'
#!/bin/bash
if [[ $1 == "-n" ]]; then
  echo testhost.example.com
else
  echo 7.2.15-5-omarchy
fi
SH
cat >"$stub_bin/id" <<'SH'
#!/bin/bash
echo "${ID_USER:-tester}"
SH

cat >"$stub_bin/pactl" <<'SH'
#!/bin/bash
case "$*" in
  info) exit 0 ;;
  "list short sinks") printf '%b' "${PA_SINKS:-}" ;;
  "list short sources") printf '%b' "${PA_SOURCES:-}" ;;
  # The same nodes as JSON; a third column is the node's ALSA card.
  "-f json list sinks" | "-f json list sources")
    nodes=${PA_SINKS:-}
    [[ $* == *sources ]] && nodes=${PA_SOURCES:-}
    printf '%b' "$nodes" | jq -R 'split("\t") | {name: .[1], properties: {"alsa.card": (.[2] // "")}}' | jq -s .
    ;;
  "-f json list cards") printf '%s' "${PA_CARDS:-[]}" ;;
esac
SH

cat >"$stub_bin/omarchy-hw-software-rendering" <<'SH'
#!/bin/bash
echo "${RENDERER:-Mesa Intel(R) Graphics}"
exit "${RENDERING:-1}"
SH

cat >"$stub_bin/omarchy-hw-vm" <<'SH'
#!/bin/bash
[[ -n ${VM:-} ]]
SH

for name in omarchy-version omarchy-version-channel omarchy-hw-platform lscpu; do
  printf '#!/bin/bash\necho stub\n' >"$stub_bin/$name"
done
chmod +x "$stub_bin"/*

new_root() {
  fake=$(mktemp -d "$test_tmp/root.XXXXXX")
  mkdir -p "$fake/sys/class/net" "$fake/sys/class/rfkill" "$fake/sys/class/bluetooth" "$fake/sys/class/drm" \
    "$fake/sys/class/input" "$fake/sys/class/power_supply" "$fake/sys/class/dmi/id" "$fake/sys/bus/pci/devices" \
    "$fake/sys/bus/usb/devices" "$fake/proc/asound" "$fake/run/udev/data" "$fake/dev/dri"
  printf '3\n' >"$fake/sys/class/dmi/id/chassis_type"
  touch "$fake/dev/dri/card0"
}

# A PCI device: path, class, vendor:device, and the driver bound to it, if any.
pci() {
  local dir=$fake/sys/bus/pci/devices/$1
  mkdir -p "$dir"
  printf '%s\n' "$2" >"$dir/class"
  printf '0x%s\n' "${3%%:*}" >"$dir/vendor"
  printf '0x%s\n' "${3##*:}" >"$dir/device"
  [[ -z ${4:-} ]] || ln -s "/sys/bus/pci/drivers/$4" "$dir/driver"
}

# Sound card N registered under a PCI controller, as snd_hda_intel does.
sound_card() {
  mkdir -p "$fake/sys/bus/pci/devices/$1/sound/card$2" "$fake/sys/class/sound/card$2"
  ln -s "$fake/sys/bus/pci/devices/$1" "$fake/sys/class/sound/card$2/device"
}

make_laptop() {
  mkdir -p "$fake/proc/acpi/button/lid/LID0"
  printf 'state:      %s\n' "${1:-open}" >"$fake/proc/acpi/button/lid/LID0/state"
  printf '10\n' >"$fake/sys/class/dmi/id/chassis_type"
}

# A German session, so a dropped LC_ALL=C shows.
rollcall() {
  LC_ALL=de_DE.UTF-8 OMARCHY_ROLLCALL_ROOT=$fake PATH="$stub_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-rollcall" --json "$@" 2>/dev/null
}

# Prints "<result>: <detail>" for one check.
outcome() {
  rollcall "$@" | jq -r '.checks[0] | "\(.result): \(.detail)"'
}

expect() {
  local description=$1 expected=$2 actual=$3
  [[ $actual == $expected ]] || fail "$description" "expected: $expected"$'\n'"actual:   $actual"
  pass "$description"
}

# Wi-Fi
new_root
mkdir -p "$fake/sys/class/net/wlan0/wireless"
pci 0000:00:14.3 0x028000 8086:a840 iwlwifi
ln -s "$fake/sys/bus/pci/devices/0000:00:14.3" "$fake/sys/class/net/wlan0/device"

expect "Wi-Fi NetworkManager has connected passes, named by its driver" "pass: connected (iwlwifi)" "$(outcome wifi)"
expect "a Wi-Fi adapter on but not connected still works" "pass: on, not connected (iwlwifi)" "$(NM_WIFI='wifi:disconnected\n' outcome wifi)"
expect "a Wi-Fi adapter NetworkManager calls unavailable fails" "fail: NetworkManager reports the adapter unavailable (iwlwifi)" "$(NM_WIFI='wifi:unavailable\n' outcome wifi)"
expect "an unmanaged second interface does not hide an unavailable one" "fail: NetworkManager reports the adapter unavailable (iwlwifi)" \
  "$(NM_WIFI='wifi:unmanaged\nwifi:unavailable\n' outcome wifi)"
expect "Wi-Fi turned off in NetworkManager is skipped" "skip: turned off in NetworkManager" "$(NM_RADIOS=disabled:enabled NM_WIFI='wifi:unavailable\n' outcome wifi)"
expect "a NetworkManager that does not answer fails" "fail: NetworkManager did not answer (iwlwifi)" "$(NM_STATUS=124 outcome wifi)"
expect "no NetworkManager at all is skipped" "skip: NetworkManager is not running" "$(NM_STATUS=8 outcome wifi)"

mkdir -p "$fake/sys/class/rfkill/rfkill0"
printf 'wlan\n' >"$fake/sys/class/rfkill/rfkill0/type"
printf '1\n' >"$fake/sys/class/rfkill/rfkill0/soft"
printf '0\n' >"$fake/sys/class/rfkill/rfkill0/hard"
expect "Wi-Fi the user turned off is skipped, not failed" "skip: turned off" "$(NM_WIFI='wifi:unavailable\n' outcome wifi)"

new_root
make_laptop
expect "a laptop with no Wi-Fi at all fails" "fail: the laptop reports no Wi-Fi adapter" "$(outcome wifi)"
expect "a laptop with no Bluetooth at all fails" "fail: the laptop reports no Bluetooth controller" "$(outcome bluetooth)"
mkdir -p "$fake/sys/class/rfkill/rfkill0"
printf 'wlan\n' >"$fake/sys/class/rfkill/rfkill0/type"
printf '1\n' >"$fake/sys/class/rfkill/rfkill0/soft"
printf '1\n' >"$fake/sys/class/rfkill/rfkill0/hard"
expect "a hardware switch that keeps the interface from appearing is a skip" "skip: turned off by a hardware switch" "$(outcome wifi)"

new_root
pci 0000:00:14.3 0x028000 8086:a840
expect "a Wi-Fi card on the bus with no driver fails rather than skipping" "fail: Wi-Fi card 8086:a840 (no driver) has no wireless interface" "$(outcome wifi)"
new_root
pci 0000:01:00.0 0x028000 17cb:1107 ath12k_pci
expect "a bound Wi-Fi driver whose firmware never loaded fails" "fail: Wi-Fi card 17cb:1107 (ath12k_pci) has no wireless interface" "$(outcome wifi)"

# Bluetooth
new_root
mkdir -p "$fake/sys/class/bluetooth/hci0/device"
ln -s /sys/bus/usb/drivers/btusb "$fake/sys/class/bluetooth/hci0/device/driver"
expect "a powered Bluetooth controller passes, with no address in the report" "pass: powered (btusb)" "$(outcome bluetooth)"
expect "an unblocked controller that never powered up fails" "fail: a controller is not blocked but did not power up (btusb)" "$(BT_POWERED=no outcome bluetooth)"

mkdir -p "$fake/sys/class/rfkill/rfkill1"
printf 'bluetooth\n' >"$fake/sys/class/rfkill/rfkill1/type"
printf '1\n' >"$fake/sys/class/rfkill/rfkill1/soft"
expect "Bluetooth blocked the way omarchy-bluetooth-power turns it off is skipped" "skip: turned off" "$(BT_POWERED=no outcome bluetooth)"

new_root
mkdir -p "$fake/sys/bus/usb/devices/1-10" "$fake/sys/bus/usb/devices/1-10:1.0"
printf '8087\n' >"$fake/sys/bus/usb/devices/1-10/idVendor"
printf '0033\n' >"$fake/sys/bus/usb/devices/1-10/idProduct"
printf 'e0\n' >"$fake/sys/bus/usb/devices/1-10:1.0/bInterfaceClass"
printf '01\n' >"$fake/sys/bus/usb/devices/1-10:1.0/bInterfaceSubClass"
printf '01\n' >"$fake/sys/bus/usb/devices/1-10:1.0/bInterfaceProtocol"
expect "a USB Bluetooth adapter with no controller fails" "fail: Bluetooth adapter 8087:0033 (no driver) has no controller" "$(outcome bluetooth)"

# Audio
new_root
pci 0000:01:00.0 0x030000 1002:13c0 amdgpu
pci 0000:01:00.1 0x040300 1002:1640 snd_hda_intel
sound_card 0000:01:00.1 0
printf '00-03: HDMI 0 : HDMI 0 : playback 1\n' >"$fake/proc/asound/pcm"
printf ' 0 [Generic        ]: HDA-Intel - HD-Audio Generic\n' >"$fake/proc/asound/cards"
expect "a desktop with only a graphics card's HDMI audio is skipped" "skip: no speaker or headphone output found" "$(outcome audio-output)"

# An AMD APU's analog controller shares the GPU's slot as function 6.
pci 0000:01:00.6 0x040300 1022:15e3 snd_hda_intel
expect "an onboard controller that registered no sound card fails, HDMI elsewhere or not" "fail: audio controller 1022:15e3 (snd_hda_intel) has no sound card" "$(outcome audio-output)"

sound_card 0000:01:00.6 1
printf '01-00: SN6140 Analog : SN6140 Analog : playback 1 : capture 1\n' >>"$fake/proc/asound/pcm"
expect "a desktop output PipeWire has not opened is skipped: its jack may be empty" "skip: PipeWire has no speaker or headphone output open; nothing plugged in? (HDA-Intel)" \
  "$(PA_SINKS='56\talsa_output.pci-0000_01_00.1.hdmi-stereo\n' outcome audio-output)"
expect "an analog sink in PipeWire passes" "pass: 1 in PipeWire (HDA-Intel)" \
  "$(PA_SINKS='56\talsa_output.pci-0000_01_00.1.hdmi-stereo\n57\talsa_output.pci-0000_01_00.6.analog-stereo\n' outcome audio-output)"

make_laptop
expect "a laptop's dead speakers are not excused by a graphics card's HDMI sink" "fail: PipeWire has not opened the built-in speaker or headphone output (HDA-Intel)" \
  "$(PA_SINKS='56\talsa_output.pci-0000_01_00.1.hdmi-stereo\n' outcome audio-output)"
expect "a laptop whose one HDA card was switched to HDMI is skipped" "skip: audio is going to HDMI or DisplayPort (HDA-Intel)" \
  "$(PA_SINKS='56\talsa_output.pci-0000_01_00.6.hdmi-stereo\n' outcome audio-output)"
expect "speakers that are open mean the card was not switched, so a missing microphone fails" "fail: PipeWire has not opened the built-in microphone (HDA-Intel)" \
  "$(PA_SINKS='56\talsa_output.pci-0000_01_00.6.hdmi-stereo\n57\talsa_output.pci-0000_01_00.6.analog-stereo\n' outcome audio-input)"
expect "a USB DAC's speakers say nothing about the switched HDA card's microphone" "skip: audio is going to HDMI or DisplayPort (HDA-Intel)" \
  "$(PA_SINKS='56\talsa_output.pci-0000_01_00.6.hdmi-stereo\n58\talsa_output.usb-Generic_DAC-00.analog-stereo\n' outcome audio-input)"
rm -r "$fake/proc/acpi"
printf '3\n' >"$fake/sys/class/dmi/id/chassis_type"

# A board whose analog codec is on USB leaves the chipset controller codec-less.
rm -r "$fake/sys/bus/pci/devices/0000:01:00.6/sound"
expect "a codec-less controller beside working audio is ignored" "pass: 1 in PipeWire (HDA-Intel)" \
  "$(PA_SINKS='57\talsa_output.usb-Generic_USB_Audio-00.analog-stereo\n' outcome audio-output)"

printf '00-03: HDMI 0 : HDMI 0 : playback 1\n' >"$fake/proc/asound/pcm"
rm "$fake/sys/bus/pci/devices/0000:01:00.6/driver"
expect "an onboard audio controller with no driver fails when audio is missing" "fail: audio controller 1022:15e3 has no driver" "$(outcome audio-output)"

# A mini PC whose chipset audio carries only HDMI, DisplayPort and S/PDIF, and
# GPU audio left behind when Integrated mode detached the GPU.
new_root
pci 0000:00:1f.3 0x040300 8086:7a50 snd_hda_intel
pci 0000:01:00.1 0x040300 10de:22bc
pci 0000:02:00.1 0x040300 1002:ab28
mkdir -p "$fake/sys/bus/pci/devices/0000:00:1f.3/skl_hda_dsp_generic/sound/card0"
printf '00-01: ALC897 Digital : ALC897 Digital : playback 1\n00-03: HDMI 0 : HDMI 0 : playback 1\n00-07: DP 1 : DP 1 : playback 1\n' >"$fake/proc/asound/pcm"
expect "chipset audio with only digital outputs is skipped, its card found under the SOF machine driver" "skip: no speaker or headphone output found" "$(outcome audio-output)"

# Haswell and Broadwell put the GPU's HDMI on a controller of its own at 00:03.0.
new_root
make_laptop
pci 0000:00:03.0 0x040300 8086:160c snd_hda_intel
pci 0000:00:1b.0 0x040300 8086:9ca0 snd_hda_intel
sound_card 0000:00:03.0 0
sound_card 0000:00:1b.0 1
printf '00-03: HDMI 0 : HDMI 0 : playback 1\n01-00: ALC3263 Analog : ALC3263 Analog : playback 1 : capture 1\n' >"$fake/proc/asound/pcm"
expect "Haswell's separate HDMI controller does not excuse dead analog audio" "fail: PipeWire has not opened the built-in speaker or headphone output (no sound card)" \
  "$(PA_SINKS='56\talsa_output.pci-0000_00_03.0.hdmi-stereo\n' outcome audio-output)"

# Intel's AVS driver registers its card under a platform device of its own.
new_root
pci 0000:00:1f.3 0x040300 8086:7a50 snd_soc_avs
mkdir -p "$fake/sys/devices/platform/avs_hdaudio.2/sound/card0"
printf '00-02: HDMI2 : HDMI2 : playback 1\n' >"$fake/proc/asound/pcm"
mkdir -p "$fake/sys/devices/platform/avs_probe_mb.0.auto/sound/card1"
expect "an HDMI-only AVS machine is skipped, its card found where AVS puts it" "skip: no speaker or headphone output found" "$(outcome audio-output)"
rm -r "$fake/sys/devices/platform/avs_hdaudio.2"
expect "AVS's debug probe card does not stand in for a board that never came up" "fail: audio controller 8086:7a50 (snd_soc_avs) has no sound card" "$(outcome audio-output)"

# Every laptop has speakers and a microphone, whatever bus they are on, and
# no jack to wait on.
new_root
make_laptop
expect "a laptop with no built-in microphone fails" "fail: no built-in microphone (no sound card)" "$(outcome audio-input)"
pci 0000:00:1f.3 0x040300 8086:7a50 snd_hda_intel
sound_card 0000:00:1f.3 0
printf '00-00: Analog : Analog : playback 1 : capture 1\n' >>"$fake/proc/asound/pcm"
expect "a laptop microphone PipeWire has not opened fails" "fail: PipeWire has not opened the built-in microphone (no sound card)" "$(outcome audio-input)"

# A USB headset on a plugged-in port cannot stand in for the built-in microphone.
mkdir -p "$fake/sys/devices/usb3/3-1/3-1:1.0/sound/card2" "$fake/sys/class/sound"
ln -s "$fake/sys/devices/usb3/3-1/3-1:1.0/sound/card2" "$fake/sys/class/sound/card2"
ln -s "$fake/sys/devices/usb3/3-1/3-1:1.0" "$fake/sys/devices/usb3/3-1/3-1:1.0/sound/card2/device"
printf 'removable\n' >"$fake/sys/devices/usb3/3-1/removable"
printf '02-00: USB Audio : USB Audio : playback 1 : capture 1\n' >>"$fake/proc/asound/pcm"
expect "a USB headset's microphone does not stand in for the built-in one" "fail: PipeWire has not opened the built-in microphone (no sound card)" \
  "$(PA_SOURCES='60\talsa_input.usb-Headset-00.mono-fallback\t2\n' outcome audio-input)"
expect "the built-in microphone in PipeWire passes" "pass: 1 in PipeWire (no sound card)" \
  "$(PA_SOURCES='60\talsa_input.usb-Headset-00.mono-fallback\t2\n61\talsa_input.pci-0000_00_1f.3.analog-stereo\t0\n' outcome audio-input)"
expect "a node with no ALSA card does not stand in for the built-in microphone" "fail: PipeWire has not opened the built-in microphone (no sound card)" \
  "$(PA_SOURCES='62\talsa_input.usb-Headset-00.mono-fallback\n' outcome audio-input)"

# With the built-in card gone, only the headset is left, and it does not count.
rm -r "$fake/sys/bus/pci/devices/0000:00:1f.3/sound" "$fake/sys/class/sound/card0"
expect "a laptop whose only sound card is a USB headset fails on its own controller" "fail: audio controller 8086:7a50 (snd_hda_intel) has no sound card" \
  "$(PA_SOURCES='60\talsa_input.usb-Headset-00.mono-fallback\t2\n' outcome audio-input)"

# Graphics
new_root
rm "$fake/dev/dri/card0"
expect "a GPU with no device node fails" "fail: no GPU device in /dev/dri" "$(outcome graphics)"
touch "$fake/dev/dri/card0"
expect "rendering on the GPU passes with the renderer" "pass: Mesa Intel(R) Graphics" "$(outcome graphics)"
expect "rendering on the CPU fails" "fail: rendering on the CPU (llvmpipe)" "$(RENDERER=llvmpipe RENDERING=0 outcome graphics)"
expect "a VM rendering in software is skipped" "skip: virtual machine, rendering in software (llvmpipe)" "$(VM=1 RENDERER=llvmpipe RENDERING=0 outcome graphics)"
expect "a renderer that cannot be read is skipped, not passed" "skip: the renderer could not be read; run this from the desktop" "$(RENDERING=2 outcome graphics)"
expect "a renderer probe that crashes fails" "fail: asking the GPU for its renderer crashed or hung" "$(RENDERING=139 outcome graphics)"

# Battery: charge-based, and not named BAT*.
new_root
mkdir -p "$fake/sys/class/power_supply/CMB0"
printf 'Battery\n' >"$fake/sys/class/power_supply/CMB0/type"
printf '1\n' >"$fake/sys/class/power_supply/CMB0/present"
printf '80\n' >"$fake/sys/class/power_supply/CMB0/capacity"
printf 'Discharging\n' >"$fake/sys/class/power_supply/CMB0/status"
printf '4500000\n' >"$fake/sys/class/power_supply/CMB0/charge_full"
printf '5000000\n' >"$fake/sys/class/power_supply/CMB0/charge_full_design"
expect "a charge-based battery gets its health" "pass: 80%, discharging, health 90%" "$(outcome battery)"
rm "$fake/sys/class/power_supply/CMB0/status"
expect "an unreadable battery status reads as unknown" "pass: 80%, unknown, health 90%" "$(outcome battery)"
rm -r "$fake/sys/class/power_supply/CMB0"
make_laptop
expect "a laptop that reports no battery fails" "fail: the laptop reports no battery" "$(outcome battery)"

# Panel and touchpad, on a laptop.
new_root
expect "a desktop skips the built-in panel" "skip: not a laptop" "$(outcome panel)"

make_laptop
mkdir -p "$fake/sys/class/drm/card1/device" "$fake/sys/class/drm/card1-eDP-1"
ln -s /sys/bus/pci/drivers/i915 "$fake/sys/class/drm/card1/device/driver"
printf 'connected\n' >"$fake/sys/class/drm/card1-eDP-1/status"
expect "a connected eDP panel passes" "pass: eDP connected (i915)" "$(outcome panel)"

mkdir -p "$fake/sys/class/input/event5"
printf '13:69\n' >"$fake/sys/class/input/event5/dev"
printf 'E:ID_INPUT=1\nE:ID_INPUT_TOUCHPAD=1\nE:ID_BUS=usb\n' >"$fake/run/udev/data/c13:69"
mkdir -p "$fake/sys/devices/usb1/1-2/input/input9"
ln -s "$fake/sys/devices/usb1/1-2/input/input9" "$fake/sys/class/input/event5/device"
printf 'removable\n' >"$fake/sys/devices/usb1/1-2/removable"
expect "a trackpad on a removable USB port does not stand in for the built-in one" "fail: no built-in touchpad found" "$(outcome touchpad)"
# Behind a dock, the dock's own port reads unknown; the port it plugs into does not.
mkdir -p "$fake/sys/devices/usb1/1-2/1-2.3/input/input9"
rm "$fake/sys/class/input/event5/device"
ln -s "$fake/sys/devices/usb1/1-2/1-2.3/input/input9" "$fake/sys/class/input/event5/device"
printf 'unknown\n' >"$fake/sys/devices/usb1/1-2/1-2.3/removable"
expect "a trackpad behind a dock does not stand in for the built-in one" "fail: no built-in touchpad found" "$(outcome touchpad)"
printf 'fixed\n' >"$fake/sys/devices/usb1/1-2/removable"
expect "a touchpad on an internal USB port is the built-in one" "pass: found (unknown)" "$(outcome touchpad)"
printf 'E:ID_INPUT=1\nE:ID_INPUT_TOUCHPAD=1\n' >"$fake/run/udev/data/c13:69"
expect "a built-in touchpad passes" "pass: found (unknown)" "$(outcome touchpad)"

make_laptop closed
expect "a closed lid skips the built-in panel" "skip: lid is closed" "$(outcome panel)"

# Services: only units a package ships are named, instances cut to their template.
new_root
expect "units made on the machine are counted, not named" "fail: failed: 2 other wg-quick@" \
  "$(SHIPPED=wg-quick@.service FAILED_UNITS='wg-quick@corp.service loaded failed failed WireGuard\nmnt-nas.mount loaded failed failed NAS\nvpn-acme.service loaded failed failed VPN\n' outcome services)"
expect "the hostname and username are redacted wherever they appear" "fail: failed: backup_<host>.service sync-<user>.service" \
  "$(SHIPPED='backup_TestHost.service sync-tester.service' FAILED_UNITS='backup_TestHost.service loaded failed failed\nsync-tester.service loaded failed failed\n' outcome services)"

# An account named omarchy, as a stock worker's is, leaves the kernel's name alone.
expect "a username of omarchy does not rewrite the kernel or Omarchy's own units" "7.2.15-5-omarchy failed: omarchy-seamless-login.service" \
  "$(ID_USER=omarchy SHIPPED=omarchy-seamless-login.service FAILED_UNITS='omarchy-seamless-login.service loaded failed failed\n' rollcall services | jq -r '"\(.kernel) \(.checks[0].detail)"')"

# A username that is also a result word leaves the result alone.
status=0
ID_USER=fail SHIPPED=docker.service FAILED_UNITS='docker.service loaded failed failed Docker\n' rollcall services >/dev/null || status=$?
expect "a user named fail cannot turn a failure into a pass" "1" "$status"

# The whole run.
new_root
status=0
rollcall >/dev/null || status=$?
expect "a run with nothing failed exits 0" "0" "$status"
status=0
SHIPPED=docker.service FAILED_UNITS='docker.service loaded failed failed Docker\n' rollcall >/dev/null || status=$?
expect "a run with a failure exits 1" "1" "$status"
status=0
rollcall nonsense >/dev/null 2>&1 || status=$?
expect "an unknown check is a usage error" "2" "$status"
