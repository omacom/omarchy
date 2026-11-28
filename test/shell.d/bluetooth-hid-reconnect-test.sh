#!/bin/bash

set -euo pipefail

source "$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)/base-test.sh"

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT

MAC=DF:EF:A2:67:98:30
MAC2=C0:11:22:33:44:55
HOG=00001812-0000-1000-8000-00805f9b34fb
AUDIO=0000110b-0000-1000-8000-00805f9b34fb

# A fresh fake world: one bluetooth rfkill switch, a powered adapter, no devices
setup() {
  T=$(mktemp -d "$tmp_dir/case.XXXXXX")
  mkdir -p "$T/bin" "$T/rfkill/rfkill0"
  echo bluetooth >"$T/rfkill/rfkill0/type"
  echo 0 >"$T/rfkill/rfkill0/soft"
  echo 0 >"$T/rfkill/rfkill0/hard"
  echo yes >"$T/powered"
  : >"$T/paired"
  : >"$T/calls"
  : >"$T/input"

  # The fake bluetoothctl logs every call and answers from files in $T
  cat >"$T/bin/bluetoothctl" <<EOF
#!/bin/bash
echo "\$*" >>"$T/calls"
case \$1 in
  show)
    [[ ! -f "$T/monitor-dies" ]] || /usr/bin/sleep 0.05
    echo "Controller 38:F9:D3:D6:67:F7 (public)"; echo "	Powered: \$(<"$T/powered")" ;;
  devices) cat "$T/paired" ;;
  info) cat "$T/info_\$2" 2>/dev/null ;;
  connect)
    if [[ -f "$T/untrust-on-connect" ]]; then
      target=\$(<"$T/untrust-on-connect")
      sed -i 's/Trusted: yes/Trusted: no/' "$T/info_\$target"
    fi
    if [[ -s "$T/sequence" ]]; then
      IFS= read -r response <"$T/sequence"
      sed -i '1d' "$T/sequence"
      if [[ \$response == "Connection successful" ]]; then
        printf 'U: Uniq=%s\n' "\$2" >>"$T/input"
      fi
      echo "\$response"
    else
      cat "$T/connect_\$2" 2>/dev/null || echo "Failed to connect: org.bluez.Error.Failed"
    fi
    ;;
  power)
    if [[ \$2 == "on" && -f "$T/power-on-fails" ]]; then
      rm "$T/power-on-fails"
      exit 1
    fi
    echo "Changing \$* succeeded" ;;
  disconnect) echo "Changing \$* succeeded" ;;
esac
EOF
  # No real waiting in tests
  printf '#!/bin/bash\nexit 0\n' >"$T/bin/sleep"
  cat >"$T/bin/udevadm" <<EOF
#!/bin/bash
[[ ! -f "$T/monitor-dies" ]] || exit 0
exec /usr/bin/sleep 60
EOF
  chmod +x "$T/bin/bluetoothctl" "$T/bin/sleep" "$T/bin/udevadm"
}

# pair <address> <trusted> <blocked> <connected> <uuid>
pair() {
  # bluetoothctl colours this line even into a pipe; keep the escape codes in
  printf '\033[1;30mDevice %s Some Device\033[0m\n' "$1" >>"$T/paired"
  printf 'Device %s (random)\n\tTrusted: %s\n\tBlocked: %s\n\tConnected: %s\n\tUUID: Something (%s)\n' \
    "$1" "$2" "$3" "$4" "$5" >"$T/info_$1"
}

# input_device <address> <name>
input_device() {
  printf 'I: Bus=0005 Vendor=046d Product=b034 Version=0006\nN: Name="%s"\nU: Uniq=%s\n\n' \
    "$2" "${1,,}" >>"$T/input"
}

run() {
  PATH="$T/bin:$PATH" \
    OMARCHY_BLUETOOTH_HID_RECONNECT_INPUT_DEVICES="$T/input" \
    OMARCHY_BLUETOOTH_HID_RECONNECT_RFKILL_DIR="$T/rfkill" \
    OMARCHY_BLUETOOTH_HID_RECONNECT_ONESHOT=1 \
    "$@" "$ROOT/bin/omarchy-bluetooth-hid-reconnect" >"$T/out" 2>&1
}

called() {
  grep -qxF -- "$1" "$T/calls"
}

expect() {
  local description=$1
  shift

  if "$@"; then
    pass "$description"
  else
    fail "$description" "calls: $(tr '\n' '|' <"$T/calls")
output: $(tr '\n' '|' <"$T/out")"
  fi
}

not() {
  ! "$@"
}

run_loop() {
  local status=0
  run timeout 3 env OMARCHY_BLUETOOTH_HID_RECONNECT_ONESHOT=0 || status=$?
  expect "the reconnect loop stays running" test "$status" -eq 124
}

