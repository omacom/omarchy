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
elif [[ $* == *"CONNECTIVITY general" ]]; then
  echo "${NM_CONNECTIVITY:-full}"
elif [[ $* == *general ]]; then
  echo "${NM_RADIOS:-enabled:enabled}"
elif [[ $* == *DEVICE,TYPE,STATE* ]]; then
  printf '%b' "${NM_DEVICES:-}"
else
  printf '%b%b' "${NM_ETHERNET-ethernet:connected\n}" "${NM_WIFI:-wifi:connected\n}"
fi
SH

# Units named in SHIPPED come from a package; anything else was made here. An
# instance's file is its template's, as systemd reports it.
# The user's manager answers from USER_FAILED_UNITS, its packaged units in
# /usr/lib/systemd/user and its own in the home directory.
cat >"$stub_bin/systemctl" <<'SH'
#!/bin/bash
manager=system failed=${FAILED_UNITS:-} local=/etc/systemd/system
if [[ $1 == "--user" ]]; then
  shift
  manager=user failed=${USER_FAILED_UNITS:-} local=/home/tester/.config/systemd/user
fi
case "$*" in
  "is-active --quiet bluetooth.service") exit 0 ;;
  list-units*) printf '%b' "$failed" ;;
  "show -p FragmentPath --value "*)
    unit=${!#}
    [[ $unit == *@* ]] && unit="${unit%%@*}@.${unit##*.}"
    if [[ " ${SHIPPED:-} " == *" $unit "* ]]; then
      echo "/usr/lib/systemd/$manager/$unit"
    else
      echo "$local/$unit"
    fi
    ;;
esac
SH

# The kernel log of this boot, and its error-level lines alone.
cat >"$stub_bin/journalctl" <<'SH'
#!/bin/bash
if [[ " $* " == *" -p 3 "* ]]; then
  printf '%b' "${KERNEL_ERRORS:-}"
else
  printf '%b' "${KERNEL_LOG-Linux version 7.2.15-5-omarchy\n}"
fi
SH

cat >"$stub_bin/timedatectl" <<'SH'
#!/bin/bash
[[ -z ${TIME_STATUS:-} ]] || exit "$TIME_STATUS"
if [[ $1 == "show-timesync" ]]; then
  printf "%s\n" "${TIME_MESSAGE-Leap=0 Version=4 Mode=4 Stratum=2}"
  exit 0
fi
printf '%b' "${TIME_FIELDS:-CanNTP=yes\nNTP=yes\nNTPSynchronized=yes\n}"
SH

# fprintd and iio-sensor-proxy on the system bus. FPRINT_ERROR is what busctl
# says when the call fails; the sensor proxy is absent unless SENSOR_PROXY says.
cat >"$stub_bin/busctl" <<'SH'
#!/bin/bash
case "$*" in
  *GetDefaultDevice*)
    if [[ -n ${FPRINT_ERROR:-} ]]; then
      echo "$FPRINT_ERROR" >&2
      exit 1
    fi
    echo 'o "/net/reactivated/Fprint/Device/0"'
    ;;
  *"net.reactivated.Fprint.Device name") echo 's "Goodix MOC Fingerprint Sensor"' ;;
  *SensorProxy*)
    [[ -n ${SENSOR_PROXY:-} ]] || exit 1
    echo "$SENSOR_PROXY"
    ;;
  *) exit 1 ;;
esac
SH

# A session-wide LIBVA_DRIVER_NAME loads the wrong driver for this GPU.
cat >"$stub_bin/vainfo" <<'SH'
#!/bin/bash
[[ -z ${LIBVA_DRIVER_NAME:-} ]] || exit 1
printf '%b' "${VAINFO:-}"
SH

# PipeWire's graph, or no PipeWire at all.
cat >"$stub_bin/pw-dump" <<'SH'
#!/bin/bash
[[ -n ${PW_DUMP:-} ]] || exit 1
echo "$PW_DUMP"
SH

cat >"$stub_bin/v4l2-ctl" <<'SH'
#!/bin/bash
printf '%b' "${V4L2_INFO:-}"
SH

cat >"$stub_bin/powerprofilesctl" <<'SH'
#!/bin/bash
[[ -n ${PROFILE:-} ]] || exit 1
echo "$PROFILE"
SH

# A command named in MISSING is not installed.
cat >"$stub_bin/omarchy-cmd-present" <<'SH'
#!/bin/bash
for cmd in "$@"; do
  [[ " ${MISSING:-} " == *" $cmd "* ]] && exit 1
done
exit 0
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
  make_cpu
}

# Two threads on intel_pstate that have both been down to C10.
make_cpu() {
  local cpu=$fake/sys/devices/system/cpu n state
  mkdir -p "$cpu/cpufreq/policy0" "$cpu/cpuidle" "$fake/proc"
  printf '0-1\n' >"$cpu/present"
  printf '0-1\n' >"$cpu/online"
  printf 'intel_pstate\n' >"$cpu/cpufreq/policy0/scaling_driver"
  printf 'powersave\n' >"$cpu/cpufreq/policy0/scaling_governor"
  printf 'balance_performance\n' >"$cpu/cpufreq/policy0/energy_performance_preference"
  printf 'intel_idle\n' >"$cpu/cpuidle/current_driver"
  printf 'processor\t: 0\nvendor_id\t: GenuineIntel\n' >"$fake/proc/cpuinfo"
  for n in 0 1; do
    for state in 0:POLL 1:C1E 2:C10; do
      mkdir -p "$cpu/cpu$n/cpuidle/state${state%%:*}"
      printf '%s\n' "${state#*:}" >"$cpu/cpu$n/cpuidle/state${state%%:*}/name"
      printf '0\n' >"$cpu/cpu$n/cpuidle/state${state%%:*}/disable"
      printf '5000\n' >"$cpu/cpu$n/cpuidle/state${state%%:*}/time"
    done
  done
}

