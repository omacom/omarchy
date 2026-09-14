# Restore speaker output on pre-T2 "Touch Bar" MacBooks (Cirrus CS8409 audio).
#
# These models pair a Cirrus CS8409 HDA bridge with a MAX98706 speaker amp. The
# in-tree snd_hda_codec_cs8409 driver never initialises the amp, so the card
# comes up with speaker_outs=0 and only headphones work. fix-t2.sh does not
# cover them: it gates on the T2 PCI ID (106b:180[12]), which these Macs predate.
#
# davidjo/snd_hda_macbookpro ships the out-of-tree codec patch; the DKMS package
# rebuilds it against every installed kernel, so the fix survives kernel updates.
# Affected: MacBookPro13,2 MacBookPro13,3 MacBookPro14,2 MacBookPro14,3.

product_name="${OMARCHY_DMI_PRODUCT_NAME:-$(cat /sys/class/dmi/id/product_name 2>/dev/null)}"
pci="$(lspci -nn)"
if [[ $product_name =~ ^MacBookPro1[34],[23]$ ]] &&
  [[ $pci != *"106b:1801"* && $pci != *"106b:1802"* ]]; then
  echo "Detected pre-T2 MacBook with Cirrus CS8409 speakers"
  omarchy-pkg-add snd-hda-macbookpro-dkms-git
fi