setup
pair $MAC yes no no $HOG
input_device $MAC "Logitech MX Master 3S"
run env
expect "a present device is left alone" not called "connect $MAC"
expect "no scan runs while every device is present" not called "--timeout 45 scan le"

setup
pair $MAC yes no no $HOG
input_device $MAC "MX Master 3S"
run env
expect "a device is matched by its address, not its name" not called "connect $MAC"
expect "a present device is never disconnected" not called "disconnect $MAC"

setup
pair $MAC yes no no $HOG
run env
expect "a missing LE HID device gets a connect" called "connect $MAC"
expect "an LE scan runs alongside the connect" called "--timeout 45 scan le"

setup
pair $MAC no no no $HOG
run env
expect "an untrusted device is ignored" not called "connect $MAC"

setup
pair $MAC yes no no $AUDIO
run env
expect "a device without HID is ignored" not called "connect $MAC"

setup
pair $MAC yes no no $HOG
echo 1 >"$T/rfkill/rfkill0/soft"
run env
expect "Bluetooth turned off by rfkill: bluetoothctl is never called" test ! -s "$T/calls"

setup
pair $MAC yes no no $HOG
echo no >"$T/powered"
run env
expect "a powered-off adapter gets no connect" not called "connect $MAC"
expect "a powered-off adapter is never powered back on" not called "power on"

setup
pair $MAC yes no yes $HOG
run env
expect "a fresh link with no input device yet is not dropped inside the grace period" not called "disconnect $MAC"
expect "a fresh link with no input device yet gets no connect inside the grace period" not called "connect $MAC"

setup
pair $MAC yes no yes $HOG
run env OMARCHY_BLUETOOTH_HID_RECONNECT_STALE_GRACE=0
expect "a stale link past the grace period is dropped" called "disconnect $MAC"
expect "a stale link past the grace period is reconnected" called "connect $MAC"

setup
pair $MAC yes no no $HOG
pair $MAC2 yes no no $HOG
echo "Failed to connect: org.bluez.Error.InProgress" >"$T/connect_$MAC"
echo "Failed to connect: org.bluez.Error.InProgress" >"$T/connect_$MAC2"
run env
expect "two InProgress results power the adapter off" called "power off"
expect "two InProgress results power the adapter back on" called "power on"

setup
pair $MAC yes no no $HOG
printf '%s\n' 'Failed to connect: org.bluez.Error.InProgress' 'Failed to connect: org.bluez.Error.InProgress' 'Connection successful' >"$T/sequence"
touch "$T/power-on-fails"
run_loop
expect "a failed power-on is retried during recovery" test "$(grep -cx 'power on' "$T/calls")" -eq 2

setup
pair $MAC yes no no $HOG
printf '%s\n' 'Failed to connect: org.bluez.Error.InProgress' 'Failed to connect: org.bluez.Error.Failed' 'Failed to connect: org.bluez.Error.InProgress' 'Connection successful' >"$T/sequence"
run_loop
expect "an ordinary failure breaks the run of InProgress results" not called "power off"

setup
touch "$T/monitor-dies"
run_loop
expect "reconnect passes continue after the monitor exits" test "$(grep -cx 'show' "$T/calls")" -gt 1

setup
pair $MAC yes no no $HOG
pair $MAC2 yes no no $HOG
input_device $MAC "MX Master 3S"
run env
expect "with two devices, only the missing one gets a connect" called "connect $MAC2"
expect "with two devices, the present one is left alone" not called "connect $MAC"

setup
pair $MAC yes no no $HOG
pair $MAC2 yes no no $HOG
echo "$MAC2" >"$T/untrust-on-connect"
run env
expect "a device untrusted during an earlier connect is skipped" not called "connect $MAC2"

# The hardware predicate: an Apple vendor and a controller on hci_uart_bcm
hw() {
  local vendor=$1 driver=$2 dir="$tmp_dir/hw.$RANDOM"

  mkdir -p "$dir/bluetooth/hci0/device" "$dir/drivers/$driver"
  echo "$vendor" >"$dir/sys_vendor"
  ln -s "$dir/drivers/$driver" "$dir/bluetooth/hci0/device/driver"
  OMARCHY_HW_DMI_VENDOR="$dir/sys_vendor" OMARCHY_HW_BLUETOOTH_DIR="$dir/bluetooth" \
    "$ROOT/bin/omarchy-hw-apple-uart-bluetooth"
}

expect "the predicate matches a Mac with hci_uart_bcm" hw "Apple Inc." hci_uart_bcm
expect "the predicate rejects a Mac with other Bluetooth" not hw "Apple Inc." btusb
expect "the predicate rejects hci_uart_bcm on a non-Mac" not hw "Dell Inc." hci_uart_bcm
