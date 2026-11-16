# Snapdragon firmware an OEM signs for one board (audio and compute DSP, GPU,
# video), from the omarchy-pkgs package made for that machine.
#
# Each package provides qcom-firmware-<folder> for the firmware folders it
# fills. The folders come from the firmware the device tree still lacks and
# from what qcom-firmware-extract copied from Windows (its manifest), so a
# machine set up from Windows moves to its package too; qcom-firmware-extract's
# retire hook then removes the Windows copies the package covers. The deepest
# folder goes first: a folder two machines share, like the Surfaces' GPU
# firmware, is then already filled by the package the machine's own folder
# brought in. This runs before qualcomm/firmware.sh, which copies from Windows
# only what is still missing.

if omarchy-hw-aarch64-qualcomm; then
  manifest=${OMARCHY_QCOM_FIRMWARE_MANIFEST:-/var/lib/omarchy/qcom-firmware/manifest}
  while IFS= read -r folder; do
    name="qcom-firmware-${folder#qcom/}"
    name=${name//\//-}
    name=${name,,}
    if ! pacman -T "$name" >/dev/null && package=$(pacman -Sp --print-format %n "$name" 2>/dev/null); then
      omarchy-pkg-add "$package"
    fi
  done < <(
    {
      qcom-firmware-extract --list-missing
      if [[ -r $manifest ]]; then
        cut -d' ' -f1 "$manifest"
      fi
    } | sed 's|/[^/]*$||' | sort -u | awk -F/ '{ print NF "\t" $0 }' | sort -rn | cut -f2
  )
fi
