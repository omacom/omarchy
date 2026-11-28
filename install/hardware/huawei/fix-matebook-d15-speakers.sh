# Internal speakers for the Huawei MateBook D 15 BOHB-WAX9, version M1280.
#
# The ES8336 codec's speaker and headphone amplifiers are switched by two GPIOs.
# The kernel's sof_es8336 quirk for this board (BOHB-WAX9-PCB-B2) sets
# HEADPHONE_GPIO alone, which the driver reads as speakers on GPIO1 and
# headphones on GPIO0. On the M1280 the two are the other way round, so the
# speakers stay silent while their sink looks fine. 0x1b0 is the quirk the
# kernel picks here (0x1a0: DMIC, headphone GPIO, headset mic on MIC1) plus
# SPEAKERS_EN_GPIO1 (0x10), which swaps them: speakers on GPIO0, headphones on
# GPIO1.
#
# Other versions share the DMI product name, and the kernel's quirk is right on
# at least one of them, so this matches the version too. A quirk someone
# already set for this driver is left alone.
#
# modprobe -c prints the configuration modprobe will apply: every config
# directory and the kernel command line, with continued lines joined and module
# names spelled with underscores. Only grep's answer counts, and grep reads all
# of it, since a grep -q that stops early would leave modprobe writing into a
# closed pipe.
#
# https://github.com/omacom/omarchy/issues/15825
product_version="${OMARCHY_DMI_PRODUCT_VERSION:-/sys/class/dmi/id/product_version}"
modprobe_dir="${OMARCHY_MODPROBE_DIR:-/etc/modprobe.d}"

if omarchy-hw-match "BOHB-WAX9" &&
  grep -qx "M1280" "$product_version" 2>/dev/null &&
  ! { modprobe -c 2>/dev/null || true; } | grep -E '^options snd_soc_sof_es8336 (.* )?quirk=' >/dev/null; then
  sudo install -Dm644 /dev/stdin "$modprobe_dir/huawei-matebook-d15-speakers.conf" <<'CONF'
# Huawei MateBook D 15 M1280: the speaker amplifier is on GPIO0, not GPIO1.
options snd_soc_sof_es8336 quirk=0x1b0
CONF
fi