# A USB device or interface under a port, linked into /sys/bus/usb/devices as
# the kernel links it: path below sys/devices, then any files as name=value.
usb() {
  local dir=$fake/sys/devices/$1 pair
  mkdir -p "$dir" "$fake/sys/bus/usb/devices"
  ln -sfn "$dir" "$fake/sys/bus/usb/devices/${1##*/}"
  shift
  for pair in "$@"; do
    printf '%s\n' "${pair#*=}" >"$dir/${pair%%=*}"
  done
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

# A German session, so a dropped LC_ALL=C shows. The walkthrough's results
# live in a store of the test's own.
state=$test_tmp/state
rollcall() {
  LC_ALL=de_DE.UTF-8 OMARCHY_ROLLCALL_ROOT=$fake OMARCHY_ROLLCALL_STATE=$state PATH="$stub_bin:$ROOT/bin:$PATH" \
    "$ROOT/bin/omarchy-rollcall" --json "$@" 2>/dev/null
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

# Ethernet: presence from the bus, and the interface name never in the report.
new_root
pci 0000:03:00.0 0x020000 10ec:8125 r8169
mkdir -p "$fake/sys/bus/pci/devices/0000:03:00.0/net/enp3s0"
ln -s "$fake/sys/bus/pci/devices/0000:03:00.0/net/enp3s0" "$fake/sys/class/net/enp3s0"
ln -s "$fake/sys/bus/pci/devices/0000:03:00.0" "$fake/sys/class/net/enp3s0/device"
printf '1\n' >"$fake/sys/class/net/enp3s0/type"
printf '1\n' >"$fake/sys/class/net/enp3s0/carrier"
printf '2500\n' >"$fake/sys/class/net/enp3s0/speed"
expect "a wired port with a cable passes with its speed and driver" "pass: cable in at 2.5 Gb/s (r8169)" \
  "$(NM_DEVICES='enp3s0:ethernet:connected\n' outcome ethernet)"
printf '0\n' >"$fake/sys/class/net/enp3s0/carrier"
expect "a wired port with nothing plugged in still works" "pass: no cable (r8169)" "$(NM_DEVICES='enp3s0:ethernet:unavailable\n' outcome ethernet)"
expect "a wired port NetworkManager does not list fails" "fail: NetworkManager does not see a wired port (r8169)" \
  "$(NM_DEVICES='docker0:bridge:connected (externally)\n' outcome ethernet)"
expect "a NetworkManager that does not answer about wired ports fails" "fail: NetworkManager did not answer (r8169)" "$(NM_STATUS=124 outcome ethernet)"

pci 0000:04:00.0 0x020000 8086:125c igc
mkdir -p "$fake/sys/bus/pci/devices/0000:04:00.0/net/enp4s0"
ln -s "$fake/sys/bus/pci/devices/0000:04:00.0/net/enp4s0" "$fake/sys/class/net/enp4s0"
ln -s "$fake/sys/bus/pci/devices/0000:04:00.0" "$fake/sys/class/net/enp4s0/device"
printf '1\n' >"$fake/sys/class/net/enp4s0/type"
printf '1\n' >"$fake/sys/class/net/enp4s0/carrier"
expect "several wired ports are counted, each driver named once" "pass: a cable in 1 of 2 ports (igc, r8169)" \
  "$(NM_DEVICES='enp3s0:ethernet:unavailable\nenp4s0:ethernet:connected\n' outcome ethernet)"

pci 0000:05:00.0 0x020000 8086:1572 vfio-pci
expect "a controller handed to a virtual machine is the user's" "pass: a cable in 1 of 2 ports (igc, r8169)" \
  "$(NM_DEVICES='enp3s0:ethernet:unavailable\nenp4s0:ethernet:connected\n' outcome ethernet)"
pci 0000:06:00.0 0x020000 10ec:8126
expect "a wired controller with no driver fails, whatever else works" "fail: Ethernet controller 10ec:8126 (no driver) has no network interface" "$(outcome ethernet)"

new_root
usb usb2/2-1 idVendor=0bda idProduct=8156 removable=removable
usb usb2/2-1/2-1:1.0 bInterfaceClass=ff
mkdir -p "$fake/sys/devices/usb2/2-1/2-1:1.0/net/enx001122334455"
ln -s "$fake/sys/devices/usb2/2-1/2-1:1.0/net/enx001122334455" "$fake/sys/class/net/enx001122334455"
ln -s "$fake/sys/devices/usb2/2-1/2-1:1.0" "$fake/sys/class/net/enx001122334455/device"
printf '1\n' >"$fake/sys/class/net/enx001122334455/type"
ln -s /sys/bus/usb/drivers/r8152 "$fake/sys/devices/usb2/2-1/2-1:1.0/driver"
expect "a USB adapter on a removable port is not a wired port of the machine's" "skip: no wired port found" "$(outcome ethernet)"
printf 'fixed\n' >"$fake/sys/devices/usb2/2-1/removable"
rm -r "$fake/sys/class/net/enx001122334455" "$fake/sys/devices/usb2/2-1/2-1:1.0/net"
expect "a built-in USB Ethernet chip with no interface fails" "fail: USB Ethernet chip 0bda:8156 has no network interface" "$(outcome ethernet)"

# Network: NetworkManager's last verdict, nothing sent.
new_root
expect "full connectivity passes, naming the kinds of connection" "pass: online (ethernet, wifi)" "$(outcome network)"
expect "a network with no internet is where the user is" "skip: connected, without internet access" "$(NM_CONNECTIVITY=limited outcome network)"
expect "a captive portal is a skip" "skip: behind a login page" "$(NM_CONNECTIVITY=portal outcome network)"
expect "no connectivity with nothing connected is offline" "skip: offline" "$(NM_CONNECTIVITY=none NM_ETHERNET='' NM_WIFI='wifi:disconnected\n' outcome network)"
expect "a connected device with no connectivity at all fails" "fail: a connected ethernet device has no connectivity" "$(NM_CONNECTIVITY=none outcome network)"
expect "connectivity checking turned off is a skip" "skip: NetworkManager is not checking connectivity" "$(NM_CONNECTIVITY=unknown outcome network)"

# Modem
new_root
expect "no modem is a skip" "skip: no modem found" "$(outcome modem)"
pci 0000:08:00.0 0x0d4000 17cb:0308
expect "a modem on the bus with no driver fails" "fail: modem 17cb:0308 has no driver" "$(outcome modem)"
ln -s /sys/bus/pci/drivers/mhi-pci-generic "$fake/sys/bus/pci/devices/0000:08:00.0/driver"
expect "a modem whose driver made no control port fails" "fail: the modem has no control port (mhi-pci-generic)" "$(outcome modem)"
mkdir -p "$fake/sys/class/wwan/wwan0"
expect "a modem with a driver and a control port passes" "pass: found (mhi-pci-generic)" "$(outcome modem)"
mkdir -p "$fake/sys/class/rfkill/rfkill2"
printf 'wwan\n' >"$fake/sys/class/rfkill/rfkill2/type"
printf '1\n' >"$fake/sys/class/rfkill/rfkill2/soft"
expect "a modem the user turned off is skipped" "skip: turned off" "$(outcome modem)"

# Camera: built-in is a fixed port or an image processor; nothing is opened.
new_root
make_laptop
expect "a laptop with no camera is skipped, not failed" "skip: no built-in camera found" "$(outcome camera)"
usb usb3/3-1 idVendor=046d idProduct=085e removable=removable
usb usb3/3-1/3-1:1.0 bInterfaceClass=0e bInterfaceSubClass=01
expect "a webcam on a removable port does not stand in for a built-in one" "skip: no built-in camera found" "$(outcome camera)"
usb usb3/3-4 idVendor=04f2 idProduct=b7e0 removable=fixed
usb usb3/3-4/3-4:1.0 bInterfaceClass=0e bInterfaceSubClass=01
expect "a built-in camera with no driver fails" "fail: camera 04f2:b7e0 has no driver" "$(outcome camera)"
ln -s /sys/bus/usb/drivers/uvcvideo "$fake/sys/devices/usb3/3-4/3-4:1.0/driver"
mkdir -p "$fake/sys/devices/usb3/3-4/3-4:1.0/video4linux/video1"
printf '81:1\n' >"$fake/sys/devices/usb3/3-4/3-4:1.0/video4linux/video1/dev"
printf 'E:ID_V4L_CAPABILITIES=:\n' >"$fake/run/udev/data/c81:1"
expect "a built-in camera whose only node is metadata fails" "fail: camera 04f2:b7e0 has no capture device (uvcvideo)" "$(outcome camera)"
mkdir -p "$fake/sys/devices/usb3/3-4/3-4:1.0/video4linux/video0"
printf '81:0\n' >"$fake/sys/devices/usb3/3-4/3-4:1.0/video4linux/video0/dev"
printf 'E:ID_V4L_CAPABILITIES=:capture:\n' >"$fake/run/udev/data/c81:0"
expect "a built-in camera with a capture node passes" "pass: 1 built-in (uvcvideo)" "$(outcome camera)"

# A Snapdragon camera subsystem is found by its device-tree node, bound or not.
new_root
make_laptop
mkdir -p "$fake/sys/devices/platform/soc/ac5a000.isp/of_node"
printf 'qcom,x1e80100-camss\0' >"$fake/sys/devices/platform/soc/ac5a000.isp/of_node/compatible"
mkdir -p "$fake/sys/bus/platform/devices"
ln -s "$fake/sys/devices/platform/soc/ac5a000.isp" "$fake/sys/bus/platform/devices/ac5a000.isp"
expect "a Snapdragon camera subsystem whose driver never bound fails" "fail: image processor qcom,x1e80100-camss has no driver" "$(outcome camera)"

# An Intel IPU's sensor reaches apps through Omarchy's relay or libcamera.
new_root
make_laptop
pci 0000:00:05.0 0x048000 8086:645d
expect "an image processor with no driver fails" "fail: image processor 8086:645d has no driver" "$(outcome camera)"
ln -s /sys/bus/pci/drivers/intel-ipu7 "$fake/sys/bus/pci/devices/0000:00:05.0/driver"
expect "an image processor with no relay and no libcamera camera fails" "fail: image processor (intel-ipu7) has no camera an app can open" "$(PW_DUMP='[]' outcome camera)"
expect "an image processor is skipped when PipeWire cannot be asked" \
  "skip: the camera sits behind an image processor (intel-ipu7); PipeWire is not reachable from this session" "$(outcome camera)"
expect "an image processor's camera through libcamera passes" "pass: through libcamera (intel-ipu7)" \
  "$(PW_DUMP='[{"info": {"props": {"media.class": "Video/Source", "node.name": "libcamera_input._SB_.PC00"}}}]' outcome camera)"
mkdir -p "$fake/sys/devices/virtual/video4linux/video8"
expect "a relay that is not running offers no capture" "fail: image processor (intel-ipu7) has no camera an app can open" \
  "$(PW_DUMP='[]' V4L2_INFO='Device Caps      : 0x05200002\n\tVideo Output\n' outcome camera)"
expect "an image processor's camera relayed to a loopback node passes" "pass: relayed from the image processor (intel-ipu7)" \
  "$(V4L2_INFO='Device Caps      : 0x05200001\n\tVideo Capture\n' outcome camera)"

# Keyboard, on a laptop.
new_root
expect "a desktop skips the built-in keyboard" "skip: not a laptop" "$(outcome keyboard)"
make_laptop
mkdir -p "$fake/sys/class/input/event7"
printf '13:71\n' >"$fake/sys/class/input/event7/dev"
printf 'E:ID_INPUT=1\nE:ID_INPUT_KEYBOARD=1\nE:ID_BUS=usb\n' >"$fake/run/udev/data/c13:71"
mkdir -p "$fake/sys/devices/usb1/1-3/input/input12"
ln -s "$fake/sys/devices/usb1/1-3/input/input12" "$fake/sys/class/input/event7/device"
printf 'removable\n' >"$fake/sys/devices/usb1/1-3/removable"
expect "a USB keyboard plugged in does not stand in for the built-in one" "fail: no built-in keyboard found" "$(outcome keyboard)"
mkdir -p "$fake/sys/class/input/event3" "$fake/sys/devices/platform/i8042/serio0/input/input3"
printf '13:67\n' >"$fake/sys/class/input/event3/dev"
printf 'E:ID_INPUT=1\nE:ID_INPUT_KEY=1\nE:ID_INPUT_KEYBOARD=1\n' >"$fake/run/udev/data/c13:67"
ln -s "$fake/sys/devices/platform/i8042/serio0/input/input3" "$fake/sys/class/input/event3/device"
ln -s "$fake/sys/devices/platform/i8042/serio0" "$fake/sys/devices/platform/i8042/serio0/input/input3/device"
ln -s /sys/bus/serio/drivers/atkbd "$fake/sys/devices/platform/i8042/serio0/driver"
expect "the keyboard controller's keyboard passes" "pass: found (atkbd)" "$(outcome keyboard)"

# Sensors: an accelerometer or light sensor has to give a reading.
new_root
expect "a machine with no sensors is skipped" "skip: no motion or light sensor found" "$(outcome sensors)"
printf '31\n' >"$fake/sys/class/dmi/id/chassis_type"
expect "a convertible with no accelerometer fails" "fail: the convertible reports no accelerometer" "$(outcome sensors)"
pci 0000:00:12.0 0x118000 8086:a0fc
expect "a convertible's sensor hub with no driver fails" "fail: sensor hub 8086:a0fc has no driver" "$(outcome sensors)"
ln -s /sys/bus/pci/drivers/intel_ish_ipc "$fake/sys/bus/pci/devices/0000:00:12.0/driver"
mkdir -p "$fake/sys/bus/iio/devices/iio:device0"
printf 'accel_3d\n' >"$fake/sys/bus/iio/devices/iio:device0/name"
for axis in x y z; do printf -- '-512\n' >"$fake/sys/bus/iio/devices/iio:device0/in_accel_${axis}_raw"; done
expect "an accelerometer that gives a reading passes" "pass: accelerometer (accel_3d)" "$(outcome sensors)"
expect "an accelerometer iio-sensor-proxy does not see fails" "fail: iio-sensor-proxy does not see the accelerometer" "$(SENSOR_PROXY='b false' outcome sensors)"
expect "an accelerometer iio-sensor-proxy sees passes" "pass: accelerometer (accel_3d)" "$(SENSOR_PROXY='b true' outcome sensors)"
: >"$fake/sys/bus/iio/devices/iio:device0/in_accel_x_raw"
expect "an accelerometer whose hub lists it and gives no reading fails" "fail: the accelerometer (accel_3d) does not answer" "$(outcome sensors)"

# Fingerprint: recognised by Omarchy's detector, then asked of fprintd.
new_root
expect "no fingerprint reader is a skip" "skip: no fingerprint reader found" "$(outcome fingerprint)"
mkdir -p "$fake/sys/bus/usb/devices/3-9"
printf '27c6\n' >"$fake/sys/bus/usb/devices/3-9/idVendor"
printf 'Goodix Fingerprint USB Device\n' >"$fake/sys/bus/usb/devices/3-9/product"
expect "a reader fprintd can use passes, named as fprintd names it" "pass: fprintd sees it (Goodix MOC Fingerprint Sensor)" "$(outcome fingerprint)"
expect "a reader before fingerprint setup installs fprintd is a skip" "skip: reader found; fprintd is not installed until fingerprint setup runs" \
  "$(FPRINT_ERROR='Call failed: The name net.reactivated.Fprint was not provided by any .service files' outcome fingerprint)"
expect "a reader fprintd has no driver for fails" "fail: fprintd has no driver for the reader" \
  "$(FPRINT_ERROR='Call failed: No devices available' outcome fingerprint)"

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

# Video decode: asked of each awake GPU through vainfo.
new_root
expect "no vainfo is a skip naming the tool" "skip: vainfo is not installed (libva-utils)" "$(MISSING=vainfo outcome video-decode)"
mkdir -p "$fake/sys/class/drm/card1" "$fake/sys/bus/pci/devices/0000:01:00.0/drm/renderD128" "$fake/sys/bus/pci/devices/0000:01:00.0/power"
pci 0000:01:00.0 0x030000 1002:13c0 amdgpu
ln -s "$fake/sys/bus/pci/devices/0000:01:00.0" "$fake/sys/class/drm/card1/device"
expect "a GPU that decodes passes with the codecs" "pass: H.264, HEVC, AV1 (amdgpu)" \
  "$(VAINFO='vainfo: Driver version: Mesa Gallium driver\n      VAProfileH264Main               :\tVAEntrypointVLD\n      VAProfileH264High               :\tVAEntrypointVLD\n      VAProfileH264High               :\tVAEntrypointEncSlice\n      VAProfileHEVCMain               :\tVAEntrypointVLD\n      VAProfileAV1Profile0            :\tVAEntrypointVLD\n      VAProfileNone                   :\tVAEntrypointVideoProc\n' outcome video-decode)"
expect "the NVIDIA session's VA driver name does not reach another GPU" "pass: H.264, HEVC, AV1 (amdgpu)" \
  "$(LIBVA_DRIVER_NAME=nvidia VAINFO='      VAProfileH264Main               :\tVAEntrypointVLD\n      VAProfileHEVCMain               :\tVAEntrypointVLD\n      VAProfileAV1Profile0            :\tVAEntrypointVLD\n' outcome video-decode)"
expect "a GPU whose driver decodes on every other machine and offers nothing fails" "fail: no hardware decode on the GPU (amdgpu)" "$(outcome video-decode)"
rm "$fake/sys/bus/pci/devices/0000:01:00.0/driver"
ln -s /sys/bus/pci/drivers/nvidia "$fake/sys/bus/pci/devices/0000:01:00.0/driver"
expect "an NVIDIA card with no VA-API driver installed is not expected to decode" "skip: no GPU offers VA-API decode" "$(outcome video-decode)"
mkdir -p "$fake/usr/lib/dri" && : >"$fake/usr/lib/dri/nvidia_drv_video.so"
expect "an NVIDIA card with its VA-API driver that offers nothing fails" "fail: no hardware decode on the GPU (nvidia)" "$(outcome video-decode)"
rm "$fake/usr/lib/dri/nvidia_drv_video.so"
printf 'suspended\n' >"$fake/sys/bus/pci/devices/0000:01:00.0/power/runtime_status"
expect "a sleeping GPU is left asleep" "skip: the GPU is asleep" "$(outcome video-decode)"
rm "$fake/sys/bus/pci/devices/0000:01:00.0/power/runtime_status" "$fake/sys/bus/pci/devices/0000:01:00.0/driver"
ln -s /sys/bus/platform/drivers/msm "$fake/sys/bus/pci/devices/0000:01:00.0/driver"
expect "a GPU that decodes through something other than VA-API is a skip" "skip: no GPU offers VA-API decode" "$(outcome video-decode)"

# Suspend: what the kernel kept of this boot's suspends; nothing is suspended.
new_root
expect "a kernel with no sleep state is skipped" "skip: the kernel offers no sleep state" "$(outcome suspend)"
mkdir -p "$fake/sys/power/suspend_stats"
printf 'freeze mem disk\n' >"$fake/sys/power/state"
printf 's2idle [deep]\n' >"$fake/sys/power/mem_sleep"
expect "a virtual machine skips suspend" "skip: virtual machine" "$(VM=1 outcome suspend)"
printf '0\n' >"$fake/sys/power/suspend_stats/success"
printf '0\n' >"$fake/sys/power/suspend_stats/fail"
expect "no suspend yet this boot is a skip" "skip: not suspended since boot (deep)" "$(outcome suspend)"
printf '3\n' >"$fake/sys/power/suspend_stats/success"
expect "deep sleep with every suspend succeeding passes" "pass: deep, 3 suspends" "$(outcome suspend)"

printf '[s2idle] deep\n' >"$fake/sys/power/mem_sleep"
printf '512000000\n' >"$fake/sys/power/suspend_stats/last_hw_sleep"
printf '900000000\n' >"$fake/sys/power/suspend_stats/total_hw_sleep"
expect "suspend-to-idle that reached hardware sleep passes" "pass: s2idle, 3 suspends, the last 512 s in hardware sleep" "$(outcome suspend)"
printf '0\n' >"$fake/sys/power/suspend_stats/last_hw_sleep"
expect "suspend-to-idle whose last suspend never reached hardware sleep fails" "fail: s2idle, 3 suspends, the last never reached hardware sleep" "$(outcome suspend)"
printf '0\n' >"$fake/sys/power/suspend_stats/total_hw_sleep"
expect "suspend-to-idle that never reached hardware sleep fails" "fail: s2idle, 3 suspends, none reached hardware sleep" "$(outcome suspend)"
rm "$fake/sys/power/suspend_stats/last_hw_sleep" "$fake/sys/power/suspend_stats/total_hw_sleep"
mkdir -p "$fake/sys/devices/system/cpu/cpuidle"
printf '0\n' >"$fake/sys/devices/system/cpu/cpuidle/low_power_idle_system_residency_us"
expect "Intel's S0ix residency stands in for the counter when it is all there is" "fail: s2idle, 3 suspends, none reached hardware sleep" "$(outcome suspend)"
printf '7200000\n' >"$fake/sys/devices/system/cpu/cpuidle/low_power_idle_system_residency_us"
expect "S0ix residency after suspends passes" "pass: s2idle, 3 suspends, hardware sleep reached" "$(outcome suspend)"

printf '2\n' >"$fake/sys/power/suspend_stats/fail"
printf -- '-16\n' >"$fake/sys/power/suspend_stats/last_failed_errno"
printf 'suspend\n' >"$fake/sys/power/suspend_stats/last_failed_step"
expect "a suspend a wake event called off is not a failure" "pass: s2idle, 3 suspends, hardware sleep reached, 2 called off by a wake event" "$(outcome suspend)"
printf '1\n' >"$fake/sys/power/suspend_stats/failed_resume"
printf '0000:00:14.0\n' >"$fake/sys/power/suspend_stats/last_failed_dev"
expect "a failed resume fails, naming the step and device" "fail: 2 of 5 suspends failed, the last at suspend (0000:00:14.0)" "$(outcome suspend)"
printf 'nvme-eui.0025385b71b0aa21\n' >"$fake/sys/power/suspend_stats/last_failed_dev"
expect "a failed device name that could carry a serial is left out" "fail: 2 of 5 suspends failed, the last at suspend" "$(outcome suspend)"

# Processor: drivers, idle states and threads, nothing loaded or switched.
new_root
expect "a processor with its own driver that has idled deeply passes" \
  "pass: intel_pstate, powersave governor, EPP balance_performance, idle down to C10 (intel_idle), 2 threads, balanced profile" \
  "$(PROFILE=balanced outcome cpu)"
expect "a virtual machine skips the processor" "skip: virtual machine" "$(VM=1 outcome cpu)"
printf '0\n' >"$fake/sys/devices/system/cpu/cpu1/cpuidle/state2/time"
expect "a thread that never entered its deepest idle state since boot fails" \
  "fail: 1 of 2 threads never entered C10 since boot (intel_pstate, powersave governor, EPP balance_performance)" "$(outcome cpu)"
printf '1\n' >"$fake/sys/devices/system/cpu/cpu0/cpuidle/state2/disable"
expect "a disabled state is not the deepest one" "pass: intel_pstate, powersave governor, EPP balance_performance, idle down to C1E (intel_idle), 2 threads" "$(outcome cpu)"
rm -r "$fake/sys/devices/system/cpu/cpu0/cpuidle/state2"
expect "no idle state deeper than halt fails on x86" "fail: no idle state deeper than C1E (intel_pstate, powersave governor, EPP balance_performance)" "$(outcome cpu)"
printf 'processor\t: 0\nCPU implementer\t: 0x61\n' >"$fake/proc/cpuinfo"
expect "an ARM processor is not held to the firmware's idle tables" "pass: intel_pstate, powersave governor, EPP balance_performance, idle down to C1E (intel_idle), 2 threads" "$(outcome cpu)"

new_root
printf '0\n' >"$fake/sys/devices/system/cpu/online"
expect "an offline thread fails" "fail: 1 of 2 threads are offline" "$(outcome cpu)"
mkdir -p "$fake/sys/devices/system/cpu/smt"
printf 'off\n' >"$fake/sys/devices/system/cpu/smt/control"
expect "threads left offline by turning SMT off were chosen" "pass: intel_pstate, powersave governor, EPP balance_performance, idle down to C10 (intel_idle), 1 threads" "$(outcome cpu)"

new_root
printf 'acpi-cpufreq\n' >"$fake/sys/devices/system/cpu/cpufreq/policy0/scaling_driver"
rm "$fake/sys/devices/system/cpu/cpufreq/policy0/energy_performance_preference"
expect "the generic driver is named as generic, not failed" "pass: acpi-cpufreq, powersave governor, the generic driver, idle down to C10 (intel_idle), 2 threads" "$(outcome cpu)"
mkdir -p "$fake/sys/bus/acpi/devices/AMDI0102:00"
printf '15\n' >"$fake/sys/bus/acpi/devices/AMDI0102:00/status"
expect "AMD's platform management device with no driver fails" "fail: AMD platform management AMDI0102 has no driver (amd_pmf)" "$(outcome cpu)"
mkdir -p "$fake/sys/bus/acpi/devices/AMDI0102:00/physical_node"
ln -s /sys/bus/platform/drivers/amd_pmf "$fake/sys/bus/acpi/devices/AMDI0102:00/physical_node/driver"
expect "AMD's platform management device with amd_pmf bound passes" "pass: acpi-cpufreq, powersave governor, the generic driver, idle down to C10 (intel_idle), 2 threads" "$(outcome cpu)"
rm "$fake/sys/devices/system/cpu/cpufreq/policy0/scaling_driver"
expect "a processor with no frequency scaling driver fails" "fail: no frequency scaling driver" "$(outcome cpu)"

# Storage: controllers by bus, the system disk through its encryption layer.
new_root
expect "a system disk that cannot be traced is skipped" "skip: the system disk could not be traced" "$(outcome storage)"
pci 0000:07:00.0 0x010802 c0a9:5421 nvme
disk=$fake/sys/bus/pci/devices/0000:07:00.0/nvme/nvme0/nvme0n1
mkdir -p "$disk/nvme0n1p2" "$disk/queue" "$fake/sys/class/block" "$fake/sys/devices/virtual/block/dm-0/slaves" "$fake/dev/mapper" \
  "$fake/sys/bus/pci/devices/0000:07:00.0/nvme/nvme0/power"
ln -s "$fake/sys/bus/pci/devices/0000:07:00.0/nvme/nvme0" "$disk/device"
ln -s "$disk" "$fake/sys/class/block/nvme0n1"
ln -s "$disk/nvme0n1p2" "$fake/sys/class/block/nvme0n1p2"
touch "$disk/nvme0n1p2/partition"
ln -s "$fake/sys/devices/virtual/block/dm-0" "$fake/sys/class/block/dm-0"
ln -s "$fake/sys/class/block/nvme0n1p2" "$fake/sys/devices/virtual/block/dm-0/slaves/nvme0n1p2"
ln -s ../dm-0 "$fake/dev/mapper/root"
mkdir -p "$fake/proc/self"
printf '33 2 0:30 /@ / rw,relatime shared:1 - btrfs /dev/mapper/root rw,subvol=/@\n' >"$fake/proc/self/mountinfo"
printf '0\n' >"$disk/queue/rotational"
printf '2199023255040\n' >"$disk/queue/discard_max_bytes"
printf '100000\n' >"$fake/sys/bus/pci/devices/0000:07:00.0/nvme/nvme0/power/pm_qos_latency_tolerance_us"
expect "an encrypted NVMe system disk with TRIM and power saving passes" "pass: NVMe system disk (nvme), TRIM, power saving on" "$(outcome storage)"
rm "$fake/sys/bus/pci/devices/0000:07:00.0/nvme/nvme0/power/pm_qos_latency_tolerance_us"
printf 'no_apst\n' >"$fake/sys/bus/pci/devices/0000:07:00.0/nvme/nvme0/quirks"
expect "power saving the kernel turned off for a drive model is said, not failed" "pass: NVMe system disk (nvme), TRIM, power saving off for this model" "$(outcome storage)"
printf '0\n' >"$disk/queue/discard_max_bytes"
expect "a solid-state system disk without TRIM fails" "fail: the NVMe system disk (nvme) does not accept TRIM" "$(outcome storage)"
pci 0000:00:0e.0 0x010400 8086:467f
expect "a storage controller with no driver fails" "fail: storage controller 8086:467f has no driver" "$(outcome storage)"
expect "a virtual machine skips storage" "skip: virtual machine" "$(VM=1 outcome storage)"

# USB and Thunderbolt
new_root
expect "a desktop with no USB controller found is skipped" "skip: no USB controller found" "$(outcome usb)"
make_laptop
expect "a laptop with no USB controller fails" "fail: the laptop reports no USB controller" "$(outcome usb)"
pci 0000:00:14.0 0x0c0330 8086:a0ed xhci_hcd
for hub in usb1:480 usb2:10000; do
  mkdir -p "$fake/sys/bus/pci/devices/0000:00:14.0/${hub%%:*}"
  printf '%s\n' "${hub#*:}" >"$fake/sys/bus/pci/devices/0000:00:14.0/${hub%%:*}/speed"
  ln -s "$fake/sys/bus/pci/devices/0000:00:14.0/${hub%%:*}" "$fake/sys/bus/usb/devices/${hub%%:*}"
done
expect "USB controllers with drivers pass with their fastest port" "pass: 1 controller (xhci_hcd), up to 10 Gb/s" "$(outcome usb)"
pci 0000:00:0d.2 0x0c0340 8086:9a1b thunderbolt
expect "a USB4 controller with no domain fails" "fail: the USB4 or Thunderbolt controller has no domain (1 controller (xhci_hcd), up to 10 Gb/s)" "$(outcome usb)"
mkdir -p "$fake/sys/bus/thunderbolt/devices/domain0"
printf 'usbonly\n' >"$fake/sys/bus/thunderbolt/devices/domain0/security"
expect "a USB-only Thunderbolt security level is the owner's firmware setting, not a failure" \
  "pass: 1 controller (xhci_hcd), up to 10 Gb/s, USB4 or Thunderbolt limited to usbonly in the firmware settings" "$(outcome usb)"
printf 'user\n' >"$fake/sys/bus/thunderbolt/devices/domain0/security"
expect "a USB4 controller with a domain that can authorise passes" "pass: 1 controller (xhci_hcd), up to 10 Gb/s, USB4 or Thunderbolt (security user)" "$(outcome usb)"
pci 0000:00:14.1 0x0c03fe 8086:a0ee
expect "a device-mode controller with no driver is not a host controller" "pass: 1 controller (xhci_hcd), up to 10 Gb/s, USB4 or Thunderbolt (security user)" "$(outcome usb)"
pci 0000:04:00.0 0x0c0330 1b21:2142
expect "a USB controller with no driver fails" "fail: USB controller 1b21:2142 has no driver" "$(outcome usb)"

# Card reader
new_root
expect "no card reader is a skip" "skip: no card reader found" "$(outcome card-reader)"
pci 0000:2f:00.0 0xff0000 10ec:525a
expect "a Realtek card reader, which reports no class, with no driver fails" "fail: card reader 10ec:525a has no driver" "$(outcome card-reader)"
ln -s /sys/bus/pci/drivers/rtsx_pci "$fake/sys/bus/pci/devices/0000:2f:00.0/driver"
expect "a card reader with its driver passes" "pass: found (rtsx_pci)" "$(outcome card-reader)"
new_root
usb usb1/1-6 idVendor=05e3 idProduct=0761 product="USB Card Reader" removable=removable
usb usb1/1-6/1-6:1.0 bInterfaceClass=08
expect "a card reader on a removable port is not the machine's" "skip: no card reader found" "$(outcome card-reader)"
printf 'fixed\n' >"$fake/sys/devices/usb1/1-6/removable"
expect "a built-in USB card reader with no driver fails" "fail: card reader 05e3:0761 has no driver" "$(outcome card-reader)"
ln -s /sys/bus/usb/drivers/usb-storage "$fake/sys/devices/usb1/1-6/1-6:1.0/driver"
expect "a built-in USB card reader with its driver passes" "pass: found (usb-storage)" "$(outcome card-reader)"

# TPM
new_root
expect "no TPM is a skip" "skip: no TPM found" "$(outcome tpm)"
mkdir -p "$fake/sys/bus/acpi/devices/PNP0C31:00"
printf '0\n' >"$fake/sys/bus/acpi/devices/PNP0C31:00/status"
expect "a TPM switched off in the firmware is a skip" "skip: the TPM is switched off in the firmware" "$(outcome tpm)"
mkdir -p "$fake/sys/bus/acpi/devices/MSFT0101:00"
printf '15\n' >"$fake/sys/bus/acpi/devices/MSFT0101:00/status"
expect "a TPM the firmware describes with no driver fails" "fail: the firmware describes a TPM that has no driver" "$(outcome tpm)"
mkdir -p "$fake/sys/class/tpm/tpm0/device" "$fake/sys/class/tpm/tpm0/pcr-sha256"
printf '2\n' >"$fake/sys/class/tpm/tpm0/tpm_version_major"
ln -s /sys/bus/platform/drivers/tpm_crb "$fake/sys/class/tpm/tpm0/device/driver"
printf '0000000000000000000000000000000000000000000000000000000000000000\n' >"$fake/sys/class/tpm/tpm0/pcr-sha256/0"
expect "a TPM 2.0 that answers passes" "pass: TPM 2.0 (tpm_crb)" "$(outcome tpm)"
: >"$fake/sys/class/tpm/tpm0/pcr-sha256/0"
expect "a TPM 2.0 that does not answer fails" "fail: TPM 2.0 does not answer (tpm_crb)" "$(outcome tpm)"

# Firmware and the kernel
new_root
expect "a quiet kernel passes, its error lines counted" "pass: no firmware missing, not tainted, 2 kernel errors" \
  "$(KERNEL_ERRORS='ACPI BIOS Error (bug): Failure creating named object\nACPI Error: AE_ALREADY_EXISTS\n' outcome firmware)"
expect "a firmware file that never loaded and is not installed fails, named by file" \
  "fail: missing firmware: amdgpu/dcn_4_0_1_dmcub.bin, rtl_nic/rtl8126a-3.fw" \
  "$(KERNEL_LOG='r8169 0000:03:00.0: Direct firmware load for rtl_nic/rtl8126a-3.fw failed with error -2\namdgpu 0000:01:00.0: firmware: failed to load amdgpu/dcn_4_0_1_dmcub.bin (-2)\n' outcome firmware)"
mkdir -p "$fake/usr/lib/firmware"
touch "$fake/usr/lib/firmware/iwlwifi-so-a0-gf-a0-86.ucode.zst"
expect "a newer firmware a driver falls back from is not missing" "pass: no firmware missing, not tainted, 0 kernel errors" \
  "$(KERNEL_LOG='iwlwifi 0000:00:14.3: Direct firmware load for iwlwifi-so-a0-gf-a0-89.ucode failed with error -2\n' outcome firmware)"
touch "$fake/usr/lib/firmware/iwlwifi-so-a0-gf-a0-89.ucode.zst"
expect "a newer firmware installed since the driver fell back is not a failure" "pass: no firmware missing, not tainted, 0 kernel errors" \
  "$(KERNEL_LOG='iwlwifi 0000:00:14.3: Direct firmware load for iwlwifi-so-a0-gf-a0-89.ucode failed with error -2\n' outcome firmware)"
touch "$fake/usr/lib/firmware/iwlwifi-so-a0-gf-a0-90.ucode.zst"
expect "a newer version installed since boot does not hide that every requested one failed" \
  "fail: missing firmware: iwlwifi-so-a0-gf-a0-77.ucode; failed to load at boot but on disk now, restart to load: iwlwifi-so-a0-gf-a0-86.ucode, iwlwifi-so-a0-gf-a0-89.ucode" \
  "$(KERNEL_LOG='iwlwifi: Direct firmware load for iwlwifi-so-a0-gf-a0-89.ucode failed with error -2\niwlwifi: Direct firmware load for iwlwifi-so-a0-gf-a0-86.ucode failed with error -2\niwlwifi: Direct firmware load for iwlwifi-so-a0-gf-a0-77.ucode failed with error -2\n' outcome firmware)"
rm "$fake/usr/lib/firmware/iwlwifi-so-a0-gf-a0-90.ucode.zst"
expect "every version failing is not a fallback, and the ones on disk ran without loading" "fail: missing firmware: iwlwifi-so-a0-gf-a0-77.ucode; failed to load at boot but on disk now, restart to load: iwlwifi-so-a0-gf-a0-86.ucode, iwlwifi-so-a0-gf-a0-89.ucode" \
  "$(KERNEL_LOG='iwlwifi: Direct firmware load for iwlwifi-so-a0-gf-a0-89.ucode failed with error -2\niwlwifi: Direct firmware load for iwlwifi-so-a0-gf-a0-86.ucode failed with error -2\niwlwifi: Direct firmware load for iwlwifi-so-a0-gf-a0-77.ucode failed with error -2\n' outcome firmware)"
mkdir -p "$fake/usr/lib/firmware/amdgpu" && touch "$fake/usr/lib/firmware/amdgpu/dcn_4_0_1_dmcub.bin.zst"
expect "firmware on disk now that failed at boot still fails: the device runs without it" \
  "fail: failed to load at boot but on disk now, restart to load: amdgpu/dcn_4_0_1_dmcub.bin" \
  "$(KERNEL_LOG='amdgpu 0000:01:00.0: firmware: failed to load amdgpu/dcn_4_0_1_dmcub.bin (-2)\n' outcome firmware)"
rm -r "$fake/usr/lib/firmware/amdgpu" "$fake/usr/lib/firmware/iwlwifi-so-a0-gf-a0-89.ucode.zst"
mkdir -p "$fake/proc/sys/kernel" "$fake/sys/module/zfs" "$fake/sys/module/ext4"
printf 'POE\n' >"$fake/sys/module/zfs/taint"
: >"$fake/sys/module/ext4/taint"
printf '12289\n' >"$fake/proc/sys/kernel/tainted"
expect "an out-of-tree module's taint is named with its module, not failed" "pass: no firmware missing, tainted POE by zfs, 0 kernel errors" "$(outcome firmware)"
printf '512\n' >"$fake/proc/sys/kernel/tainted"
expect "a kernel warning fails, naming where it was" "fail: kernel tainted W by a kernel warning, first at drivers/gpu/drm/amd/display/dc/core/dc.c" \
  "$(KERNEL_LOG='WARNING: CPU: 3 PID: 412 at drivers/gpu/drm/amd/display/dc/core/dc.c:1234 dc_commit_state+0x1/0x2 [amdgpu]\n' outcome firmware)"
printf '0\n' >"$fake/proc/sys/kernel/tainted"
expect "a kernel log this user cannot read is a skip" "skip: the kernel log is not readable as this user; not tainted" "$(KERNEL_LOG='' outcome firmware)"

# Time
new_root
expect "a synchronised clock passes" "pass: synchronised" "$(outcome time)"
expect "network time turned off is a skip" "skip: network time is turned off" "$(TIME_FIELDS='CanNTP=yes\nNTP=no\nNTPSynchronized=no\n' outcome time)"
expect "no time service is a skip" "skip: no network time service" "$(TIME_FIELDS='CanNTP=no\nNTP=no\nNTPSynchronized=no\n' outcome time)"
expect "an unsynchronised clock while offline is a skip" "skip: not synchronised while offline" \
  "$(NM_CONNECTIVITY=none TIME_FIELDS='CanNTP=yes\nNTP=yes\nNTPSynchronized=no\n' outcome time)"
expect "an unsynchronised clock online fails" "fail: online, but the clock is not synchronised" "$(TIME_FIELDS='CanNTP=yes\nNTP=yes\nNTPSynchronized=no\n' outcome time)"
expect "an unsynchronised clock no server has answered yet is a skip" "skip: not synchronised yet: no time server has answered" "$(TIME_MESSAGE='' TIME_FIELDS='CanNTP=yes\nNTP=yes\nNTPSynchronized=no\n' outcome time)"
expect "timedated that does not answer is a skip" "skip: timedated did not answer" "$(TIME_STATUS=1 outcome time)"

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

# User services, named on the same terms as the system's.
new_root
expect "a user session with nothing failed passes" "pass: none failed" "$(FAILED_UNITS='docker.service loaded failed failed\n' outcome user-services)"
expect "a user's own units are counted and packaged ones named" "fail: failed: 1 other wireplumber.service" \
  "$(SHIPPED=wireplumber.service USER_FAILED_UNITS='wireplumber.service loaded failed failed\nbackup-acme.service loaded failed failed\n' outcome user-services)"
expect "an Omarchy unit copied into the home directory is Omarchy's name" "fail: failed: omarchy-camera-relay.service" \
  "$(USER_FAILED_UNITS='omarchy-camera-relay.service loaded failed failed\n' outcome user-services)"

# The walkthrough: what a person finished, read from the store, oldest first.
new_root
expect "an empty walkthrough store reports nothing" "0" "$(rollcall | jq '.attended | length')"
expect "an empty walkthrough store adds no block to the text report" "0" \
  "$(OMARCHY_ROLLCALL_ROOT=$fake OMARCHY_ROLLCALL_STATE=$state PATH="$stub_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-rollcall" 2>/dev/null | grep -c '^Walkthrough$')"
mkdir -p "$state/attended"
printf '{"id": "speakers", "result": "pass", "detail": "left and right heard", "finished": 200}\n' >"$state/attended/speakers.json"
printf '{"id": "camera", "result": "skip", "detail": "no camera on testhost", "finished": 100}\n' >"$state/attended/camera.json"
printf '{"id": "keyboard", "detail": "typed", "question": "Did every key register?"}\n' >"$state/attended/keyboard.pending.json"
printf '{"id": "lid", "result": "maybe", "detail": "", "finished": 50}\n' >"$state/attended/lid.json"
printf '{"id": "touchpad", "result": "pass"' >"$state/attended/touchpad.json"
expect "finished results come oldest first; pending, unknown and malformed ones are left out, and the host is redacted" \
  "camera skip: no camera on <host>; speakers pass: left and right heard" \
  "$(rollcall | jq -r '.attended | map("\(.id) \(.result): \(.detail)") | join("; ")')"
expect "naming checks leaves the walkthrough out" "0" "$(rollcall time | jq '.attended | length')"
text=$(LC_ALL=C OMARCHY_ROLLCALL_ROOT=$fake OMARCHY_ROLLCALL_STATE=$state PATH="$stub_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-rollcall" 2>/dev/null | sed -n '/^Walkthrough$/,$p')
expect "the text report gives the walkthrough its own block and counts" \
  $'Walkthrough\n\n  – camera         skipped: no camera on <host>\n  ✓ speakers       left and right heard\n\n1 passed, 0 failed, 1 skipped' "$text"
printf '{"id": "keyboard-backlight-key", "result": "pass", "detail": "level 2 to 0 and back", "finished": 300}\n' >"$state/attended/keyboard-backlight-key.json"
text=$(LC_ALL=C OMARCHY_ROLLCALL_ROOT=$fake OMARCHY_ROLLCALL_STATE=$state PATH="$stub_bin:$ROOT/bin:$PATH" "$ROOT/bin/omarchy-rollcall" 2>/dev/null)
expect "a long walkthrough name widens the column for every row" \
  $'  ✓ time                    synchronised\n  ✓ keyboard-backlight-key  level 2 to 0 and back' \
  "$(grep -E '^  . (keyboard-backlight-key|time) ' <<<"$text")"
rm "$state/attended/keyboard-backlight-key.json"
status=0
rollcall >/dev/null || status=$?
expect "a walkthrough with nothing failed exits 0" "0" "$status"
printf '{"id": "speakers", "result": "fail", "detail": "the right speaker is silent", "finished": 300}\n' >"$state/attended/speakers.json"
status=0
rollcall >/dev/null || status=$?
expect "a failed walkthrough test fails the roll call" "1" "$status"
rm -r "$state"

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
