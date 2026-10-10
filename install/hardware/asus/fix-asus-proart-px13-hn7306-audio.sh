# Fix microphone and speakers on the ASUS ProArt PX13 HN7306 (Strix Halo).
#
# Stock installs of alsa-ucm-conf (as of 1.2.16.1) ship no UCM data for the
# TAS2783 speaker amp used on this board's amd-soundwire card. UCM import
# for the whole card fails as a result (not just the speaker), which takes
# the microphone and headphone paths down with it and leaves PipeWire with
# no real audio device at all -- only its dummy fallback.
#
# The three files below are the already-merged upstream fix
# (alsa-project/alsa-ucm-conf#812), plus explicit PlaybackChannels/Rate/
# Format on the Speaker device: this board's SmartAmp PCM only accepts
# S16_LE/2ch/48000Hz (no ranges), and PipeWire's ACP profile probe defaults
# to a different format/rate before falling back, which fails outright on
# a PCM that offers no alternative to fall back to.
#
# Even with UCM fixed, ACP still can't bring up the "HiFi" profile here: it
# bundles the Speaker and Headphones ports into one sink mapping, and the
# rt721 "SimpleJack" headphone PCM fails to open at the driver level
# (unrelated to UCM, and unrelated to whether a jack is physically
# plugged in) on this board's current SOF/soundwire driver stack. One
# broken port takes the whole profile down with it, including the mic.
# Until that driver issue is fixed upstream, this uses the "pro-audio"
# profile instead, which exposes each working port independently and
# tolerates the broken one.
#
# Under "pro-audio", UCM's Speaker EnableSequence never runs (pro-audio
# talks to raw ALSA devices directly, bypassing UCM device enable/disable),
# so the amp's four hardware enable switches (Left/Right Spk[2] Switch)
# come up off and stay off -- not just at boot, but after every WirePlumber
# restart, since each restart re-probes and re-activates the profile the
# same way. A systemd drop-in re-applies them after every WirePlumber
# start, once its own profile activation has settled (setting them too
# early gets them reset right back to off by that activation). This is
# safe with respect to user mute preferences: it only touches this
# hardware enable gate, which has no exposure in any mute UI on this
# card -- actual user mute (volume slider, mute key) is PipeWire's own
# per-sink software Mute/Volume, a separate layer WirePlumber already
# persists correctly on its own and which this never touches.

if omarchy-hw-asus-proart-px13-hn7306; then
  sudo install -Dm644 /dev/stdin /usr/share/alsa/ucm2/codecs/tas2783/init.conf <<'EOF'
# tas2783 specific switch control settings

BootSequence [
	cset "name='Left Spk' on"
	cset "name='Right Spk' on"
	cset "name='Left Spk2' on"
	cset "name='Right Spk2' on"
]
EOF

  sudo install -Dm644 /dev/stdin /usr/share/alsa/ucm2/sof-soundwire/tas2783.conf <<'EOF'
# Use case Configuration for sof-soundwire card

SectionDevice."Speaker" {
	Comment	"Speaker"

	EnableSequence [
		cset "name='Left Spk Switch' on"
		cset "name='Right Spk Switch' on"
		cset "name='Left Spk2 Switch' on"
		cset "name='Right Spk2 Switch' on"
	]

	DisableSequence [
		cset "name='Left Spk Switch' off"
		cset "name='Right Spk Switch' off"
		cset "name='Left Spk2 Switch' off"
		cset "name='Right Spk2 Switch' off"
	]

	Value {
	      PlaybackPriority 100
	      PlaybackPCM "hw:${CardId},2"
	      PlaybackChannels 2
	      PlaybackRate 48000
	      PlaybackFormat "S16_LE"
	}
}
EOF

  # Adds tas2783 to the speaker-codec filter regex, matching alsa-ucm-conf#812
  # as merged (the reviewer asked for tas2783 to stay out of MultiCodecRegex,
  # since it defines only a Speaker device, not a multi-function codec, so
  # only this one line changes). Exact string replace, not sed, to avoid any
  # ambiguity from the heavy regex-special-character content of this line.
  sudo python3 - <<'EOF'
