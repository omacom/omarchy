echo "Enable targeted AMD SoundWire recovery after resume"

[[ -e /proc/asound/amdsoundwire ]] || exit 0

systemctl --user daemon-reload
systemctl --user enable --now omarchy-amd-soundwire-resume.service
