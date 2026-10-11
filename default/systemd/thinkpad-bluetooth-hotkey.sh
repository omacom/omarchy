#!/bin/bash

# Preserve the model's current mask, enabling only the Bluetooth hotkey.
mask_path=/sys/devices/platform/thinkpad_acpi/hotkey_mask
if [[ -e $mask_path ]]; then
  if current=$(cat "$mask_path" 2>/dev/null); then
    if [[ $current =~ ^0[xX][0-9a-fA-F]+$ ]]; then
      if ! printf '%#x\n' "$((current | 0x00100000))" | tee "$mask_path" >/dev/null; then
        printf 'Warning: failed to write ThinkPad hotkey mask to %s\n' "$mask_path" >&2
      fi
    else
      printf 'Warning: invalid hexadecimal ThinkPad hotkey mask in %s\n' "$mask_path" >&2
    fi
  else
    printf 'Warning: failed to read ThinkPad hotkey mask from %s\n' "$mask_path" >&2
  fi
fi
