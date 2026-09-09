# The MacBookPro13,3 BCM43602 can load the stock binary firmware without its
# board NVRAM, but then miss 5 GHz networks and fail WPA handshakes on 2.4 GHz.
# Installing this board configuration restored 5 GHz on that model with
# 7.35.177.61 firmware. Keep the match narrow: a shared chip ID does not imply
# the same RF wiring/calibration on other Macs or non-Apple boards.
# Source: https://gist.github.com/MikeRatcliffe/9614c16a8ea09731a9d5e91685bd8c80
# Fetch a pinned, verified revision rather than redistributing the board data.
(
  sys_vendor=$(cat /sys/class/dmi/id/sys_vendor 2>/dev/null || true)
  product_name=$(cat /sys/class/dmi/id/product_name 2>/dev/null || true)
  if [[ $sys_vendor != Apple* || $product_name != "MacBookPro13,3" ]]; then
    return 0
  fi

  for device in /sys/bus/pci/devices/*; do
    [[ -d $device ]] || continue
    if [[ $(cat "$device/vendor") == "0x14e4" && $(cat "$device/device") == "0x43ba" &&
      $(cat "$device/subsystem_vendor") == "0x106b" && $(cat "$device/subsystem_device") == "0x015a" ]]; then
      firmware_dir=/usr/lib/firmware/brcm
      target="$firmware_dir/brcmfmac43602-pcie.Apple Inc.-MacBookPro13,3.txt"
      # Respect administrator and package-provided NVRAM, including compressed
      # files and symlinks. Reapplying hardware setup must preserve the MAC.
      for existing in "$target" "$target.zst" "$target.xz" \
        "$firmware_dir/brcmfmac43602-pcie.txt"{,.zst,.xz}; do
        if [[ -e $existing || -L $existing ]]; then
          return 0
        fi
      done

      scratch=$(mktemp -d)
      trap 'rm -rf "$scratch"' EXIT
      curl --fail --silent --show-error --location --retry 2 --connect-timeout 10 --max-time 60 \
        https://gist.githubusercontent.com/MikeRatcliffe/9614c16a8ea09731a9d5e91685bd8c80/raw/bd7af7c6f01df3ccee1471d36cb8df15d618a6aa/brcmfmac43602-pcie.txt \
        -o "$scratch/nvram"
      echo "b109f3e6663b0e888c2559e36f7e0109f2a3a6b9765786d11f849f16d4b32d06  $scratch/nvram" | sha256sum --check --status

      # The stock firmware can report a shared Broadcom placeholder address.
      # Use a per-install locally administered unicast MAC in that case, or
      # when setup runs without a bound network interface.
      macaddr=$(cat "$device"/net/*/address 2>/dev/null || true)
      if [[ ! $macaddr =~ ^([[:xdigit:]]{2}:){5}[[:xdigit:]]{2}$ || $macaddr == "00:90:4c:0d:f4:3e" ]]; then
        macaddr="02$(od -An -N5 -tx1 /dev/urandom | tr -d '\n' | tr ' ' ':')"
      fi
      sed "s/^macaddr=.*/macaddr=$macaddr/" "$scratch/nvram" > "$scratch/board.txt"
      install -Dm644 "$scratch/board.txt" "$target"
      echo "Installed MacBookPro13,3 BCM43602 board NVRAM; applies on the next boot"
      # Do not reload the driver: installation may be using this Wi-Fi link.
      break
    fi
  done
)
