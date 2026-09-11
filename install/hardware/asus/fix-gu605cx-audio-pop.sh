# The GU605CX ALC285 headphone output pops when idle HDA power saving kicks in.
# Keeping the codec powered avoids the pop, but may increase idle power use.
# Idle pops are fixed; shutdown pops persist and boot popping is unverified.

if omarchy-hw-asus-gu605cx-alc285; then
  audio_config="/etc/modprobe.d/omarchy-asus-gu605cx-audio.conf"

  # Preserve administrator overrides, including symlinks and empty opt-out files.
  if [[ ! -e $audio_config && ! -L $audio_config ]]; then
    sudo bash -eu <<'ROOT'
audio_config="/etc/modprobe.d/omarchy-asus-gu605cx-audio.conf"
mkdir -p /etc/modprobe.d

# Publish only a complete file so a failed write can be retried by the migration.
audio_temp=$(mktemp /etc/modprobe.d/.omarchy-asus-gu605cx-audio.XXXXXX)
trap 'rm -f "$audio_temp"' EXIT
cat > "$audio_temp" <<'EOF'
# Avoid idle HDA power transitions that pop on ASUS GU605CX headphone outputs.
# This driver-wide option also applies to other HDA controllers on this laptop.
# Leave controller power-saving policy unchanged; disabling codec idle saving is enough.
options snd_hda_intel power_save=0
EOF
chmod 644 "$audio_temp"
ln -T -- "$audio_temp" "$audio_config"
ROOT
  fi
fi
