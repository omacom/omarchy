#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

require_command jq

TMPDIR=$(mktemp -d)
trap 'rm -rf "$TMPDIR"' EXIT

catalog="$ROOT/default/omarchy/devices.json"
sys="$TMPDIR/sys"
drivers="$TMPDIR/drivers"
stub_bin="$TMPDIR/bin"
mkdir -p "$sys" "$drivers" "$stub_bin"

# pacman answers from a list of installed packages, lpstat from a list of
# queues, so readiness is decided by the test rather than the machine.
INSTALLED="$TMPDIR/installed"
QUEUES="$TMPDIR/queues"
: >"$INSTALLED"
: >"$QUEUES"

cat >"$stub_bin/pacman" <<'SH'
#!/bin/bash
[[ $1 == "-Q" ]] || exit 1
shift
[[ ${1:-} == "--" ]] && shift
for pkg in "$@"; do
  grep -Fxq -- "$pkg" "$INSTALLED" || exit 1
done
SH

cat >"$stub_bin/lpstat" <<'SH'
#!/bin/bash
cat "$QUEUES"
SH

# The machine running the tests has its own fingerprint reader, or none, and its
# own PAM stack: both answer from the test.
PLATFORM_FINGERPRINT="$TMPDIR/platform-fingerprint"
PAM_SUDO="$TMPDIR/pam-sudo"
: >"$PAM_SUDO"
cat >"$stub_bin/omarchy-hw-fingerprint" <<'SH'
#!/bin/bash
[[ -e $PLATFORM_FINGERPRINT ]]
SH
APPLE_LAPTOP="$TMPDIR/apple-laptop"
cat >"$stub_bin/omarchy-hw-aarch64-apple" <<'SH'
#!/bin/bash
[[ -e $APPLE_LAPTOP ]]
SH
cp "$stub_bin/omarchy-hw-aarch64-apple" "$stub_bin/omarchy-hw-laptop"
export PLATFORM_FINGERPRINT APPLE_LAPTOP
export OMARCHY_PAM_SUDO="$PAM_SUDO"

chmod +x "$stub_bin/pacman" "$stub_bin/lpstat" "$stub_bin/omarchy-hw-fingerprint" "$stub_bin/omarchy-hw-aarch64-apple" "$stub_bin/omarchy-hw-laptop"

