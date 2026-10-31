# The Framework Laptop 13 AMD Ryzen AI 300 firmware exposes an ACP capture
# device (acp-pdm-mach) that only ever produces DC garbage, and the Realtek
# ALC285's shipped HDA UCM profile makes the *headset* jack the default source
# while labelling the broken ACP path "Digital Microphone". Turning UCM off for
# the card makes WirePlumber fall back to the generic analog profile, whose
# default source is the working internal microphone -- and leaves the ACP
# drivers loaded, so nothing else about the machine changes.
# The rule is scoped to the card by name; the install is gated on the exact DMI
# so it only ever ships to this model.
# See FrameworkComputer/SoftwareFirmwareIssueTracker#166.
omarchy_framework13_ai300_mic_matched=0
omarchy_framework13_ai300_mic_changed=0

config_home="${XDG_CONFIG_HOME:-$HOME/.config}"
mic_conf="${OMARCHY_FRAMEWORK13_AI300_MIC_CONF:-$config_home/wireplumber/wireplumber.conf.d/50-framework13-ai300-no-ucm.conf}"

sys_vendor="${OMARCHY_DMI_SYS_VENDOR:-/sys/class/dmi/id/sys_vendor}"
product_name="${OMARCHY_DMI_PRODUCT_NAME:-/sys/class/dmi/id/product_name}"

# Live WirePlumber state, used to decide whether the rule still needs applying.
# Reading the running card instead of this script's write is what keeps the
# migration from restarting audio a second time once the rule is already in
# effect. The status is read into a variable before parsing, and no consumer
# exits early, so `wpctl status` is never killed by SIGPIPE -- which `pipefail`
# would otherwise turn into a failure after the matching id had already been
# found.
omarchy_framework13_ai300_mic_device_id() {
  local status
  status=$(wpctl status 2>/dev/null) || return 1
  awk '
    /Ryzen HD Audio Controller/ && /\[alsa\]/ {
      for (i = 1; i <= NF; i++)
        if (!found && $i ~ /^[0-9]+\.$/) { id = $i; found = 1 }
    }
    END { if (found) print id }
  ' <<<"$status" | tr -d '.'
}

omarchy_framework13_ai300_mic_card_present() {
  [[ -n $(omarchy_framework13_ai300_mic_device_id) ]]
}

# The card's api.alsa.use-ucm property, read from the running card rather than
# inferred from a capture source: with UCM off that source may not exist at all
# when the user has saved an output-only or disabled profile, so requiring it
# would report the rule as unapplied even when it is in effect.
omarchy_framework13_ai300_mic_ucm_off() {
  local id
  id=$(omarchy_framework13_ai300_mic_device_id)
  [[ -n $id ]] || return 1
  wpctl inspect "$id" 2>/dev/null | grep 'api.alsa.use-ucm = "false"' >/dev/null
}

if [[ $(cat "$sys_vendor" 2>/dev/null) == "Framework" ]] &&
  [[ $(cat "$product_name" 2>/dev/null) == "Laptop 13 (AMD Ryzen AI 300 Series)" ]]; then
  omarchy_framework13_ai300_mic_matched=1

  mic_rule='monitor.alsa.rules = [
  {
    matches = [
      {
        device.name = "~alsa_card.pci-*"
        device.product.name = "Ryzen HD Audio Controller"
      }
    ]
    actions = {
      update-props = {
        api.alsa.use-ucm = false
      }
    }
  }
]'

  current=""
  [[ -f $mic_conf ]] && current=$(<"$mic_conf")

  if [[ $current != "$mic_rule" ]]; then
    printf '%s\n' "$mic_rule" | install -Dm644 /dev/stdin "$mic_conf"
    omarchy_framework13_ai300_mic_changed=1
  fi
fi
