#!/bin/bash

# Preserve the model's current mask, enabling only the Bluetooth hotkey.
mask_path=/sys/devices/platform/thinkpad_acpi/hotkey_mask
if [[ -e $mask_path ]]; then
  if current=$(cat "$mask_path" 2>/dev/null); then
    printf '%#x\n' "$((current | 0x00100000))" | tee "$mask_path" >/dev/null || true
  fi
fi