path = "/usr/share/alsa/ucm2/sof-soundwire/sof-soundwire.conf"
old = '\t\t\tRegex "(${var:MultiCodecRegex}|rt1318|cs42l43-spk(\\+cs35l56)?|cs35l56((-bridge)|(\\+cs42l43-spk))?)"\n'
new = '\t\t\tRegex "(${var:MultiCodecRegex}|tas2783|rt1318|cs42l43-spk(\\+cs35l56)?|cs35l56((-bridge)|(\\+cs42l43-spk))?)"\n'
with open(path) as f:
    content = f.read()
if new not in content:
    if content.count(old) != 1:
        raise SystemExit(
            f"expected exactly 1 occurrence of the unpatched line, found {content.count(old)} "
            "-- sof-soundwire.conf may differ from the version this fix was written against, skipping"
        )
    with open(path, "w") as f:
        f.write(content.replace(old, new, 1))
EOF

  mkdir -p ~/.config/wireplumber/wireplumber.conf.d
  cat > ~/.config/wireplumber/wireplumber.conf.d/asus-proart-px13-hn7306-audio.conf <<'EOF'
## Friendly port names for the amd-soundwire card on the ASUS ProArt PX13
## HN7306, and hiding its non-functional amp-telemetry capture channel.
## The card only reports a generic "Audio Coprocessor" description, so
## pro-audio's raw port names default to "Audio Coprocessor Pro N".

monitor.alsa.rules = [
  {
    matches = [
      { node.name = "alsa_output.pci-0000_c4_00.5-platform-amd_sdw.pro-output-0" }
    ]
    actions = { update-props = { node.description = "PX13 Headphones" node.nick = "Headphones" } }
  }
  {
    matches = [
      { node.name = "alsa_output.pci-0000_c4_00.5-platform-amd_sdw.pro-output-2" }
    ]
    actions = { update-props = { node.description = "PX13 Speakers" node.nick = "Speakers" } }
  }
  {
    matches = [
      { node.name = "alsa_input.pci-0000_c4_00.5-platform-amd_sdw.pro-input-1" }
    ]
    actions = { update-props = { node.description = "PX13 Headset Microphone" node.nick = "Headset Mic" } }
  }
  {
    ## pro-input-3 is the tas2783 amp's internal feedback/telemetry capture
    ## channel (speaker protection DSP), not a real microphone, and it is
    ## unreliable to stream from. Hide it from mic pickers entirely.
    matches = [
      { node.name = "alsa_input.pci-0000_c4_00.5-platform-amd_sdw.pro-input-3" }
    ]
    actions = { update-props = { node.description = "PX13 Speaker Amp Reference (internal)" node.disabled = true } }
  }
  {
    matches = [
      { node.name = "alsa_input.pci-0000_c4_00.5-platform-amd_sdw.pro-input-4" }
    ]
    actions = { update-props = { node.description = "PX13 Internal Microphone" node.nick = "Internal Mic" } }
  }
]
EOF

  mkdir -p ~/.config/systemd/user/wireplumber.service.d
  cat > ~/.config/systemd/user/wireplumber.service.d/asus-proart-px13-hn7306-speaker-enable.conf <<'EOF'
[Service]
ExecStartPost=/bin/bash -c 'sleep 3; for c in "Left Spk Switch" "Right Spk Switch" "Left Spk2 Switch" "Right Spk2 Switch"; do amixer -c amdsoundwire cset iface=MIXER,name="$c" on; done'
EOF
  systemctl --user daemon-reload

  for control in "Left Spk Switch" "Right Spk Switch" "Left Spk2 Switch" "Right Spk2 Switch"; do
    amixer -c amdsoundwire cset iface=MIXER,name="$control" on >/dev/null
  done
  sudo alsactl store

  systemctl --user try-restart wireplumber.service
fi
