# The GU605CX ALC285 headphone output pops when idle HDA power saving kicks in.
# Keeping HDA powered avoids the pop, at the cost of increased idle power use.
# Only the pause/resume case has been verified; boot and shutdown are untested.

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
# These driver-wide options also affect other HDA controllers on this laptop.
options snd_hda_intel power_save=0 power_save_controller=N
EOF
chmod 644 "$audio_temp"
ln -T -- "$audio_temp" "$audio_config"
ROOT
  fi
fi
