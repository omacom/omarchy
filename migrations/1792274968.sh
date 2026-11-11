echo "Install PipeWire's JACK and GStreamer plugins on ARM"

# x86_64 gets pipewire-jack and gst-plugin-pipewire from the ISO
# (install/omarchy-other.packages). ARM installs have no ISO, so they got
# neither, and the first package that needs jack (obs-studio, ffmpeg, mpv,
# portaudio) pulled in jack2 instead of PipeWire's implementation.
if ! omarchy-hw-aarch64; then
  exit 0
fi

omarchy-pkg-add gst-plugin-pipewire

# An owner who installed a JACK server on purpose keeps it; only one pulled in
# as a dependency is replaced. pipewire-jack provides jack, so the swap is one
# transaction, and --ask=4 answers pacman's conflict question with yes, which
# omarchy-pkg-add cannot (see 1786952219.sh).
if omarchy-pkg-missing pipewire-jack; then
  # Captured, not piped: grep -q quitting early would SIGPIPE pacman under
  # pipefail. jack2-dbus needs jack2 by name, and pipewire-jack-client runs on it.
  explicit=$(pacman -Qqe)
  if ! grep -Fxq -e jack -e jack2 <<<"$explicit" &&
    ! omarchy-pkg-present jack2-dbus && ! omarchy-pkg-present pipewire-jack-client; then
    sudo pacman -S --noconfirm --needed --ask=4 pipewire-jack
  fi
fi
