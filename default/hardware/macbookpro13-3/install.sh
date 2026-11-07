#!/bin/bash
# SPDX-License-Identifier: GPL-2.0-only
# Fresh installation only. Never initiates suspend, reboot or a hardware write.
set -euo pipefail
export PATH=/usr/bin:/usr/sbin
[[ $EUID == 0 ]] || { echo "Administrator privileges required." >&2; exit 1; }
[[ $(</sys/class/dmi/id/product_name) == "MacBookPro13,3" ]] || exit 1
base=$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)
target=/usr/local/libexec/omarchy-macbookpro13-3
src=/usr/src/macbook-ec-wake-0.1
dropin=/etc/systemd/system/systemd-suspend.service.d/60-omarchy-macbookpro13-3.conf
policy=/etc/systemd/sleep.conf.d/60-omarchy-macbookpro13-3.conf
manifest=$target/files.sha256
files=("$src/Makefile" "$src/macbook_ec_wake_trial.c" "$src/dkms.conf"
  "$target/suspend" "$target/unpark.py" "$target/resume" "$dropin" "$policy")

active=$(systemctl show systemd-suspend.service -p ActiveState --value)
[[ $active == "inactive" && ! -e /run/macbook-suspend/state ]] || {
  echo "Suspend must be inactive with no pending controller recovery." >&2; exit 1;
}

case ${1:-} in
  install)
    # Refuse earlier community installations and runtime trials. Never stack hooks.
    for path in "$src" "$target" "$dropin" "$policy" /var/lib/dkms/macbook-ec-wake \
      /usr/local/sbin/macbook-suspend /usr/local/libexec/macbook-touchbar \
      /run/macbook-suspend-trial /run/macbook-touchbar-trial; do
      [[ ! -e $path && ! -L $path ]] || {
        echo "Already exists; refusing to overwrite or combine: $path" >&2; exit 1;
      }
    done
    for property in ExecStartPre ExecStopPost; do
      commands=$(systemctl show systemd-suspend.service -p "$property" --value)
      [[ -z $commands ]] || {
        echo "Existing suspend hooks need manual review before installation." >&2; exit 1;
      }
    done
    [[ -d /usr/lib/modules/$(uname -r)/build ]] || {
      echo "Install headers matching the running kernel first." >&2; exit 1;
    }
    command -v dkms >/dev/null
    bash "$base/persistent-sleep/macbook-suspend" check
    /usr/bin/python3 -I "$base/touchbar/unpark.py"
    rollback() {
      local result=$?
      trap - EXIT
      if (( result != 0 )); then
        echo "Installation failed; removing only files added by this attempt." >&2
        [[ ! -e $dropin ]] || unlink "$dropin"
        systemctl daemon-reload || true
        if [[ -d /var/lib/dkms/macbook-ec-wake/0.1 ]]; then
          dkms remove -m macbook-ec-wake -v 0.1 --all || true
        fi
        for path in "${files[@]}" "$manifest"; do
          [[ ! -e $path ]] || unlink "$path"
        done
        rmdir "$src" "$target" 2>/dev/null || true
      fi
      exit "$result"
    }
    trap rollback EXIT
    install -d -m755 "$src"
    install -d -m700 "$target"
    install -m644 "$base/ec-wake-trial/Makefile" "$base/ec-wake-trial/macbook_ec_wake_trial.c" "$src/"
    install -m644 "$base/persistent-sleep/dkms.conf" "$src/dkms.conf"
    dkms add -m macbook-ec-wake -v 0.1
    dkms build -m macbook-ec-wake -v 0.1 -k "$(uname -r)"
    dkms install -m macbook-ec-wake -v 0.1 -k "$(uname -r)"
    modinfo -k "$(uname -r)" macbook_ec_wake_trial >/dev/null
    install -m700 "$base/persistent-sleep/macbook-suspend" "$target/suspend"
    install -m700 "$base/touchbar/resume" "$target/resume"
    install -m600 "$base/touchbar/unpark.py" "$target/unpark.py"
    install -Dm644 "$base/suspend.conf" "$dropin"
    install -Dm644 "$base/persistent-sleep/60-macbook-s2idle.conf" "$policy"
    systemctl daemon-reload
    systemd-analyze verify systemd-suspend.service
    commands=$(systemctl show systemd-suspend.service -p ExecStartPre --value)
    [[ $commands == *"$target/suspend pre"* ]] || {
      echo "Missing suspend preparation hook; reverting installation." >&2; exit 1;
    }
    commands=$(systemctl show systemd-suspend.service -p ExecStopPost --value)
    [[ $commands == *"$target/suspend post"*"$target/resume"* ]] || {
      echo "Unexpected recovery order; reverting installation." >&2; exit 1;
    }
    # Later sleep.conf settings must not silently put this sequence into deep sleep.
    sleep_settings=$(systemd-analyze cat-config systemd/sleep.conf)
    effective=$(awk '
      /^[[:space:]]*\[/ { section = $0 }
      section ~ /^[[:space:]]*\[Sleep\]/ && /^[[:space:]]*(MemorySleepMode|SuspendState)[[:space:]]*=/ {
        key = $0; sub(/[[:space:]]*=.*/, "", key); sub(/^[[:space:]]*/, "", key)
        sub(/^[^=]*=[[:space:]]*/, ""); sub(/[[:space:]]*$/, ""); value[key] = $0
      }
      END { print value["SuspendState"]; print value["MemorySleepMode"] }
    ' <<< "$sleep_settings")
    [[ $effective == $'mem\ns2idle' ]] || {
      echo "A competing sleep policy overrides s2idle; reverting installation." >&2; exit 1;
    }
    sha256sum "${files[@]}" > "$manifest"
    trap - EXIT
    echo "Installed sleep and Touch Bar recovery. No suspend or reboot was initiated."
    echo "Test an attended undocked lid cycle, then repeat after reboot."
    echo "Remove with: omarchy setup macbookpro13-3 remove"
    ;;
  remove)
    [[ -f $manifest && ! -L $manifest ]] || { echo "No installation manifest." >&2; exit 1; }
    current=$(sha256sum "${files[@]}")
    [[ $current == "$(<"$manifest")" ]] || {
      echo "Installed files changed; refusing removal." >&2; exit 1;
    }
    unlink "$dropin"
    systemctl daemon-reload
    dkms remove -m macbook-ec-wake -v 0.1 --all
    for path in "${files[@]}" "$manifest"; do [[ ! -e $path ]] || unlink "$path"; done
    rmdir "$src" "$target"
    echo "Removed the workaround and its sleep policy. Reboot to clear the EC wake mark."
    echo "Wi-Fi, audio, NVMe, T1Bridge and keyboard settings were retained."
    ;;
  *) echo "Usage: $0 install|remove" >&2; exit 2 ;;
esac