# make_device <name> <vendor> <product> <manufacturer> <product-name> <serial>
#   then interfaces as "class/sub/proto:driver[:interface-name]" (driver - for none)
make_device() {
  local name=$1 vendor=$2 product=$3 manufacturer=$4 product_name=$5 serial=$6 n=0 spec
  shift 6
  local dev="$sys/$name"
  mkdir -p "$dev"
  echo "$vendor" >"$dev/idVendor"
  echo "$product" >"$dev/idProduct"
  echo "00" >"$dev/bDeviceClass"
  [[ -n $manufacturer ]] && echo "$manufacturer" >"$dev/manufacturer"
  [[ -n $product_name ]] && echo "$product_name" >"$dev/product"
  [[ -n $serial ]] && echo "$serial" >"$dev/serial"

  for spec in "$@"; do
    local class=${spec%%:*} rest=${spec#*:} driver intf_name=""
    driver=${rest%%:*}
    [[ $rest == *:* ]] && intf_name=${rest#*:}
    local intf="$dev/$name:1.$((n++))"
    mkdir -p "$intf"
    IFS=/ read -r c s p <<<"$class"
    echo "$c" >"$intf/bInterfaceClass"
    echo "$s" >"$intf/bInterfaceSubClass"
    echo "$p" >"$intf/bInterfaceProtocol"
    [[ -n $intf_name ]] && echo "$intf_name" >"$intf/interface"
    if [[ $driver != "-" ]]; then
      mkdir -p "$drivers/$driver"
      ln -s "$drivers/$driver" "$intf/driver"
    fi
  done
}

detect() {
  PATH="$stub_bin:$ROOT/bin:$PATH" \
  INSTALLED="$INSTALLED" QUEUES="$QUEUES" \
  OMARCHY_USB_DEVICES_PATH="$sys" \
  OMARCHY_DEVICE_CATALOG="$catalog" \
    "$ROOT/bin/omarchy-device-detect" "$@"
}

device_json() {
  detect "$sys/$1"
}

# The catalog is what every guide reads, so it has to parse and every guide has
# to say something and offer some way forward.
jq -e 'type == "object"' "$catalog" >/dev/null || fail "devices.json parses as an object"
problems=$(jq -r '
  to_entries[]
  | select((.value.title | type) != "string"
      or (.value.summary | type) != "string"
      or ((.value.steps // []) | length) == 0
      or ((.value.url // "https://") | startswith("https://") | not)
      or ((.value.download // "https://") | startswith("https://") | not))
  | .key' "$catalog")
[[ -z $problems ]] || fail "every device guide has a title, summary and steps, and only https links" "$problems"
pass "every device guide has a title, summary and steps, and only https links"

roles_without_guide=$(for role in printer scanner camera iphone smartcard serial displaylink fingerprint unknown; do
  jq -e --arg role "$role" 'has($role)' "$catalog" >/dev/null || echo "$role"
done)
[[ -z $roles_without_guide ]] || fail "every role the detector reports has a general guide" "$roles_without_guide"
pass "every role the detector reports has a general guide"

# The case behind this: an Epson L380 is not driverless. Its printer interface
# lacks IPP-USB and its scanner sits on a vendor-specific interface no kernel
# driver binds.
make_device 1-1 04b8 1120 EPSON "L380 Series" X33Q "ff/ff/ff:-" "07/01/02:usblp"
epson=$(device_json 1-1)
[[ $(jq -c .roles <<<"$epson") == '["printer","scanner"]' ]] ||
  fail "an Epson multifunction printer is a printer and a scanner" "$epson"
[[ $(jq -c .guides <<<"$epson") == '["printer.04b8","scanner.04b8"]' ]] ||
  fail "an Epson multifunction printer gets the Epson guides" "$epson"
[[ $(jq -r .name <<<"$epson") == "EPSON L380 Series" && $(jq -r .id <<<"$epson") == "04b8:1120" && $(jq -r .key <<<"$epson") == "04b8:1120:X33Q" ]] ||
  fail "a device is named and keyed by what it reports" "$epson"
[[ $(jq -r .ready <<<"$epson") == "false" ]] || fail "a printer with nothing installed is not ready" "$epson"
pass "an Epson multifunction printer is a printer and a scanner with the Epson guides"

printf '%s\n' epson-inkjet-printer-escpr sane simple-scan >"$INSTALLED"
[[ $(device_json 1-1 | jq -r .ready) == "false" ]] ||
  fail "a printer with its driver but no queue is not ready yet"
echo "device for L380: usb://EPSON/L380%20Series?serial=X33Q" >"$QUEUES"
[[ $(device_json 1-1 | jq -r .ready) == "true" ]] ||
  fail "a printer with its driver and a queue for its serial is ready"
echo "device for Other: usb://EPSON/L380%20Series?serial=SOMEONE-ELSE" >"$QUEUES"
[[ $(device_json 1-1 | jq -r .ready) == "false" ]] ||
  fail "a queue for another printer of the same model does not make this one ready"
: >"$INSTALLED"
: >"$QUEUES"
pass "a printer is ready only once its driver is installed and it has a queue of its own"

make_device 1-2 03f0 0001 HP "LaserJet MFP" S1 "07/01/04:-" "ff/ff/ff:-"
hp=$(device_json 1-2)
[[ $(jq -c .guides <<<"$hp") == '["printer.ipp"]' ]] ||
  fail "an IPP-USB printer gets the driverless guide ahead of its vendor's" "$hp"
pass "an IPP-USB printer gets the driverless guide ahead of its vendor's"

make_device 1-3 04f9 0002 Brother "MFC" S2 "07/01/04:-" "ff/ff/ff:-"
[[ $(device_json 1-3 | jq -c .guides) == '["printer.ipp","scanner.ipp"]' ]] ||
  fail "an IPP-USB multifunction printer scans driverless too"
pass "an IPP-USB multifunction printer scans driverless too"

make_device 1-4 046d c52b Logitech "USB Receiver" "" "03/01/01:usbhid" "03/01/02:usbhid"
make_device 1-5 0781 5581 SanDisk Ultra S3 "08/06/50:usb-storage"
make_device 1-6 046d 085c Logitech "C922 Webcam" "" "0e/01/00:uvcvideo" "0e/02/00:uvcvideo" "ff/ff/ff:-"
make_device 1-7 18d1 4ee1 Google Pixel S4 "ff/ff/00:-:MTP"
mkdir -p "$sys/usb1"
echo 1d6b >"$sys/usb1/idVendor"
echo 0002 >"$sys/usb1/idProduct"
echo 09 >"$sys/usb1/bDeviceClass"
for quiet in 1-4 1-5 1-6 1-7 usb1; do
  [[ -z $(device_json "$quiet") ]] || fail "a device that works out of the box is not reported: $quiet" "$(device_json "$quiet")"
done
pass "keyboards, storage, webcams, phones in file-transfer mode and hubs are not reported"

make_device 1-8 05ac 12a8 Apple iPhone S5 "06/01/01:-" "ff/fe/02:-"
[[ $(device_json 1-8 | jq -c .roles) == '["iphone"]' ]] || fail "an iPhone is an iPhone, not a camera"
make_device 1-9 04a9 3218 Canon "EOS" S6 "06/01/01:-"
[[ $(device_json 1-9 | jq -c .roles) == '["camera"]' ]] || fail "a PTP camera is a camera"
make_device 1-10 1a86 7523 "" "USB Serial" "" "ff/01/02:ch341"
[[ $(device_json 1-10 | jq -c .roles) == '["serial"]' ]] || fail "a CH340 adapter is a serial device"
make_device 1-11 2341 0043 Arduino Uno S7 "02/02/01:cdc_acm" "0a/00/00:cdc_acm"
[[ $(device_json 1-11 | jq -c .roles) == '["serial"]' ]] || fail "a CDC ACM board is a serial device"
make_device 1-12 08e6 3437 Gemalto "Card Reader" "" "0b/00/00:-"
[[ $(device_json 1-12 | jq -c .roles) == '["smartcard"]' ]] || fail "a CCID reader is a smart card reader"
make_device 1-13 17e9 6000 DisplayLink Dock S8 "ff/00/00:-" "ff/00/00:-"
[[ $(device_json 1-13 | jq -c .roles) == '["displaylink"]' ]] || fail "a DisplayLink dock is a DisplayLink device"
make_device 1-14 27c6 538d Goodix "" "" "ff/00/00:-"
[[ $(device_json 1-14 | jq -c .roles) == '["fingerprint"]' ]] || fail "a Goodix reader is a fingerprint reader, not a device without a driver"
make_device 1-20 04f3 0c4b "" "ELAN:ARM-M4" "" "ff/00/00:-"
[[ $(device_json 1-20 | jq -c .roles) == '["fingerprint"]' ]] || fail "an Elan match-on-chip reader is a fingerprint reader"
make_device 1-21 10a5 9800 "" "FPC Sensor Controller" "" "ff/00/00:-"
[[ $(device_json 1-21 | jq -c .roles) == '["fingerprint"]' ]] || fail "a Fingerprint Cards reader is a fingerprint reader"
make_device 1-27 2808 1234 FocalTech "FT9365 ESS" "" "ff/00/00:-"
[[ $(device_json 1-27 | jq -c .roles) == '["fingerprint"]' ]] || fail "FocalTech readers get the fingerprint guide"
make_device 1-15 04b8 0142 EPSON "Perfection V600" S9 "ff/ff/ff:-"
[[ $(device_json 1-15 | jq -c .guides) == '["scanner.04b8"]' ]] || fail "a standalone Epson scanner gets the Epson scanner guide"
make_device 1-16 abcd 1234 Acme Widget S10 "ff/00/00:-"
widget=$(device_json 1-16)
[[ $(jq -c .roles <<<"$widget") == '["unknown"]' ]] || fail "a device the kernel bound nothing to is reported as needing a driver" "$widget"
make_device 1-17 abcd 5678 Acme Gadget S11 "ff/00/00:usbfs"
[[ $(device_json 1-17 | jq -c .roles) == '["unknown"]' ]] ||
  fail "an app holding a device through usbfs is not a kernel driver"
pass "phones, cameras, serial boards, smart cards, docks, fingerprint readers, scanners and driverless devices get their guides"

make_device 1-18 2109 0103 VIA "USB Billboard Device" S12 "11/00/00:-"
make_device 1-19 18d1 4ee7 Google Pixel S13 "ff/42/01:-"
make_device 1-20 04e8 6860 SAMSUNG "SAMSUNG_Android" S14 "06/01/01:-:MTP" "ff/42/01:-"
make_device 1-21 1050 0407 Yubico "YubiKey OTP+FIDO+CCID" "" "03/01/01:usbhid" "03/00/00:usbhid" "0b/00/00:-"
make_device 1-22 05ac 8600 Apple iBridge "" "0e/01/01:uvcvideo" "ff/fe/02:-"
make_device 1-23 8087 095a Intel "L850-GL" "" "02/0e/00:cdc_mbim" "0a/00/02:cdc_mbim" "02/02/01:cdc_acm"
for quiet in 1-18 1-19 1-20 1-21 1-22 1-23; do
  [[ -z $(device_json "$quiet") ]] || fail "a device that needs nothing is not reported: $quiet" "$(device_json "$quiet")"
done
mkdir -p "$sys/1-24"
echo 2109 >"$sys/1-24/idVendor"
echo 8884 >"$sys/1-24/idProduct"
echo 11 >"$sys/1-24/bDeviceClass"
[[ -z $(device_json 1-24) ]] || fail "a Billboard device is not reported"
pass "Billboards, phones offering ADB or MTP, YubiKeys, a Mac's T2 bridge and cellular modems are not reported"

make_device 1-25 abcd 9999 "" "-t" "" "ff/00/00:-"
[[ $(device_json 1-25 | jq -r .name) == "t" ]] || fail "a device name cannot start with a dash" "$(device_json 1-25)"
pass "a device name cannot start with a dash"

printf '%s\n' epson-inkjet-printer-escpr sane simple-scan >"$INSTALLED"
make_device 1-26 04b8 1120 EPSON "L380 Series" X33 "ff/ff/ff:-" "07/01/02:usblp"
echo "device for L380: usb://EPSON/L380%20Series?serial=X33Q" >"$QUEUES"
[[ $(device_json 1-26 | jq -r .ready) == "false" ]] || fail "a serial that only starts another printer's does not count as its queue"
echo "device for L380: usb://EPSON/L380%20Series?serial=X33&interface=1" >"$QUEUES"
[[ $(device_json 1-26 | jq -r .ready) == "true" ]] || fail "a queue for the whole serial counts"
printf '%s\n' sane simple-scan >"$INSTALLED"
[[ $(device_json 1-26 | jq -r .ready) == "true" ]] || fail "an existing queue for this serial also covers vendor-installed drivers"
rm -rf "$sys/1-26"
: >"$QUEUES"
pass "a printer's queue must carry its whole serial"

echo pcsclite >"$INSTALLED"
[[ $(device_json 1-12 | jq -r .ready) == "false" ]] || fail "a smart card reader missing ccid is not ready"
[[ $(device_json 1-16 | jq -r .ready) == "false" ]] || fail "a device without a driver is never ready"
: >"$INSTALLED"
pass "readiness needs every package of the guide"

# Setup > Devices lists what still needs something, by name, with the target
# omarchy-setup-device takes.
menu_rows=$(detect --menu)
grep -Fxq $'EPSON L380 Series\t04b8:1120' <<<"$menu_rows" || fail "the devices menu lists a printer that needs a driver" "$menu_rows"
grep -Fq "Logitech" <<<"$menu_rows" && fail "the devices menu leaves out what works"
pass "the devices menu lists connected devices that still need something"

# A reader the platform drives without USB, like a Mac's Touch ID once Linux
# supports it, is found by the full scan and set up through its role -- unless
# a USB reader already stands for it.
platform_menu() {
  PATH="$stub_bin:$ROOT/bin:$PATH" INSTALLED="$INSTALLED" QUEUES="$QUEUES" \
    OMARCHY_USB_DEVICES_PATH="$1" OMARCHY_DEVICE_CATALOG="$catalog" \
    "$ROOT/bin/omarchy-device-detect" --menu
}
mkdir -p "$TMPDIR/no-usb"
touch "$PLATFORM_FINGERPRINT"
[[ $(platform_menu "$TMPDIR/no-usb") == $'Fingerprint reader\tplatform:fingerprint' ]] ||
  fail "a platform fingerprint reader that is not set up is listed" "$(platform_menu "$TMPDIR/no-usb")"
[[ $(platform_menu "$sys" | grep -c Fingerprint) == 0 ]] ||
  fail "a USB fingerprint reader is not listed twice" "$(platform_menu "$sys")"
echo "auth sufficient pam_fprintd.so" >"$PAM_SUDO"
echo fprintd >"$INSTALLED"
[[ -z $(platform_menu "$TMPDIR/no-usb") ]] || fail "a platform fingerprint reader in use is not listed"
: >"$PAM_SUDO"
: >"$INSTALLED"
[[ -z $(detect "$sys/1-1" | jq -r 'select(.key == "platform:fingerprint")') ]] ||
  fail "checking one device does not add the platform reader"
rm "$PLATFORM_FINGERPRINT"

# Touch ID on an Apple Silicon laptop has nothing to install yet: it is listed
# under Other so it is no mystery, and kept off the list of things to set up.
platform_other() {
  PATH="$stub_bin:$ROOT/bin:$PATH" INSTALLED="$INSTALLED" QUEUES="$QUEUES" \
    OMARCHY_USB_DEVICES_PATH="$1" OMARCHY_DEVICE_CATALOG="$catalog" \
    "$ROOT/bin/omarchy-device-detect" --menu-other
}
touch "$APPLE_LAPTOP"
[[ $(platform_other "$TMPDIR/no-usb") == $'Touch ID\tplatform:touchid' ]] ||
  fail "Touch ID on an Apple Silicon laptop is listed under Other" "$(platform_other "$TMPDIR/no-usb")"
[[ -z $(platform_menu "$TMPDIR/no-usb") ]] || fail "Touch ID is not listed among devices to set up"
grep -q EPSON <<<"$(platform_other "$sys")" && fail "a device with something to install is not listed under Other"
touch "$PLATFORM_FINGERPRINT"
[[ -z $(platform_other "$TMPDIR/no-usb") ]] || fail "a fingerprint reader Linux drives is not listed as Touch ID"
rm "$PLATFORM_FINGERPRINT" "$APPLE_LAPTOP"
pass "Touch ID on an Apple Silicon laptop is listed under Other and nowhere else"
pass "a platform fingerprint reader is listed until fingerprint login is set up"

all=$(detect)
[[ $(grep -c . <<<"$all") == "$(jq -s 'length' <<<"$all")" ]] || fail "without arguments, every device prints one JSON line"
grep -q '"04b8:1120' <<<"$all" || fail "without arguments, the bus directory is scanned"
grep -q '1-1:1' <<<"$(jq -r .path <<<"$all")" && fail "interfaces in the bus directory are not reported as devices"
pass "without arguments, every device on the bus is checked once"

# The watcher: a device is announced once, only when it is not ready, and only
# a delivered toast counts.
watch_home="$TMPDIR/watch-home"
NOTIFY_LOG="$TMPDIR/notify-log"
NOTIFY_FAIL="$TMPDIR/notify-fail"
mkdir -p "$watch_home"
: >"$NOTIFY_LOG"

cat >"$stub_bin/omarchy-notification-send" <<'SH'
#!/bin/bash
[[ -e $NOTIFY_FAIL ]] && exit 1
printf '%s\n' "$*" >>"$NOTIFY_LOG"
SH
cat >"$stub_bin/omarchy-notification-wait" <<'SH'
#!/bin/bash
exit 0
SH
# Replays the events in $UDEV_EVENTS (none by default), then ends, so the
# watcher runs its login check and whatever those events start, and waits for
# them.
UDEV_EVENTS="$TMPDIR/udev-events"
: >"$UDEV_EVENTS"
cat >"$stub_bin/udevadm" <<'SH'
#!/bin/bash
cat "$UDEV_EVENTS"
SH
chmod +x "$stub_bin/omarchy-notification-send" "$stub_bin/omarchy-notification-wait" "$stub_bin/udevadm"

run_watch() {
  PATH="$stub_bin:$ROOT/bin:$PATH" \
  HOME="$watch_home" \
  XDG_STATE_HOME="$watch_home/.local/state" \
  XDG_CONFIG_HOME="$watch_home/.config" \
  INSTALLED="$INSTALLED" QUEUES="$QUEUES" \
  NOTIFY_LOG="$NOTIFY_LOG" NOTIFY_FAIL="$NOTIFY_FAIL" \
  OMARCHY_USB_DEVICES_PATH="$sys" \
  OMARCHY_DEVICE_CATALOG="$catalog" \
  UDEV_EVENTS="$UDEV_EVENTS" \
  OMARCHY_SYSFS_ROOT="$sys" \
  OMARCHY_DEVICE_SETTLE_SECONDS=0 \
  OMARCHY_DEVICE_REPLUG_SECONDS="${REPLUG_SECONDS:-60}" \
    "$ROOT/bin/omarchy-device-watch"
}

# Only the Epson, so the expected toasts stay readable.
mv "$sys" "$TMPDIR/sys-all"
mkdir -p "$sys"
mv "$TMPDIR/sys-all/1-1" "$sys/"

state="$watch_home/.local/state/omarchy/devices"
age_last_toast() {
  touch -d '2 minutes ago' "$state"/recent-* 2>/dev/null || true
}

touch "$NOTIFY_FAIL"
run_watch
[[ ! -s $NOTIFY_LOG ]] || fail "a failed toast is not logged"
compgen -G "$state/recent-*" >/dev/null &&
  fail "a toast that was never delivered does not hold the next one back"
rm "$NOTIFY_FAIL"

run_watch
grep -Fq "EPSON L380 Series Printer and scanner detected. Click to see how to set them up. --exec omarchy-launch-floating-terminal-with-presentation omarchy-setup-device 04b8:1120" "$NOTIFY_LOG" ||
  fail "a printer needing a driver is announced with a click that opens its guide" "$(cat "$NOTIFY_LOG")"
pass "a device that needs software is announced with a click that opens its guide"

# Until it is set up, it keeps asking: at every login, and every time it is
# plugged in -- though not twice for a loose cable.
age_last_toast
run_watch
[[ $(grep -c . "$NOTIFY_LOG") == 2 ]] || fail "a device that still needs software is announced at every login" "$(cat "$NOTIFY_LOG")"
pass "a device that still needs software is announced at every login"

printf 'ACTION=add\nDEVPATH=/1-1\n\nACTION=bind\nDEVPATH=/1-1\n\n' >"$UDEV_EVENTS"
mv "$sys/1-1" "$TMPDIR/unplugged"
age_last_toast
run_watch
mv "$TMPDIR/unplugged" "$sys/1-1"
[[ $(grep -c . "$NOTIFY_LOG") == 2 ]] || fail "an event for a device already gone announces nothing" "$(cat "$NOTIFY_LOG")"
run_watch
[[ $(grep -c . "$NOTIFY_LOG") == 3 ]] || fail "plugging in a device that still needs software announces it" "$(cat "$NOTIFY_LOG")"
run_watch
[[ $(grep -c . "$NOTIFY_LOG") == 3 ]] || fail "a device replugged within a minute is not announced twice" "$(cat "$NOTIFY_LOG")"
# With no window, the login check and the plug event both announce it.
REPLUG_SECONDS=0 run_watch
[[ $(grep -c . "$NOTIFY_LOG") == 5 ]] || fail "a device replugged later is announced again" "$(cat "$NOTIFY_LOG")"
: >"$UDEV_EVENTS"
pass "plugging in a device that still needs software announces it, once a minute at most"

: >"$NOTIFY_LOG"
age_last_toast
printf '%s\n' epson-inkjet-printer-escpr sane simple-scan >"$INSTALLED"
echo "usb://EPSON/L380%20Series?serial=X33Q" >"$QUEUES"
printf 'ACTION=bind\nDEVPATH=/1-1\n\n' >"$UDEV_EVENTS"
run_watch
: >"$UDEV_EVENTS"
[[ ! -s $NOTIFY_LOG ]] || fail "a device that is already set up is not announced" "$(cat "$NOTIFY_LOG")"
pass "a device that is already set up is not announced, at login or when plugged in"

: >"$NOTIFY_LOG"
: >"$INSTALLED"
: >"$QUEUES"
mv "$sys" "$TMPDIR/sys-epson"
mkdir -p "$sys"
touch "$APPLE_LAPTOP"
rm -f "$state"/recent-*
run_watch
rm "$APPLE_LAPTOP"
rmdir "$sys"
mv "$TMPDIR/sys-epson" "$sys"
[[ ! -s $NOTIFY_LOG ]] || fail "hardware with nothing to install yet is never announced" "$(cat "$NOTIFY_LOG")"
pass "hardware with nothing to install yet is never announced"

# The guide itself, with gum answering for the user: it names the device, numbers
# each guide's steps, lists every option it can install, and offers both halves
# of a printer that scans in one menu.
GUM_LOG="$TMPDIR/gum-log"
GUM_ANSWERS="$TMPDIR/gum-answers"
GUM_CONFIRM="$TMPDIR/gum-confirm"
: >"$GUM_LOG"
: >"$GUM_ANSWERS"
cat >"$stub_bin/gum" <<'SH'
#!/bin/bash
# choose answers from $GUM_ANSWERS line by line, then "Done"; confirm says yes
# while $GUM_CONFIRM exists.
case $1 in
style) shift; while [[ $1 == --* ]]; do [[ $1 == "--bold" ]] && shift || shift 2; done; printf '%s\n' "$@" ;;
choose)
  shift
  [[ $1 == "--header" ]] && shift 2
  printf '%s\n' "$@" >>"$GUM_LOG"
  answer=Done
  if [[ -s $GUM_ANSWERS ]]; then
    answer=$(head -n 1 "$GUM_ANSWERS")
    sed -i 1d "$GUM_ANSWERS"
  fi
  echo "$answer"
  ;;
confirm) [[ -e $GUM_CONFIRM ]] ;;
esac
SH
chmod +x "$stub_bin/gum"
: >"$INSTALLED"
: >"$QUEUES"

guide=$(PATH="$stub_bin:$ROOT/bin:$PATH" \
  INSTALLED="$INSTALLED" QUEUES="$QUEUES" GUM_LOG="$GUM_LOG" GUM_ANSWERS="$GUM_ANSWERS" GUM_CONFIRM="$GUM_CONFIRM" \
  OMARCHY_USB_DEVICES_PATH="$sys" \
  OMARCHY_DEVICE_CATALOG="$catalog" \
    "$ROOT/bin/omarchy-setup-device" 04b8:1120)
for expected in "EPSON L380 Series" "USB 04b8:1120" "Epson printer" "Epson scanner" "1. Choose Install and set up" "2. If it can't match" "Epson ESC/P-R driver (AUR)" "Gutenprint (Arch repositories)" "Download the driver from Epson" "SANE and Document Scanner (Arch repositories)"; do
  grep -Fq -- "$expected" <<<"$guide" || fail "the device guide shows: $expected" "$guide"
done
for expected in "Install and set up" "Open Print Settings" "Open Document Scanner" "Done"; do
  grep -Fxq -- "$expected" "$GUM_LOG" || fail "the device guide offers: $expected" "$(cat "$GUM_LOG")"
done
pass "the device guide shows every guide for the device and one menu for all of them"

: >"$GUM_LOG"
general=$(PATH="$stub_bin:$ROOT/bin:$PATH" \
  INSTALLED="$INSTALLED" QUEUES="$QUEUES" GUM_LOG="$GUM_LOG" GUM_ANSWERS="$GUM_ANSWERS" GUM_CONFIRM="$GUM_CONFIRM" \
  OMARCHY_USB_DEVICES_PATH="$TMPDIR/no-devices" \
  OMARCHY_DEVICE_CATALOG="$catalog" \
    "$ROOT/bin/omarchy-setup-device" printer)
grep -Fq "Printers made in the last ten years" <<<"$general" ||
  fail "with no printer connected, Setup > Devices > Printer shows the general printer guide" "$general"
pass "with no printer connected, the general printer guide is shown"

status=0
(
  cd "$TMPDIR"
  PATH="$stub_bin:$ROOT/bin:$PATH" OMARCHY_DEVICE_CATALOG="$catalog" \
    "$ROOT/bin/omarchy-setup-device" '$(touch pwned)' >/dev/null 2>&1
) || status=$?
((status == 1)) || fail "the guide refuses an argument that is neither a role nor a device id"
[[ ! -e $TMPDIR/pwned ]] || fail "the guide never evaluates its argument"
pass "the guide refuses an argument that is neither a role nor a device id"

# Connected lists only devices that still need something.
: >"$GUM_LOG"
printf '%s\n' epson-inkjet-printer-escpr sane simple-scan >"$INSTALLED"
echo "usb://EPSON/L380%20Series?serial=X33Q" >"$QUEUES"
connected=$(PATH="$stub_bin:$ROOT/bin:$PATH" \
  INSTALLED="$INSTALLED" QUEUES="$QUEUES" GUM_LOG="$GUM_LOG" GUM_ANSWERS="$GUM_ANSWERS" GUM_CONFIRM="$GUM_CONFIRM" \
  OMARCHY_USB_DEVICES_PATH="$sys" \
  OMARCHY_DEVICE_CATALOG="$catalog" \
    "$ROOT/bin/omarchy-setup-device")
grep -Fq "Every connected device works" <<<"$connected" ||
  fail "Connected leaves out a device that is already set up" "$connected"
pass "Connected leaves out a device that is already set up"

# Install and set up: a choice for each half, every time, then one summary and
# one confirmation, then the driver, the app to use it, and the CUPS queue.
INSTALL_LOG="$TMPDIR/install-log"
: >"$INSTALL_LOG"
: >"$INSTALLED"
: >"$QUEUES"
for cmd in omarchy-pkg-add omarchy-pkg-aur-add lpadmin udevadm-real; do
  cat >"$stub_bin/$cmd" <<SH
#!/bin/bash
echo "$cmd \$*" >>"\$INSTALL_LOG"
SH
  chmod +x "$stub_bin/$cmd"
done
cat >"$stub_bin/sudo" <<'SH'
#!/bin/bash
[[ $1 == "udevadm" ]] && { shift; exec udevadm-real "$@"; }
exec "$@"
SH
cat >"$stub_bin/lpinfo" <<'SH'
#!/bin/bash
case $* in
*-v*)
  echo "direct usb://EPSON/L380%20Series?serial=X33QZ&interface=1"
  echo "direct usb://EPSON/L380%20Series?serial=X33Q&interface=1"
  ;;
*-m*)
  echo "gutenprint.5.3://escp2-l375/expert Epson L375 - CUPS+Gutenprint v5.3.5"
  echo "gutenprint.5.3://escp2-l380/expert Epson L380 - CUPS+Gutenprint v5.3.5"
  echo "lsb/usr/epson-inkjet-printer-escpr/Epson-L380_Series-epson-escpr-en.ppd Epson L380 Series, Epson Inkjet Printer Driver (ESC/P-R) for Linux"
  ;;
esac
SH
chmod +x "$stub_bin/sudo" "$stub_bin/lpinfo"

printf '%s\n' "Install and set up" "Epson ESC/P-R driver (AUR)" "SANE and Document Scanner (Arch repositories)" \
  "1. Epson L380 Series, Epson Inkjet Printer Driver (ESC/P-R) for Linux" >"$GUM_ANSWERS"
touch "$GUM_CONFIRM"
: >"$GUM_LOG"
installing=$(PATH="$stub_bin:$ROOT/bin:$PATH" \
  INSTALLED="$INSTALLED" QUEUES="$QUEUES" GUM_LOG="$GUM_LOG" GUM_ANSWERS="$GUM_ANSWERS" GUM_CONFIRM="$GUM_CONFIRM" \
  INSTALL_LOG="$INSTALL_LOG" \
  OMARCHY_USB_DEVICES_PATH="$sys" \
  OMARCHY_DEVICE_CATALOG="$catalog" \
    "$ROOT/bin/omarchy-setup-device" 04b8:1120 2>&1)
grep -Fxq "Skip" "$GUM_LOG" || fail "every option list offers Skip" "$(cat "$GUM_LOG")"
grep -Fq "From the AUR, built from community-maintained recipes: epson-inkjet-printer-escpr" <<<"$installing" ||
  fail "the summary says what comes from the AUR before anything is installed" "$installing"
expected_log="omarchy-pkg-add sane simple-scan
omarchy-pkg-aur-add epson-inkjet-printer-escpr
lpadmin -p EPSON_L380_Series -E -v usb://EPSON/L380%20Series?serial=X33Q&interface=1 -m lsb/usr/epson-inkjet-printer-escpr/Epson-L380_Series-epson-escpr-en.ppd"
[[ $(grep -v '^udevadm-real\|^lpadmin -d' "$INSTALL_LOG") == "$expected_log" ]] ||
  fail "installing a printer that scans brings in the driver, Document Scanner and the printer's queue" "$(cat "$INSTALL_LOG")"
grep -Fq "udevadm-real trigger --action=add --settle $sys/1-1" "$INSTALL_LOG" ||
  fail "the scanner can be used without unplugging it" "$(cat "$INSTALL_LOG")"
grep -Fxq "2. Epson L380 - CUPS+Gutenprint v5.3.5" "$GUM_LOG" ||
  fail "every installed driver that names the model is offered, the chosen option's first" "$(cat "$GUM_LOG")"
pass "Install and set up asks for each half, then installs the driver, the app and the printer's queue"

# A second L380 already has the plain queue name: this one gets its own queue
# instead of taking that one over.
: >"$INSTALL_LOG"
echo "device for EPSON_L380_Series: usb://EPSON/L380%20Series?serial=OTHER&interface=1" >"$QUEUES"
printf '%s\n' "Install and set up" "Epson ESC/P-R driver (AUR)" "Skip" \
  "1. Epson L380 Series, Epson Inkjet Printer Driver (ESC/P-R) for Linux" >"$GUM_ANSWERS"
PATH="$stub_bin:$ROOT/bin:$PATH" \
  INSTALLED="$INSTALLED" QUEUES="$QUEUES" GUM_LOG="$GUM_LOG" GUM_ANSWERS="$GUM_ANSWERS" GUM_CONFIRM="$GUM_CONFIRM" \
  INSTALL_LOG="$INSTALL_LOG" \
  OMARCHY_USB_DEVICES_PATH="$sys" \
  OMARCHY_DEVICE_CATALOG="$catalog" \
    "$ROOT/bin/omarchy-setup-device" 04b8:1120 >/dev/null 2>&1
grep -Fq "lpadmin -p EPSON_L380_Series_X33Q -E" "$INSTALL_LOG" ||
  fail "a second printer of the same model gets a queue of its own" "$(cat "$INSTALL_LOG")"
grep -q "lpadmin -p EPSON_L380_Series " "$INSTALL_LOG" &&
  fail "another printer's queue is left alone" "$(cat "$INSTALL_LOG")"
: >"$QUEUES"
pass "a second printer of the same model gets a queue of its own"

# An HP that scans over IPP-USB is offered the driverless guide only, so
# choosing its scanning option has to bring in the scanner software too.
: >"$INSTALL_LOG"
printf '%s\n' "Install and set up" \
  "Driverless printing and scanning with ipp-usb, sane-airscan and Document Scanner, for a printer that scans (Arch repositories)" >"$GUM_ANSWERS"
PATH="$stub_bin:$ROOT/bin:$PATH" \
  INSTALLED="$INSTALLED" QUEUES="$QUEUES" GUM_LOG="$GUM_LOG" GUM_ANSWERS="$GUM_ANSWERS" GUM_CONFIRM="$GUM_CONFIRM" \
  INSTALL_LOG="$INSTALL_LOG" \
  OMARCHY_USB_DEVICES_PATH="$TMPDIR/sys-all" \
  OMARCHY_DEVICE_CATALOG="$catalog" \
    "$ROOT/bin/omarchy-setup-device" 03f0:0001 >/dev/null 2>&1
grep -Fxq "omarchy-pkg-add ipp-usb sane-airscan simple-scan" "$INSTALL_LOG" ||
  fail "an HP that scans over IPP-USB gets its scanner software from the driverless guide" "$(cat "$INSTALL_LOG")"
pass "an HP that scans over IPP-USB gets its scanner software from the driverless guide"

# Two printers of the same model are two rows, and each opens itself.
: >"$GUM_LOG"
twin_sys=$sys
sys="$TMPDIR/twins"
make_device 1-1 abcd 1234 Acme Widget S1 "ff/00/00:-"
make_device 1-2 abcd 1234 Acme Widget S2 "ff/00/00:-"
sys=$twin_sys
printf '%s\n' "2. Acme Widget  (abcd:1234:S2)" >"$GUM_ANSWERS"
twins=$(PATH="$stub_bin:$ROOT/bin:$PATH" \
  INSTALLED="$INSTALLED" QUEUES="$QUEUES" GUM_LOG="$GUM_LOG" GUM_ANSWERS="$GUM_ANSWERS" GUM_CONFIRM="$GUM_CONFIRM" \
  OMARCHY_USB_DEVICES_PATH="$TMPDIR/twins" \
  OMARCHY_DEVICE_CATALOG="$catalog" \
    "$ROOT/bin/omarchy-setup-device")
grep -Fq "serial S2" <<<"$twins" || fail "the device picked is the one opened" "$twins"
pass "two devices of the same model can each be picked"

# Epson Scan 2, once chosen, is offered next to Document Scanner.
: >"$GUM_LOG"
: >"$GUM_ANSWERS"
printf '%s\n' epsonscan2 >"$INSTALLED"
PATH="$stub_bin:$ROOT/bin:$PATH" \
  INSTALLED="$INSTALLED" QUEUES="$QUEUES" GUM_LOG="$GUM_LOG" GUM_ANSWERS="$GUM_ANSWERS" GUM_CONFIRM="$GUM_CONFIRM" \
  OMARCHY_USB_DEVICES_PATH="$sys" \
  OMARCHY_DEVICE_CATALOG="$catalog" \
    "$ROOT/bin/omarchy-setup-device" 04b8:1120 >/dev/null
grep -Fxq "Open Epson Scan 2" "$GUM_LOG" || fail "the app of the installed option is offered" "$(cat "$GUM_LOG")"
: >"$INSTALLED"
pass "the app of the installed option is offered"

: >"$INSTALL_LOG"
rm "$GUM_CONFIRM"
printf '%s\n' "Install and set up" "Gutenprint (Arch repositories)" "Skip" >"$GUM_ANSWERS"
PATH="$stub_bin:$ROOT/bin:$PATH" \
  INSTALLED="$INSTALLED" QUEUES="$QUEUES" GUM_LOG="$GUM_LOG" GUM_ANSWERS="$GUM_ANSWERS" GUM_CONFIRM="$GUM_CONFIRM" \
  INSTALL_LOG="$INSTALL_LOG" \
  OMARCHY_USB_DEVICES_PATH="$sys" \
  OMARCHY_DEVICE_CATALOG="$catalog" \
    "$ROOT/bin/omarchy-setup-device" 04b8:1120 >/dev/null 2>&1
[[ ! -s $INSTALL_LOG ]] || fail "nothing is installed when the summary is declined" "$(cat "$INSTALL_LOG")"
pass "nothing is installed when the summary is declined"

# Touch ID opens by its key from Setup > Devices > Other, and says why there is
# nothing to install.
: >"$GUM_ANSWERS"
: >"$GUM_LOG"
touch "$APPLE_LAPTOP"
touchid=$(PATH="$stub_bin:$ROOT/bin:$PATH" \
  INSTALLED="$INSTALLED" QUEUES="$QUEUES" GUM_LOG="$GUM_LOG" GUM_ANSWERS="$GUM_ANSWERS" GUM_CONFIRM="$GUM_CONFIRM" \
  OMARCHY_USB_DEVICES_PATH="$TMPDIR/no-usb" \
  OMARCHY_DEVICE_CATALOG="$catalog" \
    "$ROOT/bin/omarchy-setup-device" platform:touchid)
rm "$APPLE_LAPTOP"
grep -Fq "Linux can't use Touch ID" <<<"$touchid" || fail "the Touch ID guide explains why there is nothing to install" "$touchid"
grep -Fxq "Install and set up" "$GUM_LOG" && fail "the Touch ID guide offers nothing to install"
pass "Touch ID opens by its key and explains why there is nothing to install"
