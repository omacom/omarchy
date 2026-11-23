# HP EliteBook X G2i and X Flip G2i: four TAS2783A speaker amps and an OV05C10
# webcam. The kernel support ships in linux-omarchy. These packages add the
# Speaker device, guards against the amps enumerating late at boot, and the
# camera stack (Intel CamHAL on the hardware ISP, libcamera's software ISP as
# the fallback).

if omarchy-hw-hp-elitebook-x-g2i; then
  omarchy-pkg-add hp-elitebook-x-g2i-audio

  # The DSDT declares three camera sensors the machine does not have, so
  # require the OV05C10 to be present per ACPI _STA, not merely declared.
  if omarchy-hw-acpi-present OVTI05C1; then
    # Older installs got intel-ipu7-camera for a declared-but-absent sensor.
    # It conflicts with the camera package, and pacman --noconfirm answers a
    # conflict prompt with no, so retire it first.
    omarchy-pkg-drop intel-ipu7-camera
    omarchy-pkg-add hp-elitebook-x-g2i-camera
  fi
fi
