# Snapdragon firmware an OEM signs for one board (audio and compute DSP, GPU,
# video), from the omarchy-pkgs package made for that machine.
#
# Each package provides qcom-firmware-<folder> for the firmware folders it
# fills, so the folders the device tree still lacks firmware in name the
# packages to install. The deepest folder goes first: a folder two machines
# share, like the Surfaces' GPU firmware, is then already filled by the package
# the machine's own folder brought in. This runs before qualcomm/firmware.sh,
# which copies from Windows only what is still missing.

if omarchy-hw-aarch64-qualcomm; then
  while IFS= read -r folder; do
    name="qcom-firmware-${folder#qcom/}"
    name=${name//\//-}
    name=${name,,}
    if ! pacman -T "$name" >/dev/null && package=$(pacman -Sp --print-format %n "$name" 2>/dev/null); then
      omarchy-pkg-add "$package"
    fi
  done < <(qcom-firmware-extract --list-missing | sed 's|/[^/]*$||' | sort -u | awk -F/ '{ print NF "\t" $0 }' | sort -rn | cut -f2)
fi
