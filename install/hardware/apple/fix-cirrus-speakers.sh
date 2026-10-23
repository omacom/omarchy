# Restore speaker output on pre-T2 MacBooks with Cirrus CS8409 audio.
#
# These models pair a Cirrus CS8409 HDA bridge with a MAX98706 speaker amp. The
# in-tree snd_hda_codec_cs8409 driver never initialises the amp, so the card
# comes up with speaker_outs=0 and only headphones work. fix-t2.sh does not
# cover them: it gates on the T2 PCI ID (106b:180[12]), which these Macs predate.
#
# davidjo/snd_hda_macbookpro ships the out-of-tree codec patch; the DKMS package
# rebuilds it against every installed kernel, so the fix survives kernel updates.
# Affected: MacBookPro13,1-13,3 and MacBookPro14,1-14,3.
#
# A driver already built by hand (davidjo's dkms.sh or a fork) is left alone:
# pacman would refuse its /usr/src files, and a second DKMS version would race
# it for updates/dkms on every kernel update.

product_name="${OMARCHY_DMI_PRODUCT_NAME:-$(cat /sys/class/dmi/id/product_name 2>/dev/null)}"
pci="$(lspci -nn)"
if [[ $product_name =~ ^MacBookPro1[34],[1-3]$ ]] &&
  [[ $pci != *"106b:1801"* && $pci != *"106b:1802"* ]]; then
  if [[ -e ${OMARCHY_CS8409_SRC_DIR:-/usr/src/snd_hda_macbookpro-0.1} ]] ||
    { omarchy-cmd-present dkms && [[ -n $(dkms status snd_hda_macbookpro 2>/dev/null) ]]; }; then
    echo "Existing snd_hda_macbookpro driver found; leaving it in place"
  else
    echo "Detected pre-T2 MacBook with Cirrus CS8409 speakers"
    omarchy-pkg-add snd-hda-macbookpro-dkms-git
  fi
fi
